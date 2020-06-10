//
//  GDorisCropView.m
//  GDoris
//
//  Created by GIKI on 2018/9/5.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisCropView.h"
#import "GDorisCropOverlayView.h"
#import "GDorisCropScrollView.h"

static const CGFloat kGDorisCropViewPadding = 14.0f;
static const NSTimeInterval kGDorisCropTimerDuration = 0.8f;
static const CGFloat kGDorisCropViewMinimumBoxSize = 42.0f;
//static const CGFloat kGDorisCropViewCircularPathRadius = 300.0f;
static const CGFloat kGDorisMaximumZoomScale = 15.0f;

/*
 当用户点击裁剪框来调整大小时，将使用此状态
 以确定他们点击的位置和如何操作裁剪框
 */
typedef NS_ENUM(NSInteger, GDoirsCropViewOverlayEdge) {
    GDorisCropViewOverlayEdgeNone,
    GDorisCropViewOverlayEdgeTopLeft,
    GDorisCropViewOverlayEdgeTop,
    GDorisCropViewOverlayEdgeTopRight,
    GDorisCropViewOverlayEdgeRight,
    GDorisCropViewOverlayEdgeBottomRight,
    GDorisCropViewOverlayEdgeBottom,
    GDorisCropViewOverlayEdgeBottomLeft,
    GDorisCropViewOverlayEdgeLeft
};

@interface GDorisCropView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong, readwrite) UIImage *image;

/* Views */
/// 主视图，位于scrollVIew中
@property (nonatomic, strong) UIImageView *backgroundImageView;
/// 包含背景图像视图的视图，用于将其转换与滚动视图分离。
@property (nonatomic, strong) UIView *backgroundContainerView;
@property (nonatomic, strong, readwrite) UIView *foregroundContainerView;
/// 包含背景图像视图的视图, 用于将其转换从滚动视图中分离出来。
@property (nonatomic, strong) UIImageView *foregroundImageView;
/// 负责平移/缩放图像的滚动视图。
@property (nonatomic, strong) GDorisCropScrollView *scrollView;
/// 半透明的灰色视图, 覆盖在背景图像的顶部
@property (nonatomic, strong) UIView *overlayView;
/// 当用户没有与 "裁剪" 视图进行交互时, 显示的模糊视图
@property (nonatomic, strong) UIView *translucencyView;
/// UIBlurEffect
@property (nonatomic, strong) id translucencyEffect;
/// 裁剪网格视图
@property (nonatomic, strong, readwrite) GDorisCropOverlayView *gridOverlayView;
/// Gesture Recognizers
@property (nonatomic, strong) UIPanGestureRecognizer *gridPanGestureRecognizer;

/* Crop box handling */
///  否则默认情况下，设置initialCroppedImageFrame时，这将设置为YES，并在第一次应用后设置回NO - 所以它只执行一次
@property (nonatomic, assign) BOOL applyInitialCroppedImageFrame;
///  用户点击的边缘区域, 以调整裁剪区域的大小
@property (nonatomic, assign) GDoirsCropViewOverlayEdge tappedEdge;
///  调整大小时, 裁剪框的初始Frame。
@property (nonatomic, assign) CGRect cropOriginFrame;
///  手势起始识别坐标
@property (nonatomic, assign) CGPoint panOriginPoint;
/// 网格和裁剪容器视图
@property (nonatomic, assign, readwrite) CGRect cropBoxFrame;
/// 用户停止与之交互后用于重置视图的计时器
@property (nonatomic, strong) NSTimer *resetTimer;
/// 编辑状态
@property (nonatomic, assign) BOOL editing;
/// 有时在动画期间，禁用将前景图像视图与背景匹配
@property (nonatomic, assign) BOOL disableForgroundMatching;

/* Pre-screen-rotation state information */
@property (nonatomic, assign) CGPoint rotationContentOffset;
@property (nonatomic, assign) CGSize  rotationContentSize;
@property (nonatomic, assign) CGRect  rotationBoundFrame;

/* View State information */
/// 给出当前屏幕的属性，允许滚动视图使用的框架。
@property (nonatomic, readonly) CGRect contentBounds;
 /* Given the current rotation of the image, the size of the image */
@property (nonatomic, readonly) CGSize imageSize;
///  如果宽高比明确应用于此裁剪视图，则为True
@property (nonatomic, readonly) BOOL hasAspectRatio;

/* 90-degree rotation state data */
/// 记录旋转前的尺寸
@property (nonatomic, assign) CGSize cropBoxLastEditedSize;
/// 记录保存编辑大小时的角度
@property (nonatomic, assign) NSInteger cropBoxLastEditedAngle;
/// 记录上次编辑的缩放尺寸
@property (nonatomic, assign) CGFloat cropBoxLastEditedZoomScale;
/// 记录上次编辑的最小尺寸。
@property (nonatomic, assign) CGFloat cropBoxLastEditedMinZoomScale;
/// 在旋转动画时禁止任何输入
@property (nonatomic, assign) BOOL rotateAnimationInProgress;

/* Reset state data */
/// 保存原始裁剪框大小，以便我们可以判断内容何时被编辑
@property (nonatomic, assign) CGSize originalCropBoxSize;
/// 保存原始内容偏移量，以便我们可以判断它是否已滚动。
@property (nonatomic, assign) CGPoint originalContentOffset;
@property (nonatomic, assign, readwrite) BOOL canBeReset;

/* In iOS 9, a new dynamic blur effect became available. */
@property (nonatomic, assign) BOOL dynamicBlurEffect;

/* If restoring to a previous crop setting, these properties hang onto the
 values until the view is configured for the first time. */
@property (nonatomic, assign) NSInteger restoreAngle;
@property (nonatomic, assign) CGRect    restoreImageCropFrame;

/* Set to YES once `performInitialLayout` is called. This lets pending properties get queued until the view
 has been properly set up in its parent. */
@property (nonatomic, assign) BOOL initialSetupPerformed;
@end

@implementation GDorisCropView

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _image = image;
        [self setup];
    }
    return self;
}

- (void)setup
{
    __weak typeof(self) weakSelf = self;
    
    //View properties
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundColor =  [UIColor colorWithWhite:0.12f alpha:1.0f];
    self.cropBoxFrame = CGRectZero;
    self.applyInitialCroppedImageFrame = NO;
    self.editing = NO;
    self.cropBoxResizeEnabled = YES;
    self.aspectRatio = CGSizeZero;
    self.resetAspectRatioEnabled = YES;
    self.restoreImageCropFrame = CGRectZero;
    self.restoreAngle = 0;
    self.cropAdjustingDelay = kGDorisCropTimerDuration;
    self.cropViewPadding = kGDorisCropViewPadding;
    self.maximumZoomScale = kGDorisMaximumZoomScale;
    
    /* Dynamic animation blurring is only possible on iOS 9, however since the API was available on iOS 8,
     we'll need to manually check the system version to ensure that it's available. */
    self.dynamicBlurEffect =  ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending);
    
    //Scroll View properties
    self.scrollView = [[GDorisCropScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.scrollView];
    
    // Disable smart inset behavior in iOS 11
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.scrollView.touchesBegan = ^{ [weakSelf startEditing]; };
    self.scrollView.touchesEnded = ^{ [weakSelf startResetTimer]; };
    
    //Background Image View
    self.backgroundImageView = [[UIImageView alloc] initWithImage:self.image];
    self.backgroundImageView.layer.minificationFilter = kCAFilterTrilinear;
    
    //Background container view
    self.backgroundContainerView = [[UIView alloc] initWithFrame:self.backgroundImageView.frame];
    [self.backgroundContainerView addSubview:self.backgroundImageView];
    [self.scrollView addSubview:self.backgroundContainerView];
    
    //Grey transparent overlay view
    self.overlayView = [[UIView alloc] initWithFrame:self.bounds];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.35f];
    
    self.overlayView.hidden = NO;
    self.overlayView.userInteractionEnabled = NO;
    [self addSubview:self.overlayView];
    
    //Translucency View
    if (NSClassFromString(@"UIVisualEffectView")) {
        self.translucencyEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.translucencyView = [[UIVisualEffectView alloc] initWithEffect:self.translucencyEffect];
        self.translucencyView.frame = self.bounds;
    }
    else {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.barStyle = UIBarStyleBlack;
        self.translucencyView = toolbar;
        self.translucencyView.frame = CGRectInset(self.bounds, -1.0f, -1.0f);
    }
    self.translucencyView.hidden = NO;
    self.translucencyView.userInteractionEnabled = NO;
    self.translucencyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.translucencyView];
    
    // The forground container that holds the foreground image view
    self.foregroundContainerView = [[UIView alloc] initWithFrame:(CGRect){0,0,200,200}];
    self.foregroundContainerView.clipsToBounds = YES;
    self.foregroundContainerView.userInteractionEnabled = NO;
    [self addSubview:self.foregroundContainerView];
    self.foregroundImageView = [[UIImageView alloc] initWithImage:self.image];
    self.foregroundImageView.layer.minificationFilter = kCAFilterTrilinear;
    [self.foregroundContainerView addSubview:self.foregroundImageView];
    // Disable colour inversion for the image views
    if (@available(iOS 11.0, *)) {
        self.foregroundImageView.accessibilityIgnoresInvertColors = YES;
        self.backgroundImageView.accessibilityIgnoresInvertColors = YES;
    }
    
    // The white grid overlay view
    self.gridOverlayView = [[GDorisCropOverlayView alloc] initWithFrame:self.foregroundContainerView.frame];
    self.gridOverlayView.userInteractionEnabled = NO;
    self.gridOverlayView.gridHidden = YES;
    [self addSubview:self.gridOverlayView];
    
    // The pan controller to recognize gestures meant to resize the grid view
    self.gridPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gridPanGestureRecognized:)];
    self.gridPanGestureRecognizer.delegate = self;
    [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.gridPanGestureRecognizer];
    [self addGestureRecognizer:self.gridPanGestureRecognizer];
}

#pragma mark - View Layout -
- (void)performInitialSetup
{
    // Calling this more than once is potentially destructive
    if (self.initialSetupPerformed) {
        return;
    }
    
    // Disable from calling again
    self.initialSetupPerformed = YES;
    
    //Perform the initial layout of the image
    [self layoutInitialImage];
    
    // -- State Restoration --
    
    //If the angle value was previously set before this point, apply it now
    if (self.restoreAngle != 0) {
        self.angle = self.restoreAngle;
        self.restoreAngle = 0;
        self.cropBoxLastEditedAngle = self.angle;
    }
    
    //If an image crop frame was also specified before creation, apply it now
    if (!CGRectIsEmpty(self.restoreImageCropFrame)) {
        self.imageCropFrame = self.restoreImageCropFrame;
        self.restoreImageCropFrame = CGRectZero;
    }
    
    // Save the current layout state for later
    [self captureStateForImageRotation];
    
    //Check if we performed any resetabble modifications
    [self checkForCanReset];
}

- (void)layoutInitialImage
{
    CGSize imageSize = self.imageSize;
    self.scrollView.contentSize = imageSize;
    
    CGRect bounds = self.contentBounds;
    CGSize boundsSize = bounds.size;
    
    //work out the minimum scale of the object
    CGFloat scale = 0.0f;
    
    // Work out the size of the image to fit into the content bounds
    scale = MIN(CGRectGetWidth(bounds)/imageSize.width, CGRectGetHeight(bounds)/imageSize.height);
    CGSize scaledImageSize = (CGSize){floorf(imageSize.width * scale), floorf(imageSize.height * scale)};
    
    // If an aspect ratio was pre-applied to the crop view, use that to work out the minimum scale the image needs to be to fit
    CGSize cropBoxSize = CGSizeZero;
    if (self.hasAspectRatio) {
        CGFloat ratioScale = (self.aspectRatio.width / self.aspectRatio.height); //Work out the size of the width in relation to height
        CGSize fullSizeRatio = (CGSize){boundsSize.height * ratioScale, boundsSize.height};
        CGFloat fitScale = MIN(boundsSize.width/fullSizeRatio.width, boundsSize.height/fullSizeRatio.height);
        cropBoxSize = (CGSize){fullSizeRatio.width * fitScale, fullSizeRatio.height * fitScale};
        
        scale = MAX(cropBoxSize.width/imageSize.width, cropBoxSize.height/imageSize.height);
    }
    
    //Whether aspect ratio, or original, the final image size we'll base the rest of the calculations off
    CGSize scaledSize = (CGSize){floorf(imageSize.width * scale), floorf(imageSize.height * scale)};
    
    // Configure the scroll view
    self.scrollView.minimumZoomScale = scale;
    self.scrollView.maximumZoomScale = scale * self.maximumZoomScale;
    
    //Set the crop box to the size we calculated and align in the middle of the screen
    CGRect frame = CGRectZero;
    frame.size = self.hasAspectRatio ? cropBoxSize : scaledSize;
    frame.origin.x = bounds.origin.x + floorf((CGRectGetWidth(bounds) - frame.size.width) * 0.5f);
    frame.origin.y = bounds.origin.y + floorf((CGRectGetHeight(bounds) - frame.size.height) * 0.5f);
    self.cropBoxFrame = frame;
    
    //set the fully zoomed out state initially
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.contentSize = scaledSize;
    
    // If we ended up with a smaller crop box than the content, line up the content so its center
    // is in the center of the cropbox
    if (frame.size.width < scaledSize.width - FLT_EPSILON || frame.size.height < scaledSize.height - FLT_EPSILON) {
        CGPoint offset = CGPointZero;
        offset.x = -floorf(CGRectGetMidX(bounds) - (scaledSize.width * 0.5f));
        offset.y = -floorf(CGRectGetMidY(bounds) - (scaledSize.height * 0.5f));
        self.scrollView.contentOffset = offset;
    }
    
    //save the current state for use with 90-degree rotations
    self.cropBoxLastEditedAngle = 0;
    [self captureStateForImageRotation];
    
    //save the size for checking if we're in a resettable state
    self.originalCropBoxSize = self.resetAspectRatioEnabled ? scaledImageSize : cropBoxSize;
    self.originalContentOffset = self.scrollView.contentOffset;
    
    [self checkForCanReset];
    [self matchForegroundToBackground];
}

- (void)prepareforRotation
{
    self.rotationContentOffset = self.scrollView.contentOffset;
    self.rotationContentSize   = self.scrollView.contentSize;
    self.rotationBoundFrame     = self.contentBounds;
}

- (void)performRelayoutForRotation
{
    CGRect cropFrame = self.cropBoxFrame;
    CGRect contentFrame = self.contentBounds;
    
    CGFloat scale = MIN(contentFrame.size.width / cropFrame.size.width, contentFrame.size.height / cropFrame.size.height);
    self.scrollView.minimumZoomScale *= scale;
    self.scrollView.zoomScale *= scale;
    
    //Work out the centered, upscaled version of the crop rectangle
    cropFrame.size.width  = floorf(cropFrame.size.width * scale);
    cropFrame.size.height = floorf(cropFrame.size.height * scale);
    cropFrame.origin.x    = floorf(contentFrame.origin.x + ((contentFrame.size.width - cropFrame.size.width) * 0.5f));
    cropFrame.origin.y    = floorf(contentFrame.origin.y + ((contentFrame.size.height - cropFrame.size.height) * 0.5f));
    self.cropBoxFrame = cropFrame;
    
    [self captureStateForImageRotation];
    
    //Work out the center point of the content before we rotated
    CGPoint oldMidPoint = (CGPoint){CGRectGetMidX(self.rotationBoundFrame), CGRectGetMidY(self.rotationBoundFrame)};
    CGPoint contentCenter = (CGPoint){self.rotationContentOffset.x + oldMidPoint.x, self.rotationContentOffset.y + oldMidPoint.y};
    
    //Normalize it to a percentage we can apply to different sizes
    CGPoint normalizedCenter = CGPointZero;
    normalizedCenter.x = contentCenter.x / self.rotationContentSize.width;
    normalizedCenter.y = contentCenter.y / self.rotationContentSize.height;
    
    //Work out the new content offset by applying the normalized values to the new layout
    CGPoint newMidPoint = (CGPoint){CGRectGetMidX(self.contentBounds),CGRectGetMidY(self.contentBounds)};
    
    CGPoint translatedContentOffset = CGPointZero;
    translatedContentOffset.x = self.scrollView.contentSize.width * normalizedCenter.x;
    translatedContentOffset.y = self.scrollView.contentSize.height * normalizedCenter.y;
    
    CGPoint offset = CGPointZero;
    offset.x = floorf(translatedContentOffset.x - newMidPoint.x);
    offset.y = floorf(translatedContentOffset.y - newMidPoint.y);
    
    //Make sure it doesn't overshoot the top left corner of the crop box
    offset.x = MAX(-self.scrollView.contentInset.left, offset.x);
    offset.y = MAX(-self.scrollView.contentInset.top, offset.y);
    
    //Nor undershoot the bottom right corner
    CGPoint maximumOffset = CGPointZero;
    maximumOffset.x = (self.bounds.size.width - self.scrollView.contentInset.right) + self.scrollView.contentSize.width;
    maximumOffset.y = (self.bounds.size.height - self.scrollView.contentInset.bottom) + self.scrollView.contentSize.height;
    offset.x = MIN(offset.x, maximumOffset.x);
    offset.y = MIN(offset.y, maximumOffset.y);
    self.scrollView.contentOffset = offset;
    
    //Line up the background instance of the image
    [self matchForegroundToBackground];
}

- (void)matchForegroundToBackground
{
    if (self.disableForgroundMatching)
        return;
    
    //We can't simply match the frames since if the images are rotated, the frame property becomes unusable
    self.foregroundImageView.frame = [self.backgroundContainerView.superview convertRect:self.backgroundContainerView.frame toView:self.foregroundContainerView];
}

- (void)updateCropBoxFrameWithGesturePoint:(CGPoint)point
{
    CGRect frame = self.cropBoxFrame;
    CGRect originFrame = self.cropOriginFrame;
    CGRect contentFrame = self.contentBounds;
    
    point.x = MAX(contentFrame.origin.x - self.cropViewPadding, point.x);
    point.y = MAX(contentFrame.origin.y - self.cropViewPadding, point.y);
    
    //The delta between where we first tapped, and where our finger is now
    CGFloat xDelta = ceilf(point.x - self.panOriginPoint.x);
    CGFloat yDelta = ceilf(point.y - self.panOriginPoint.y);
    
    //Current aspect ratio of the crop box in case we need to clamp it
    CGFloat aspectRatio = (originFrame.size.width / originFrame.size.height);
    
    //Note whether we're being aspect transformed horizontally or vertically
    BOOL aspectHorizontal = NO, aspectVertical = NO;
    
    //Depending on which corner we drag from, set the appropriate min flag to
    //ensure we can properly clamp the XY value of the box if it overruns the minimum size
    //(Otherwise the image itself will slide with the drag gesture)
    BOOL clampMinFromTop = NO, clampMinFromLeft = NO;
    
    switch (self.tappedEdge) {
        case GDorisCropViewOverlayEdgeLeft:
            if (self.aspectRatioLockEnabled) {
                aspectHorizontal = YES;
                xDelta = MAX(xDelta, 0);
                CGPoint scaleOrigin = (CGPoint){CGRectGetMaxX(originFrame), CGRectGetMidY(originFrame)};
                frame.size.height = frame.size.width / aspectRatio;
                frame.origin.y = scaleOrigin.y - (frame.size.height * 0.5f);
            }
            CGFloat newWidth = originFrame.size.width - xDelta;
            CGFloat newHeight = originFrame.size.height;
            if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                frame.origin.x   = originFrame.origin.x + xDelta;
                frame.size.width = originFrame.size.width - xDelta;
            }
            
            clampMinFromLeft = YES;
            
            break;
        case GDorisCropViewOverlayEdgeRight:
            if (self.aspectRatioLockEnabled) {
                aspectHorizontal = YES;
                CGPoint scaleOrigin = (CGPoint){CGRectGetMinX(originFrame), CGRectGetMidY(originFrame)};
                frame.size.height = frame.size.width / aspectRatio;
                frame.origin.y = scaleOrigin.y - (frame.size.height * 0.5f);
                frame.size.width = originFrame.size.width + xDelta;
                frame.size.width = MIN(frame.size.width, contentFrame.size.height * aspectRatio);
            }
            else {
                CGFloat newWidth = originFrame.size.width + xDelta;
                CGFloat newHeight = originFrame.size.height;
                if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                    frame.size.width = originFrame.size.width + xDelta;
                }
            }
            
            break;
        case GDorisCropViewOverlayEdgeBottom:
            if (self.aspectRatioLockEnabled) {
                aspectVertical = YES;
                CGPoint scaleOrigin = (CGPoint){CGRectGetMidX(originFrame), CGRectGetMinY(originFrame)};
                frame.size.width = frame.size.height * aspectRatio;
                frame.origin.x = scaleOrigin.x - (frame.size.width * 0.5f);
                frame.size.height = originFrame.size.height + yDelta;
                frame.size.height = MIN(frame.size.height, contentFrame.size.width / aspectRatio);
            }
            else {
                CGFloat newWidth = originFrame.size.width;
                CGFloat newHeight = originFrame.size.height + yDelta;
                
                if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                    frame.size.height = originFrame.size.height + yDelta;
                }
            }
            break;
        case GDorisCropViewOverlayEdgeTop:
            if (self.aspectRatioLockEnabled) {
                aspectVertical = YES;
                yDelta = MAX(0,yDelta);
                CGPoint scaleOrigin = (CGPoint){CGRectGetMidX(originFrame), CGRectGetMaxY(originFrame)};
                frame.size.width = frame.size.height * aspectRatio;
                frame.origin.x = scaleOrigin.x - (frame.size.width * 0.5f);
                frame.origin.y    = originFrame.origin.y + yDelta;
                frame.size.height = originFrame.size.height - yDelta;
            }
            else {
                CGFloat newWidth = originFrame.size.width;
                CGFloat newHeight = originFrame.size.height - yDelta;
                
                if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                    frame.origin.y    = originFrame.origin.y + yDelta;
                    frame.size.height = originFrame.size.height - yDelta;
                }
            }
            
            clampMinFromTop = YES;
            
            break;
        case GDorisCropViewOverlayEdgeTopLeft:
            if (self.aspectRatioLockEnabled) {
                xDelta = MAX(xDelta, 0);
                yDelta = MAX(yDelta, 0);
                
                CGPoint distance;
                distance.x = 1.0f - (xDelta / CGRectGetWidth(originFrame));
                distance.y = 1.0f - (yDelta / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                frame.origin.x = originFrame.origin.x + (CGRectGetWidth(originFrame) - frame.size.width);
                frame.origin.y = originFrame.origin.y + (CGRectGetHeight(originFrame) - frame.size.height);
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                CGFloat newWidth = originFrame.size.width - xDelta;
                CGFloat newHeight = originFrame.size.height - yDelta;
                
                if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                    frame.origin.x   = originFrame.origin.x + xDelta;
                    frame.size.width = originFrame.size.width - xDelta;
                    frame.origin.y   = originFrame.origin.y + yDelta;
                    frame.size.height = originFrame.size.height - yDelta;
                }
            }
            
            clampMinFromTop = YES;
            clampMinFromLeft = YES;
            
            break;
        case GDorisCropViewOverlayEdgeTopRight:
            if (self.aspectRatioLockEnabled) {
                xDelta = MIN(xDelta, 0);
                yDelta = MAX(yDelta, 0);
                
                CGPoint distance;
                distance.x = 1.0f - ((-xDelta) / CGRectGetWidth(originFrame));
                distance.y = 1.0f - ((yDelta) / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                frame.origin.y = originFrame.origin.y + (CGRectGetHeight(originFrame) - frame.size.height);
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                CGFloat newWidth = originFrame.size.width + xDelta;
                CGFloat newHeight = originFrame.size.height - yDelta;
                
                if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                    frame.size.width  = originFrame.size.width + xDelta;
                    frame.origin.y    = originFrame.origin.y + yDelta;
                    frame.size.height = originFrame.size.height - yDelta;
                }
            }
            
            clampMinFromTop = YES;
            
            break;
        case GDorisCropViewOverlayEdgeBottomLeft:
            if (self.aspectRatioLockEnabled) {
                CGPoint distance;
                distance.x = 1.0f - (xDelta / CGRectGetWidth(originFrame));
                distance.y = 1.0f - (-yDelta / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                frame.origin.x = CGRectGetMaxX(originFrame) - frame.size.width;
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                CGFloat newWidth = originFrame.size.width - xDelta;
                CGFloat newHeight = originFrame.size.height + yDelta;
                
                if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                    frame.size.height = originFrame.size.height + yDelta;
                    frame.origin.x    = originFrame.origin.x + xDelta;
                    frame.size.width  = originFrame.size.width - xDelta;
                }
            }
            
            clampMinFromLeft = YES;
            
            break;
        case GDorisCropViewOverlayEdgeBottomRight:
            if (self.aspectRatioLockEnabled) {
                
                CGPoint distance;
                distance.x = 1.0f - ((-1 * xDelta) / CGRectGetWidth(originFrame));
                distance.y = 1.0f - ((-1 * yDelta) / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                CGFloat newWidth = originFrame.size.width + xDelta;
                CGFloat newHeight = originFrame.size.height + yDelta;
                
                if (MIN(newHeight, newWidth) / MAX(newHeight, newWidth) >= (double)_minimumAspectRatio) {
                    frame.size.height = originFrame.size.height + yDelta;
                    frame.size.width = originFrame.size.width + xDelta;
                }
            }
            break;
        case GDorisCropViewOverlayEdgeNone: break;
    }
    
    //The absolute max/min size the box may be in the bounds of the crop view
    CGSize minSize = (CGSize){kGDorisCropViewMinimumBoxSize, kGDorisCropViewMinimumBoxSize};
    CGSize maxSize = (CGSize){CGRectGetWidth(contentFrame), CGRectGetHeight(contentFrame)};
    
    //clamp the box to ensure it doesn't go beyond the bounds we've set
    if (self.aspectRatioLockEnabled && aspectHorizontal) {
        maxSize.height = contentFrame.size.width / aspectRatio;
        minSize.width = kGDorisCropViewMinimumBoxSize * aspectRatio;
    }
    
    if (self.aspectRatioLockEnabled && aspectVertical) {
        maxSize.width = contentFrame.size.height * aspectRatio;
        minSize.height = kGDorisCropViewMinimumBoxSize / aspectRatio;
    }
    
    // Clamp the width if it goes over
    if (clampMinFromLeft) {
        CGFloat maxWidth = CGRectGetMaxX(self.cropOriginFrame) - contentFrame.origin.x;
        frame.size.width = MIN(frame.size.width, maxWidth);
    }
    
    if (clampMinFromTop) {
        CGFloat maxHeight = CGRectGetMaxY(self.cropOriginFrame) - contentFrame.origin.y;
        frame.size.height = MIN(frame.size.height, maxHeight);
    }
    
    //Clamp the minimum size
    frame.size.width  = MAX(frame.size.width, minSize.width);
    frame.size.height = MAX(frame.size.height, minSize.height);
    
    //Clamp the maximum size
    frame.size.width  = MIN(frame.size.width, maxSize.width);
    frame.size.height = MIN(frame.size.height, maxSize.height);
    
    //Clamp the X position of the box to the interior of the cropping bounds
    frame.origin.x = MAX(frame.origin.x, CGRectGetMinX(contentFrame));
    frame.origin.x = MIN(frame.origin.x, CGRectGetMaxX(contentFrame) - minSize.width);
    
    //Clamp the Y postion of the box to the interior of the cropping bounds
    frame.origin.y = MAX(frame.origin.y, CGRectGetMinY(contentFrame));
    frame.origin.y = MIN(frame.origin.y, CGRectGetMaxY(contentFrame) - minSize.height);
    
    //Once the box is completely shrunk, clamp its ability to move
    if (clampMinFromLeft && frame.size.width <= minSize.width + FLT_EPSILON) {
        frame.origin.x = CGRectGetMaxX(originFrame) - minSize.width;
    }
    
    //Once the box is completely shrunk, clamp its ability to move
    if (clampMinFromTop && frame.size.height <= minSize.height + FLT_EPSILON) {
        frame.origin.y = CGRectGetMaxY(originFrame) - minSize.height;
    }
    
    self.cropBoxFrame = frame;
    
    [self checkForCanReset];
}

- (void)resetLayoutToDefaultAnimated:(BOOL)animated
{
    // If resetting the crop view includes resetting the aspect ratio,
    // reset it to zero here. But set the ivar directly since there's no point
    // in performing the relayout calculations right before a reset.
    if (self.hasAspectRatio && self.resetAspectRatioEnabled) {
        _aspectRatio = CGSizeZero;
    }
    
    if (animated == NO || self.angle != 0) {
        //Reset all of the rotation transforms
        _angle = 0;
        
        //Set the scroll to 1.0f to reset the transform scale
        self.scrollView.zoomScale = 1.0f;
        
        CGRect imageRect = (CGRect){CGPointZero, self.image.size};
        
        //Reset everything about the background container and image views
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundContainerView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = imageRect;
        self.backgroundContainerView.frame = imageRect;
        
        //Reset the transform ans size of just the foreground image
        self.foregroundImageView.transform = CGAffineTransformIdentity;
        self.foregroundImageView.frame = imageRect;
        
        //Reset the layout
        [self layoutInitialImage];
        
        //Enable / Disable the reset button
        [self checkForCanReset];
        
        return;
    }
    
    //If we were in the middle of a reset timer, cancel it as we'll
    //manually perform a restoration animation here
    if (self.resetTimer) {
        [self cancelResetTimer];
        [self setEditing:NO resetCropBox:NO animated:NO];
    }
    
    [self setSimpleRenderMode:YES animated:NO];
    
    //Perform an animation of the image zooming back out to its original size
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self layoutInitialImage];
        } completion:^(BOOL complete) {
            [self setSimpleRenderMode:NO animated:YES];
        }];
    });
}

- (void)toggleTranslucencyViewVisible:(BOOL)visible
{
    if (self.dynamicBlurEffect == NO) {
        self.translucencyView.alpha = visible ? 1.0f : 0.0f;
    }
    else {
        [(UIVisualEffectView *)self.translucencyView setEffect:visible ? self.translucencyEffect : nil];
    }
}

- (void)updateToImageCropFrame:(CGRect)imageCropframe
{
    //Convert the image crop frame's size from image space to the screen space
    CGFloat minimumSize = self.scrollView.minimumZoomScale;
    CGPoint scaledOffset = (CGPoint){imageCropframe.origin.x * minimumSize, imageCropframe.origin.y * minimumSize};
    CGSize scaledCropSize = (CGSize){imageCropframe.size.width * minimumSize, imageCropframe.size.height * minimumSize};
    
    // Work out the scale necessary to upscale the crop size to fit the content bounds of the crop bound
    CGRect bounds = self.contentBounds;
    CGFloat scale = MIN(bounds.size.width / scaledCropSize.width, bounds.size.height / scaledCropSize.height);
    
    // Zoom into the scroll view to the appropriate size
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale * scale;
    
    // Work out the size and offset of the upscaled crop box
    CGRect frame = CGRectZero;
    frame.size = (CGSize){scaledCropSize.width * scale, scaledCropSize.height * scale};
    
    //set the crop box
    CGRect cropBoxFrame = CGRectZero;
    cropBoxFrame.size = frame.size;
    cropBoxFrame.origin.x = CGRectGetMidX(bounds) - (frame.size.width * 0.5f);
    cropBoxFrame.origin.y = CGRectGetMidY(bounds) - (frame.size.height * 0.5f);
    self.cropBoxFrame = cropBoxFrame;
    
    frame.origin.x = (scaledOffset.x * scale) - self.scrollView.contentInset.left;
    frame.origin.y = (scaledOffset.y * scale) - self.scrollView.contentInset.top;
    self.scrollView.contentOffset = frame.origin;
}

#pragma mark - Gesture Recognizer -
- (void)gridPanGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self startEditing];
        self.panOriginPoint = point;
        self.cropOriginFrame = self.cropBoxFrame;
        self.tappedEdge = [self cropEdgeForPoint:self.panOriginPoint];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self startResetTimer];
    }
    
    [self updateCropBoxFrameWithGesturePoint:point];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
        [self.gridOverlayView setGridHidden:NO animated:YES];
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self.gridOverlayView setGridHidden:YES animated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.gridPanGestureRecognizer)
        return YES;
    
    CGPoint tapPoint = [gestureRecognizer locationInView:self];
    
    CGRect frame = self.gridOverlayView.frame;
    CGRect innerFrame = CGRectInset(frame, 22.0f, 22.0f);
    CGRect outerFrame = CGRectInset(frame, -22.0f, -22.0f);
    
    if (CGRectContainsPoint(innerFrame, tapPoint) || !CGRectContainsPoint(outerFrame, tapPoint))
        return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.gridPanGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        return NO;
    }
    return YES;
}

#pragma mark - Timer -
- (void)startResetTimer
{
    if (self.resetTimer)
        return;
    
    self.resetTimer = [NSTimer scheduledTimerWithTimeInterval:self.cropAdjustingDelay target:self selector:@selector(timerTriggered) userInfo:nil repeats:NO];
}

- (void)timerTriggered
{
    [self setEditing:NO resetCropBox:YES animated:YES];
    [self.resetTimer invalidate];
    self.resetTimer = nil;
}

- (void)cancelResetTimer
{
    [self.resetTimer invalidate];
    self.resetTimer = nil;
}

- (GDoirsCropViewOverlayEdge)cropEdgeForPoint:(CGPoint)point
{
    CGRect frame = self.cropBoxFrame;
    
    //account for padding around the box
    frame = CGRectInset(frame, -32.0f, -32.0f);
    
    //Make sure the corners take priority
    CGRect topLeftRect = (CGRect){frame.origin, {64,64}};
    if (CGRectContainsPoint(topLeftRect, point))
        return GDorisCropViewOverlayEdgeTopLeft;
    
    CGRect topRightRect = topLeftRect;
    topRightRect.origin.x = CGRectGetMaxX(frame) - 64.0f;
    if (CGRectContainsPoint(topRightRect, point))
        return GDorisCropViewOverlayEdgeTopRight;
    
    CGRect bottomLeftRect = topLeftRect;
    bottomLeftRect.origin.y = CGRectGetMaxY(frame) - 64.0f;
    if (CGRectContainsPoint(bottomLeftRect, point))
        return GDorisCropViewOverlayEdgeBottomLeft;
    
    CGRect bottomRightRect = topRightRect;
    bottomRightRect.origin.y = bottomLeftRect.origin.y;
    if (CGRectContainsPoint(bottomRightRect, point))
        return GDorisCropViewOverlayEdgeBottomRight;
    
    //Check for edges
    CGRect topRect = (CGRect){frame.origin, {CGRectGetWidth(frame), 64.0f}};
    if (CGRectContainsPoint(topRect, point))
        return GDorisCropViewOverlayEdgeTop;
    
    CGRect bottomRect = topRect;
    bottomRect.origin.y = CGRectGetMaxY(frame) - 64.0f;
    if (CGRectContainsPoint(bottomRect, point))
        return GDorisCropViewOverlayEdgeBottom;
    
    CGRect leftRect = (CGRect){frame.origin, {64.0f, CGRectGetHeight(frame)}};
    if (CGRectContainsPoint(leftRect, point))
        return GDorisCropViewOverlayEdgeLeft;
    
    CGRect rightRect = leftRect;
    rightRect.origin.x = CGRectGetMaxX(frame) - 64.0f;
    if (CGRectContainsPoint(rightRect, point))
        return GDorisCropViewOverlayEdgeRight;
    
    return GDorisCropViewOverlayEdgeNone;
}

#pragma mark - Scroll View Delegate -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.backgroundContainerView;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self matchForegroundToBackground];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self startEditing];
    self.canBeReset = YES;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [self startEditing];
    self.canBeReset = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startResetTimer];
    [self checkForCanReset];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self startResetTimer];
    [self checkForCanReset];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView.isTracking) {
        self.cropBoxLastEditedZoomScale = scrollView.zoomScale;
        self.cropBoxLastEditedMinZoomScale = scrollView.minimumZoomScale;
    }
    
    [self matchForegroundToBackground];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self startResetTimer];
}

#pragma mark - Accessors -

- (void)setCropBoxResizeEnabled:(BOOL)panResizeEnabled {
    _cropBoxResizeEnabled = panResizeEnabled;
    self.gridPanGestureRecognizer.enabled = _cropBoxResizeEnabled;
}

- (void)setCropBoxFrame:(CGRect)cropBoxFrame
{
    if (CGRectEqualToRect(cropBoxFrame, _cropBoxFrame)) {
        return;
    }
    
    // Upon init, sometimes the box size is still 0 (or NaN), which can result in CALayer issues
    CGSize frameSize = cropBoxFrame.size;
    if (frameSize.width < FLT_EPSILON || frameSize.height < FLT_EPSILON) { return; }
    if (isnan(frameSize.width) || isnan(frameSize.height)) { return; }
    
    //clamp the cropping region to the inset boundaries of the screen
    CGRect contentFrame = self.contentBounds;
    CGFloat xOrigin = ceilf(contentFrame.origin.x);
    CGFloat xDelta = cropBoxFrame.origin.x - xOrigin;
    cropBoxFrame.origin.x = floorf(MAX(cropBoxFrame.origin.x, xOrigin));
    if (xDelta < -FLT_EPSILON) //If we clamp the x value, ensure we compensate for the subsequent delta generated in the width (Or else, the box will keep growing)
        cropBoxFrame.size.width += xDelta;
    
    CGFloat yOrigin = ceilf(contentFrame.origin.y);
    CGFloat yDelta = cropBoxFrame.origin.y - yOrigin;
    cropBoxFrame.origin.y = floorf(MAX(cropBoxFrame.origin.y, yOrigin));
    if (yDelta < -FLT_EPSILON)
        cropBoxFrame.size.height += yDelta;
    
    //given the clamped X/Y values, make sure we can't extend the crop box beyond the edge of the screen in the current state
    CGFloat maxWidth = (contentFrame.size.width + contentFrame.origin.x) - cropBoxFrame.origin.x;
    cropBoxFrame.size.width = floorf(MIN(cropBoxFrame.size.width, maxWidth));
    
    CGFloat maxHeight = (contentFrame.size.height + contentFrame.origin.y) - cropBoxFrame.origin.y;
    cropBoxFrame.size.height = floorf(MIN(cropBoxFrame.size.height, maxHeight));
    
    //Make sure we can't make the crop box too small
    cropBoxFrame.size.width  = MAX(cropBoxFrame.size.width, kGDorisCropViewMinimumBoxSize);
    cropBoxFrame.size.height = MAX(cropBoxFrame.size.height, kGDorisCropViewMinimumBoxSize);
    
    _cropBoxFrame = cropBoxFrame;
    
    self.foregroundContainerView.frame = _cropBoxFrame; //set the clipping view to match the new rect
    self.gridOverlayView.frame = _cropBoxFrame; //set the new overlay view to match the same region

    
    //reset the scroll view insets to match the region of the new crop rect
    self.scrollView.contentInset = (UIEdgeInsets){CGRectGetMinY(_cropBoxFrame),
        CGRectGetMinX(_cropBoxFrame),
        CGRectGetMaxY(self.bounds) - CGRectGetMaxY(_cropBoxFrame),
        CGRectGetMaxX(self.bounds) - CGRectGetMaxX(_cropBoxFrame)};
    
    //if necessary, work out the new minimum size of the scroll view so it fills the crop box
    CGSize imageSize = self.backgroundContainerView.bounds.size;
    CGFloat scale = MAX(cropBoxFrame.size.height/imageSize.height, cropBoxFrame.size.width/imageSize.width);
    self.scrollView.minimumZoomScale = scale;
    
    //make sure content isn't smaller than the crop box
    CGSize size = self.scrollView.contentSize;
    size.width = floorf(size.width);
    size.height = floorf(size.height);
    self.scrollView.contentSize = size;
    
    //IMPORTANT: Force the scroll view to update its content after changing the zoom scale
    self.scrollView.zoomScale = self.scrollView.zoomScale;
    
    [self matchForegroundToBackground]; //re-align the background content to match
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing resetCropBox:NO animated:NO];
}

- (void)setSimpleRenderMode:(BOOL)simpleMode
{
    [self setSimpleRenderMode:simpleMode animated:NO];
}

- (BOOL)cropBoxAspectRatioIsPortrait
{
    CGRect cropFrame = self.cropBoxFrame;
    return CGRectGetWidth(cropFrame) < CGRectGetHeight(cropFrame);
}

- (CGRect)imageCropFrame
{
    CGSize imageSize = self.imageSize;
    CGSize contentSize = self.scrollView.contentSize;
    CGRect cropBoxFrame = self.cropBoxFrame;
    CGPoint contentOffset = self.scrollView.contentOffset;
    UIEdgeInsets edgeInsets = self.scrollView.contentInset;
    CGFloat scale = MIN(imageSize.width / contentSize.width, imageSize.height / contentSize.height);
    
    CGRect frame = CGRectZero;
    
    // Calculate the normalized origin
    frame.origin.x = floorf((floorf(contentOffset.x) + edgeInsets.left) * (imageSize.width / contentSize.width));
    frame.origin.x = MAX(0, frame.origin.x);
    
    frame.origin.y = floorf((floorf(contentOffset.y) + edgeInsets.top) * (imageSize.height / contentSize.height));
    frame.origin.y = MAX(0, frame.origin.y);
    
    // Calculate the normalized width
    frame.size.width = ceilf(cropBoxFrame.size.width * scale);
    frame.size.width = MIN(imageSize.width, frame.size.width);
    
    // Calculate normalized height
    if (floor(cropBoxFrame.size.width) == floor(cropBoxFrame.size.height)) {
        frame.size.height = frame.size.width;
    } else {
        frame.size.height = ceilf(cropBoxFrame.size.height * scale);
        frame.size.height = MIN(imageSize.height, frame.size.height);
    }
    frame.size.height = MIN(imageSize.height, frame.size.height);
    
    return frame;
}

- (void)setImageCropFrame:(CGRect)imageCropFrame
{
    if (!self.initialSetupPerformed) {
        self.restoreImageCropFrame = imageCropFrame;
        return;
    }
    
    [self updateToImageCropFrame:imageCropFrame];
}

- (void)setCroppingViewsHidden:(BOOL)hidden
{
    [self setCroppingViewsHidden:hidden animated:NO];
}

- (void)setCroppingViewsHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (_croppingViewsHidden == hidden)
        return;
    
    _croppingViewsHidden = hidden;
    
    CGFloat alpha = hidden ? 0.0f : 1.0f;
    
    if (animated == NO) {
        self.backgroundImageView.alpha = alpha;
        self.foregroundContainerView.alpha = alpha;
        self.gridOverlayView.alpha = alpha;
        
        [self toggleTranslucencyViewVisible:!hidden];
        
        return;
    }
    
    self.foregroundContainerView.alpha = alpha;
    self.backgroundImageView.alpha = alpha;
    
    [UIView animateWithDuration:0.4f animations:^{
        [self toggleTranslucencyViewVisible:!hidden];
        self.gridOverlayView.alpha = alpha;
    }];
}

- (void)setBackgroundImageViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (animated == NO) {
        self.backgroundImageView.hidden = hidden;
        return;
    }
    
    CGFloat beforeAlpha = hidden ? 1.0f : 0.0f;
    CGFloat toAlpha = hidden ? 0.0f : 1.0f;
    
    self.backgroundImageView.hidden = NO;
    self.backgroundImageView.alpha = beforeAlpha;
    [UIView animateWithDuration:0.5f animations:^{
        self.backgroundImageView.alpha = toAlpha;
    }completion:^(BOOL complete) {
        if (hidden) {
            self.backgroundImageView.hidden = YES;
        }
    }];
}

- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden
{
    [self setGridOverlayHidden:_gridOverlayHidden animated:NO];
}

- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden animated:(BOOL)animated
{
    _gridOverlayHidden = gridOverlayHidden;
    self.gridOverlayView.alpha = gridOverlayHidden ? 1.0f : 0.0f;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.gridOverlayView.alpha = gridOverlayHidden ? 0.0f : 1.0f;
    }];
}

- (CGRect)imageViewFrame
{
    CGRect frame = CGRectZero;
    frame.origin.x = -self.scrollView.contentOffset.x;
    frame.origin.y = -self.scrollView.contentOffset.y;
    frame.size = self.scrollView.contentSize;
    return frame;
}

- (void)setCanBeReset:(BOOL)canReset
{
    if (canReset == _canBeReset) {
        return;
    }
    
    _canBeReset = canReset;
    
    if (canReset) {
        if ([self.delegate respondsToSelector:@selector(cropViewDidBecomeResettable:)])
            [self.delegate cropViewDidBecomeResettable:self];
    }
    else  {
        if ([self.delegate respondsToSelector:@selector(cropViewDidBecomeNonResettable:)])
            [self.delegate cropViewDidBecomeNonResettable:self];
    }
}

- (void)setAngle:(NSInteger)angle
{
    //The initial layout would not have been performed yet.
    //Save the value and it will be applied when it has
    NSInteger newAngle = angle;
    if (angle % 90 != 0) {
        newAngle = 0;
    }
    
    if (!self.initialSetupPerformed) {
        self.restoreAngle = newAngle;
        return;
    }
    
    // Negative values are allowed, so rotate clockwise or counter clockwise depending
    // on direction
    if (newAngle >= 0) {
        while (labs(self.angle) != labs(newAngle)) {
            [self rotateImageNinetyDegreesAnimated:NO clockwise:YES];
        }
    }
    else {
        while (-labs(self.angle) != -labs(newAngle)) {
            [self rotateImageNinetyDegreesAnimated:NO clockwise:NO];
        }
    }
}

#pragma mark - Editing Mode -
- (void)startEditing
{
    [self cancelResetTimer];
    [self setEditing:YES resetCropBox:NO animated:YES];
}

- (void)setEditing:(BOOL)editing resetCropBox:(BOOL)resetCropbox animated:(BOOL)animated
{
    if (editing == _editing)
        return;
    
    _editing = editing;
    
    [self.gridOverlayView setGridHidden:!editing animated:animated];
    
    if (resetCropbox) {
        [self moveCroppedContentToCenterAnimated:animated];
        [self captureStateForImageRotation];
        self.cropBoxLastEditedAngle = self.angle;
    }
    
    if (animated == NO) {
        [self toggleTranslucencyViewVisible:!editing];
        return;
    }
    
    CGFloat duration = editing ? 0.05f : 0.35f;
    CGFloat delay = editing? 0.0f : 0.35f;
    
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        [self toggleTranslucencyViewVisible:!editing];
    } completion:nil];
}

- (void)moveCroppedContentToCenterAnimated:(BOOL)animated
{
    if (self.internalLayoutDisabled)
        return;
    
    CGRect contentRect = self.contentBounds;
    CGRect cropFrame = self.cropBoxFrame;
    
    // Ensure we only proceed after the crop frame has been setup for the first time
    if (cropFrame.size.width < FLT_EPSILON || cropFrame.size.height < FLT_EPSILON) {
        return;
    }
    
    //The scale we need to scale up the crop box to fit full screen
    CGFloat scale = MIN(CGRectGetWidth(contentRect)/CGRectGetWidth(cropFrame), CGRectGetHeight(contentRect)/CGRectGetHeight(cropFrame));
    
    CGPoint focusPoint = (CGPoint){CGRectGetMidX(cropFrame), CGRectGetMidY(cropFrame)};
    CGPoint midPoint = (CGPoint){CGRectGetMidX(contentRect), CGRectGetMidY(contentRect)};
    
    cropFrame.size.width = ceilf(cropFrame.size.width * scale);
    cropFrame.size.height = ceilf(cropFrame.size.height * scale);
    cropFrame.origin.x = contentRect.origin.x + ceilf((contentRect.size.width - cropFrame.size.width) * 0.5f);
    cropFrame.origin.y = contentRect.origin.y + ceilf((contentRect.size.height - cropFrame.size.height) * 0.5f);
    
    //Work out the point on the scroll content that the focusPoint is aiming at
    CGPoint contentTargetPoint = CGPointZero;
    contentTargetPoint.x = ((focusPoint.x + self.scrollView.contentOffset.x) * scale);
    contentTargetPoint.y = ((focusPoint.y + self.scrollView.contentOffset.y) * scale);
    
    //Work out where the crop box is focusing, so we can re-align to center that point
    __block CGPoint offset = CGPointZero;
    offset.x = -midPoint.x + contentTargetPoint.x;
    offset.y = -midPoint.y + contentTargetPoint.y;
    
    //clamp the content so it doesn't create any seams around the grid
    offset.x = MAX(-cropFrame.origin.x, offset.x);
    offset.y = MAX(-cropFrame.origin.y, offset.y);
    
    __weak typeof(self) weakSelf = self;
    void (^translateBlock)(void) = ^{
        typeof(self) strongSelf = weakSelf;
        
        // Setting these scroll view properties will trigger
        // the foreground matching method via their delegates,
        // multiple times inside the same animation block, resulting
        // in glitchy animations.
        //
        // Disable matching for now, and explicitly update at the end.
        strongSelf.disableForgroundMatching = YES;
        {
            // Slight hack. This method needs to be called during `[UIViewController viewDidLayoutSubviews]`
            // in order for the crop view to resize itself during iPad split screen events.
            // On the first run, even though scale is exactly 1.0f, performing this multiplication introduces
            // a floating point noise that zooms the image in by about 5 pixels. This fixes that issue.
            if (scale < 1.0f - FLT_EPSILON || scale > 1.0f + FLT_EPSILON) {
                strongSelf.scrollView.zoomScale *= scale;
                strongSelf.scrollView.zoomScale = MIN(strongSelf.scrollView.maximumZoomScale, strongSelf.scrollView.zoomScale);
            }
            
            // If it turns out the zoom operation would have exceeded the minizum zoom scale, don't apply
            // the content offset
            if (strongSelf.scrollView.zoomScale < strongSelf.scrollView.maximumZoomScale - FLT_EPSILON) {
                offset.x = MIN(-CGRectGetMaxX(cropFrame)+strongSelf.scrollView.contentSize.width, offset.x);
                offset.y = MIN(-CGRectGetMaxY(cropFrame)+strongSelf.scrollView.contentSize.height, offset.y);
                strongSelf.scrollView.contentOffset = offset;
            }
            
            strongSelf.cropBoxFrame = cropFrame;
        }
        strongSelf.disableForgroundMatching = NO;
        
        //Explicitly update the matching at the end of the calculations
        [strongSelf matchForegroundToBackground];
    };
    
    if (!animated) {
        translateBlock();
        return;
    }
    
    [self matchForegroundToBackground];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:translateBlock
                         completion:nil];
    });
}

- (void)setSimpleRenderMode:(BOOL)simpleMode animated:(BOOL)animated
{
    if (simpleMode == _simpleRenderMode)
        return;
    
    _simpleRenderMode = simpleMode;
    
    self.editing = NO;
    
    if (animated == NO) {
        [self toggleTranslucencyViewVisible:!simpleMode];
        
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [self toggleTranslucencyViewVisible:!simpleMode];
    }];
}

- (void)setAspectRatio:(CGSize)aspectRatio
{
    [self setAspectRatio:aspectRatio animated:NO];
}

- (void)setAspectRatio:(CGSize)aspectRatio animated:(BOOL)animated
{
    _aspectRatio = aspectRatio;
    
    // Will be executed automatically when added to a super view
    if (!self.initialSetupPerformed) {
        return;
    }
    
    // Passing in an empty size will revert back to the image aspect ratio
    if (aspectRatio.width < FLT_EPSILON && aspectRatio.height < FLT_EPSILON) {
        aspectRatio = (CGSize){self.imageSize.width, self.imageSize.height};
    }
    
    CGRect boundsFrame = self.contentBounds;
    CGRect cropBoxFrame = self.cropBoxFrame;
    CGPoint offset = self.scrollView.contentOffset;
    
    BOOL cropBoxIsPortrait = NO;
    if ((NSInteger)aspectRatio.width == 1 && (NSInteger)aspectRatio.height == 1)
        cropBoxIsPortrait = self.image.size.width > self.image.size.height;
    else
        cropBoxIsPortrait = aspectRatio.width < aspectRatio.height;
    
    BOOL zoomOut = NO;
    if (cropBoxIsPortrait) {
        CGFloat newWidth = floorf(cropBoxFrame.size.height * (aspectRatio.width/aspectRatio.height));
        CGFloat delta = cropBoxFrame.size.width - newWidth;
        cropBoxFrame.size.width = newWidth;
        offset.x += (delta * 0.5f);
        
        if (delta < FLT_EPSILON) {
            cropBoxFrame.origin.x = self.contentBounds.origin.x; //set to 0 to avoid accidental clamping by the crop frame sanitizer
        }
        
        // If the aspect ratio causes the new width to extend
        // beyond the content width, we'll need to zoom the image out
        CGFloat boundsWidth = CGRectGetWidth(boundsFrame);
        if (newWidth > boundsWidth) {
            CGFloat scale = boundsWidth / newWidth;
            
            // Scale the new height
            CGFloat newHeight = cropBoxFrame.size.height * scale;
            delta = cropBoxFrame.size.height - newHeight;
            cropBoxFrame.size.height = newHeight;
            
            // Offset the Y position so it stays in the middle
            offset.y += (delta * 0.5f);
            
            // Clamp the width to the bounds width
            cropBoxFrame.size.width = boundsWidth;
            zoomOut = YES;
        }
    }
    else {
        CGFloat newHeight = floorf(cropBoxFrame.size.width * (aspectRatio.height/aspectRatio.width));
        CGFloat delta = cropBoxFrame.size.height - newHeight;
        cropBoxFrame.size.height = newHeight;
        offset.y += (delta * 0.5f);
        
        if (delta < FLT_EPSILON) {
            cropBoxFrame.origin.y = self.contentBounds.origin.y;
        }
        
        // If the aspect ratio causes the new height to extend
        // beyond the content width, we'll need to zoom the image out
        CGFloat boundsHeight = CGRectGetHeight(boundsFrame);
        if (newHeight > boundsHeight) {
            CGFloat scale = boundsHeight / newHeight;
            
            // Scale the new width
            CGFloat newWidth = cropBoxFrame.size.width * scale;
            delta = cropBoxFrame.size.width - newWidth;
            cropBoxFrame.size.width = newWidth;
            
            // Offset the Y position so it stays in the middle
            offset.x += (delta * 0.5f);
            
            // Clamp the width to the bounds height
            cropBoxFrame.size.height = boundsHeight;
            zoomOut = YES;
        }
    }
    
    self.cropBoxLastEditedSize = cropBoxFrame.size;
    self.cropBoxLastEditedAngle = self.angle;
    
    void (^translateBlock)(void) = ^{
        self.scrollView.contentOffset = offset;
        self.cropBoxFrame = cropBoxFrame;
        
        if (zoomOut) {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        }
        
        [self moveCroppedContentToCenterAnimated:NO];
        [self checkForCanReset];
    };
    
    if (animated == NO) {
        translateBlock();
        return;
    }
    
    [UIView animateWithDuration:0.5f
                          delay:0.0
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:translateBlock
                     completion:nil];
}

- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated
{
    [self rotateImageNinetyDegreesAnimated:animated clockwise:NO];
}

- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated clockwise:(BOOL)clockwise
{
    //Only allow one rotation animation at a time
    if (self.rotateAnimationInProgress)
        return;
    
    //Cancel any pending resizing timers
    if (self.resetTimer) {
        [self cancelResetTimer];
        [self setEditing:NO resetCropBox:YES animated:NO];
        
        self.cropBoxLastEditedAngle = self.angle;
        [self captureStateForImageRotation];
    }
    
    //Work out the new angle, and wrap around once we exceed 360s
    NSInteger newAngle = self.angle;
    newAngle = clockwise ? newAngle + 90 : newAngle - 90;
    if (newAngle <= -360 || newAngle >= 360) {
        newAngle = 0;
    }
    
    _angle = newAngle;
    
    //Convert the new angle to radians
    CGFloat angleInRadians = 0.0f;
    switch (newAngle) {
        case 90:    angleInRadians = M_PI_2;            break;
        case -90:   angleInRadians = -M_PI_2;           break;
        case 180:   angleInRadians = M_PI;              break;
        case -180:  angleInRadians = -M_PI;             break;
        case 270:   angleInRadians = (M_PI + M_PI_2);   break;
        case -270:  angleInRadians = -(M_PI + M_PI_2);  break;
        default:                                        break;
    }
    
    // Set up the transformation matrix for the rotation
    CGAffineTransform rotation = CGAffineTransformRotate(CGAffineTransformIdentity, angleInRadians);
    
    //Work out how much we'll need to scale everything to fit to the new rotation
    CGRect contentBounds = self.contentBounds;
    CGRect cropBoxFrame = self.cropBoxFrame;
    CGFloat scale = MIN(contentBounds.size.width / cropBoxFrame.size.height, contentBounds.size.height / cropBoxFrame.size.width);
    
    //Work out which section of the image we're currently focusing at
    CGPoint cropMidPoint = (CGPoint){CGRectGetMidX(cropBoxFrame), CGRectGetMidY(cropBoxFrame)};
    CGPoint cropTargetPoint = (CGPoint){cropMidPoint.x + self.scrollView.contentOffset.x, cropMidPoint.y + self.scrollView.contentOffset.y};
    
    //Work out the dimensions of the crop box when rotated
    CGRect newCropFrame = CGRectZero;
    if (labs(self.angle) == labs(self.cropBoxLastEditedAngle) || (labs(self.angle)*-1) == ((labs(self.cropBoxLastEditedAngle) - 180) % 360)) {
        newCropFrame.size = self.cropBoxLastEditedSize;
        
        self.scrollView.minimumZoomScale = self.cropBoxLastEditedMinZoomScale;
        self.scrollView.zoomScale = self.cropBoxLastEditedZoomScale;
    }
    else {
        newCropFrame.size = (CGSize){floorf(self.cropBoxFrame.size.height * scale), floorf(self.cropBoxFrame.size.width * scale)};
        
        //Re-adjust the scrolling dimensions of the scroll view to match the new size
        self.scrollView.minimumZoomScale *= scale;
        self.scrollView.zoomScale *= scale;
    }
    
    newCropFrame.origin.x = floorf(CGRectGetMidX(contentBounds) - (newCropFrame.size.width * 0.5f));
    newCropFrame.origin.y = floorf(CGRectGetMidY(contentBounds) - (newCropFrame.size.height * 0.5f));
    
    //If we're animated, generate a snapshot view that we'll animate in place of the real view
    UIView *snapshotView = nil;
    if (animated) {
        snapshotView = [self.foregroundContainerView snapshotViewAfterScreenUpdates:NO];
        self.rotateAnimationInProgress = YES;
    }
    
    //Rotate the background image view, inside its container view
    self.backgroundImageView.transform = rotation;
    
    //Flip the width/height of the container view so it matches the rotated image view's size
    CGSize containerSize = self.backgroundContainerView.frame.size;
    self.backgroundContainerView.frame = (CGRect){CGPointZero, {containerSize.height, containerSize.width}};
    self.backgroundImageView.frame = (CGRect){CGPointZero, self.backgroundImageView.frame.size};
    
    //Rotate the foreground image view to match
    self.foregroundContainerView.transform = CGAffineTransformIdentity;
    self.foregroundImageView.transform = rotation;
    
    //Flip the content size of the scroll view to match the rotated bounds
    self.scrollView.contentSize = self.backgroundContainerView.frame.size;
    
    //assign the new crop box frame and re-adjust the content to fill it
    self.cropBoxFrame = newCropFrame;
    [self moveCroppedContentToCenterAnimated:NO];
    newCropFrame = self.cropBoxFrame;
    
    //work out how to line up out point of interest into the middle of the crop box
    cropTargetPoint.x *= scale;
    cropTargetPoint.y *= scale;
    
    //swap the target dimensions to match a 90 degree rotation (clockwise or counterclockwise)
    CGFloat swap = cropTargetPoint.x;
    if (clockwise) {
        cropTargetPoint.x = self.scrollView.contentSize.width - cropTargetPoint.y;
        cropTargetPoint.y = swap;
    } else {
        cropTargetPoint.x = cropTargetPoint.y;
        cropTargetPoint.y = self.scrollView.contentSize.height - swap;
    }
    
    //reapply the translated scroll offset to the scroll view
    CGPoint midPoint = {CGRectGetMidX(newCropFrame), CGRectGetMidY(newCropFrame)};
    CGPoint offset = CGPointZero;
    offset.x = floorf(-midPoint.x + cropTargetPoint.x);
    offset.y = floorf(-midPoint.y + cropTargetPoint.y);
    offset.x = MAX(-self.scrollView.contentInset.left, offset.x);
    offset.y = MAX(-self.scrollView.contentInset.top, offset.y);
    offset.x = MIN(self.scrollView.contentSize.width - (newCropFrame.size.width - self.scrollView.contentInset.right), offset.x);
    offset.y = MIN(self.scrollView.contentSize.height - (newCropFrame.size.height - self.scrollView.contentInset.bottom), offset.y);
    
    //if the scroll view's new scale is 1 and the new offset is equal to the old, will not trigger the delegate 'scrollViewDidScroll:'
    //so we should call the method manually to update the foregroundImageView's frame
    if (offset.x == self.scrollView.contentOffset.x && offset.y == self.scrollView.contentOffset.y && scale == 1) {
        [self matchForegroundToBackground];
    }
    self.scrollView.contentOffset = offset;
    
    //If we're animated, play an animation of the snapshot view rotating,
    //then fade it out over the live content
    if (animated) {
        snapshotView.center = (CGPoint){CGRectGetMidX(contentBounds), CGRectGetMidY(contentBounds)};
        [self addSubview:snapshotView];
        
        self.backgroundContainerView.hidden = YES;
        self.foregroundContainerView.hidden = YES;
        self.translucencyView.hidden = YES;
        self.gridOverlayView.hidden = YES;
        
        [UIView animateWithDuration:0.45f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.8f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, clockwise ? M_PI_2 : -M_PI_2);
            transform = CGAffineTransformScale(transform, scale, scale);
            snapshotView.transform = transform;
        } completion:^(BOOL complete) {
            self.backgroundContainerView.hidden = NO;
            self.foregroundContainerView.hidden = NO;
            self.translucencyView.hidden = NO;
            self.gridOverlayView.hidden = NO;
            
            self.backgroundContainerView.alpha = 0.0f;
            self.gridOverlayView.alpha = 0.0f;
            
            self.translucencyView.alpha = 1.0f;
            
            [UIView animateWithDuration:0.45f animations:^{
                snapshotView.alpha = 0.0f;
                self.backgroundContainerView.alpha = 1.0f;
                self.gridOverlayView.alpha = 1.0f;
            } completion:^(BOOL complete) {
                self.rotateAnimationInProgress = NO;
                [snapshotView removeFromSuperview];
                
                // If the aspect ratio lock is not enabled, allow a swap
                // If the aspect ratio lock is on, allow a aspect ratio swap
                // only if the allowDimensionSwap option is specified.
                BOOL aspectRatioCanSwapDimensions = !self.aspectRatioLockEnabled ||
                (self.aspectRatioLockEnabled && self.aspectRatioLockDimensionSwapEnabled);
                
                if (!aspectRatioCanSwapDimensions) {
                    //This will animate the aspect ratio back to the desired locked ratio after the image is rotated.
                    [self setAspectRatio:self.aspectRatio animated:animated];
                }
            }];
        }];
    }
    
    [self checkForCanReset];
}

- (void)captureStateForImageRotation
{
    self.cropBoxLastEditedSize = self.cropBoxFrame.size;
    self.cropBoxLastEditedZoomScale = self.scrollView.zoomScale;
    self.cropBoxLastEditedMinZoomScale = self.scrollView.minimumZoomScale;
}

#pragma mark - Resettable State -
- (void)checkForCanReset
{
    BOOL canReset = NO;
    
    if (self.angle != 0) { //Image has been rotated
        canReset = YES;
    }
    else if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale + FLT_EPSILON) { //image has been zoomed in
        canReset = YES;
    }
    else if ((NSInteger)floorf(self.cropBoxFrame.size.width) != (NSInteger)floorf(self.originalCropBoxSize.width) ||
             (NSInteger)floorf(self.cropBoxFrame.size.height) != (NSInteger)floorf(self.originalCropBoxSize.height))
    { //crop box has been changed
        canReset = YES;
    }
    else if ((NSInteger)floorf(self.scrollView.contentOffset.x) != (NSInteger)floorf(self.originalContentOffset.x) ||
             (NSInteger)floorf(self.scrollView.contentOffset.y) != (NSInteger)floorf(self.originalContentOffset.y))
    {
        canReset = YES;
    }
    
    self.canBeReset = canReset;
}

#pragma mark - Convienience Methods -
- (CGRect)contentBounds
{
    CGRect contentRect = CGRectZero;
    contentRect.origin.x = self.cropViewPadding + self.cropRegionInsets.left;
    contentRect.origin.y = self.cropViewPadding + self.cropRegionInsets.top;
    contentRect.size.width = CGRectGetWidth(self.bounds) - ((self.cropViewPadding * 2) + self.cropRegionInsets.left + self.cropRegionInsets.right);
    contentRect.size.height = CGRectGetHeight(self.bounds) - ((self.cropViewPadding * 2) + self.cropRegionInsets.top + self.cropRegionInsets.bottom);
    return contentRect;
}

- (CGSize)imageSize
{
    if (self.angle == -90 || self.angle == -270 || self.angle == 90 || self.angle == 270)
        return (CGSize){self.image.size.height, self.image.size.width};
    
    return (CGSize){self.image.size.width, self.image.size.height};
}

- (BOOL)hasAspectRatio
{
    return (self.aspectRatio.width > FLT_EPSILON && self.aspectRatio.height > FLT_EPSILON);
}

@end
