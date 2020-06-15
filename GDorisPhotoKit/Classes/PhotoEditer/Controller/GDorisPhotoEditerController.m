//
//  GDorisPhotoEditerController.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/12/23.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisPhotoEditerController.h"
#import "GDorisPhotoHelper.h"
#import "GDorisEditerToolbar.h"
#import "GDorisEditerColorPanel.h"
#import "UIView+GDoris.h"
#import "UIImage+GDorisDraw.h"
#import "GDorisInputViewController.h"
#import "GDorisDragDropView.h"
#import "GDorisEditerHitTestView.h"
#import "Masonry.h"
#import "GDorisEditerCropController.h"
#import "GDorisDrawing.h"
#import "CIFilter+GDoris.h"
#import "GDorisFilterToolbar.h"
#import "GDorisEditerNavigationBar.h"
@interface GDorisPhotoEditerController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,GDorisCanvasViewDelegate,GDorisCanvasViewDatasource>
@property (nonatomic, strong) GDorisEditerNavigationBar * navigationBar;
@property (nonatomic, strong) GDorisEditerHitTestView * operationArea;
@property (nonatomic, strong) GDorisEditerToolbar * toolBar;
@property (nonatomic, strong) GDorisFilterToolbar * filterToolbar;
@property (nonatomic, strong) GDorisEditerColorPanel * colorPanel;
@property (nonatomic, strong) GDorisEditerMosaicPanel * mosaicPanel;
@property (nonatomic, strong) GDorisCanvasView * canvasView;
@property (nonatomic, strong) GDorisCanvasView * mosaicCanvasView;

@property (nonatomic, strong) UIScrollView * scrollerContainer;
@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;
@property (nonatomic, strong) NSMutableArray * dragViews;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) UIImage * originImage;

/// paint property
@property (nonatomic, strong) UIColor * paintColor;
@property (nonatomic, strong) UIImage * emojiImage;
@property (nonatomic, strong) NSDictionary * emojiConfig;
/// mosaic type 1003:blur 1002:mosaic
@property (nonatomic, assign) NSInteger  mosaicType;
@property (nonatomic, strong) UIColor * mosaicColor;
@property (nonatomic, strong) UIColor * blurColor;
/// filter items
@property (nonatomic, strong) NSArray * filterItems;
@end

@implementation GDorisPhotoEditerController

+ (instancetype)photoEditerWithImage:(UIImage *)image
{
    GDorisPhotoEditerController * editer = [[GDorisPhotoEditerController alloc] initWithImage:image];
    return editer;
}


- (instancetype)initWithImage:(nullable UIImage *)image
{
    self = [super init];
    if (self) {
        self.originImage = image;
        self.image = image;
        [self initializeMosaic];
        [self initializeFilterItems];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self doInitProperty];
    [self.view addSubview:({
        _scrollerContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollerContainer.delegate = self;
        _scrollerContainer.minimumZoomScale = 1;
        _scrollerContainer.maximumZoomScale = 2;
        _scrollerContainer;
    })];
    if (@available(iOS 11.0, *)) {
        _scrollerContainer.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.scrollerContainer addSubview:({
        _imageView = [UIImageView new];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        _imageView;
    })];
    self.imageView.image = self.image;
    [GDorisPhotoHelper fitImageSize:self.image.size containerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
        self.scrollerContainer.contentSize = scrollContentSize;
        self.imageView.frame = containerFrame;
    }];
    [self.view addSubview:({
        _operationArea = [GDorisEditerHitTestView new];
        _operationArea.frame = self.view.bounds;
        _operationArea.userInteractionEnabled = NO;
        _operationArea.backgroundColor = [UIColor clearColor];
        _operationArea;
    })];
    
    [self loadMaskView];
    [self loadNavigationbar];
    [self loadToolbar];
    [self loadPanGesture];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)doInitProperty
{
    self.paintColor = [self colorPanelColors].firstObject;
    self.mosaicType = 1002;
}

- (void)initializeMosaic
{
    __weak typeof(self) weakSelf = self;;
    [GDorisPhotoHelper fitImageSize:self.originImage.size containerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage * mosaicImage = [weakSelf.originImage mosaicLevel:20 size:containerFrame.size];
            UIColor * mosaicColor = [UIColor colorWithPatternImage:mosaicImage];
            UIImage * blurImage = [weakSelf.originImage blurLevel:20 size:containerFrame.size];
            UIColor * blurColor  = [UIColor colorWithPatternImage:blurImage];
            weakSelf.blurColor = blurColor;
            weakSelf.mosaicColor = mosaicColor;
        });
    }];
    
}

- (void)initializeFilterItems
{
    __weak typeof(self) weakSelf = self;;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray * filters = [NSMutableArray array];
        GDorisFilterItem * original = [GDorisFilterItem filterWithLookup:@"" title:@"原图"];
        original.selected = YES;
        [filters addObject:original];
        GDorisFilterItem * lollipop = [GDorisFilterItem filterWithLookup:@"Lookup_棒棒糖.png" title:@"棒棒糖"];
        [filters addObject:lollipop];
        GDorisFilterItem * pure = [GDorisFilterItem filterWithLookup:@"Lookup_纯真.png" title:@"纯真"];
        [filters addObject:pure];
        GDorisFilterItem * Retro = [GDorisFilterItem filterWithLookup:@"Lookup_复古黑.png" title:@"复古黑"];
        [filters addObject:Retro];
        GDorisFilterItem * film = [GDorisFilterItem filterWithLookup:@"Lookup_胶片.png" title:@"胶片"];
        [filters addObject:film];
        GDorisFilterItem * clear = [GDorisFilterItem filterWithLookup:@"Lookup_清晰.png" title:@"清晰"];
        [filters addObject:clear];
        GDorisFilterItem * Eden = [GDorisFilterItem filterWithLookup:@"Lookup_伊甸园.png" title:@"伊甸园"];
        [filters addObject:Eden];
        weakSelf.filterItems = filters.copy;
    });
}


- (void)loadPanGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapGesture.delegate = self;
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)loadMaskView
{
    [self.operationArea addSubview:({
        UIView * view = [UIView new];
        view.userInteractionEnabled = NO;
        view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = view.bounds;
        gradientLayer.colors = @[(__bridge id)GDorisColorA(4,0,18,0.26).CGColor,(__bridge id)GDorisColorA(4,0,18,0.01).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        [view.layer addSublayer:gradientLayer];
        view;
    })];
    [self.operationArea addSubview:({
        UIView * view = [UIView new];
        view.userInteractionEnabled = NO;
        view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-130, [UIScreen mainScreen].bounds.size.width, 130);
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = view.bounds;
        gradientLayer.colors = @[(__bridge id)GDorisColorA(4,0,18,0.26).CGColor,(__bridge id)GDorisColorA(4,0,18,0.01).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0);
        [view.layer addSublayer:gradientLayer];
        view;
    })];
}

- (void)loadNavigationbar
{
    self.navigationBar = [[GDorisEditerNavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GDorisNavBarHeight)];
    [self.operationArea addSubview:self.navigationBar];
    self.navigationBar.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    __weak typeof(self) weakSelf = self;
    self.navigationBar.closeAction = ^{
        [weakSelf cancel];
    };
    self.navigationBar.confirmAction = ^{
        [weakSelf done];
    };
}

- (void)loadToolbar
{
    self.toolBar = [[GDorisEditerToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-24-GDoris_TabBarMargin, [UIScreen mainScreen].bounds.size.width, 24)];
    self.toolBar.backgroundColor = UIColor.redColor;
    self.toolBar.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    __weak typeof(self) weakSelf = self;
    self.toolBar.editToolbarClickBlock = ^(DorisEditerToolbarItemType itemType,UIButton * sender) {
        [weakSelf editToolbarClick:itemType button:sender];
    };
    [self.operationArea addSubview:self.toolBar];
}

#pragma mark - private Method

#pragma mark - action Method

- (void)done
{
    UIImage * image = [self snapshotImage];
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoEditer:editerImage:originImage:)]) {
        [self.delegate photoEditer:self editerImage:image originImage:self.originImage];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)editToolbarClick:(DorisEditerToolbarItemType)itemType button:(UIButton *)sender
{
    [self.toolBar resetToolbarSelectState];
    switch (itemType) {
        case DorisEditerToolbarItemDraw:
        {
            [self.toolBar setToolbarSelected:!sender.selected itemType:DorisEditerToolbarItemDraw];
            [self drawPhoto:sender.selected];
        }
            break;
        case DorisEditerToolbarItemMosaic:
        {
            [self.toolBar setToolbarSelected:!sender.selected itemType:DorisEditerToolbarItemMosaic];
            [self drawMosaic:sender.selected];
        }
            break;
        case DorisEditerToolbarItemCrop:
        {
            [self cropPhoto];
        }
            break;
        case DorisEditerToolbarItemText:
        {
            [self textPhoto];
        }
            break;
        case DorisEditerToolbarItemEmjio:
        {
            [self emojiPhoto];
        }
            break;
        case DorisEditerToolbarItemFilter:
        {
            [self filterPhoto];
        }
        default:
            break;
    }
}

- (void)bringSubviewToFront
{
    [self.view bringSubviewToFront:self.operationArea];
}

- (void)drawActionState:(DorisCanvasDrawState)state
{
    switch (state) {
        case DorisCanvasDrawStateBegin:
        {
            self.scrollerContainer.scrollEnabled = NO;
        }
            break;
        case DorisCanvasDrawStateMove:
        {
            [self operaAreaHidden:YES anmiated:YES];
        }
            break;
        case DorisCanvasDrawStateEnd:
        case DorisCanvasDrawStateCancel:
        {
            [self operaAreaHidden:NO anmiated:YES];
            self.scrollerContainer.scrollEnabled = YES;
        }
            break;
        default:
            break;
    }
}

- (void)operaAreaHidden:(BOOL)hidden anmiated:(BOOL)anmiated
{
    if (anmiated) {
        [UIView animateWithDuration:0.15 animations:^{
            self.operationArea.alpha = hidden ? 0 : 1;
        } completion:^(BOOL finished) {
            self.operationArea.hidden = hidden;
        }];
    } else {
        self.operationArea.hidden = hidden;
    }
    self.toolBar.hidden = hidden;
}

- (void)textInputDone:(YYLabel *)label
{
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    GDorisDragDropView * dragView = [[GDorisDragDropView alloc] initWithContentView:label];
    CGPoint  point = self.imageView.center;
    CGPoint realPoint = [self.imageView.superview convertPoint:point toView:self.imageView];
    dragView.center = realPoint;
    [self.imageView addSubview:dragView];
    [self.dragViews addObject:dragView];
}

- (void)textInputDoneWithTextLayout:(YYTextLayout *)textLayout
{
    YYLabel * label = [YYLabel new];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.textLayout = textLayout;
    label.g_size = textLayout.textBoundingSize;
    GDorisDragDropView * dragView = [[GDorisDragDropView alloc] initWithContentView:label];
    dragView.scaleEnable = NO;
    CGPoint  point = self.imageView.center;
    CGPoint realPoint = [self.imageView.superview convertPoint:point toView:self.imageView];
    dragView.center = realPoint;
    dragView.editEnabled = YES;
    [self.imageView addSubview:dragView];
    [self.dragViews addObject:dragView];
}


- (void)bringDragViewToFront
{
    __weak typeof(self) weakSelf = self;
    [self.dragViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf.imageView bringSubviewToFront:obj];
    }];
}

- (UIImage *)snapshotImage
{
    [self.dragViews enumerateObjectsUsingBlock:^(GDorisDragDropView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.editEnabled = NO;
    }];
    return [self.imageView g_snapshotImage];
}

- (void)editerCropImage:(UIImage *)cropImage
{
    self.image = cropImage;
    self.originImage = cropImage;
    self.imageView.image = self.image;
    [GDorisPhotoHelper fitImageSize:self.image.size containerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
        self.scrollerContainer.contentSize = scrollContentSize;
        self.imageView.frame = containerFrame;
    }];
    [self.dragViews removeAllObjects];
    [self.canvasView resetAllMask];
    [self.mosaicCanvasView resetAllMask];
    [self.imageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:GDorisDragDropView.class]) {
            [obj removeFromSuperview];
        }
    }];
}

#pragma mark - Gesture Method

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
{

    [self operaAreaHidden:!self.operationArea.hidden anmiated:NO];
}

#pragma mark - Edit Toolbar Action

- (void)resetEditToolbarState
{
    [self.toolBar resetToolbarSelectState];
    self.canvasView.userInteractionEnabled = NO;
    self.mosaicCanvasView.userInteractionEnabled = NO;
    self.colorPanel.hidden = YES;
    self.mosaicPanel.hidden = YES;
    self.filterToolbar.hidden = YES;
}

- (void)drawPhoto:(BOOL)selected
{
    [self resetEditToolbarState];
    self.mosaicPanel.hidden = YES;
    self.colorPanel.hidden = !selected;
    self.mosaicCanvasView.hidden = NO;
    self.canvasView.hidden = NO;
    self.canvasView.userInteractionEnabled = selected;
    self.mosaicCanvasView.userInteractionEnabled = NO;
    [self bringDragViewToFront];
}

- (void)drawMosaic:(BOOL)selected
{
    [self resetEditToolbarState];
    self.colorPanel.hidden = YES;
    self.mosaicCanvasView.hidden = NO;
    self.canvasView.hidden = NO;
    self.mosaicPanel.hidden = !selected;
    self.canvasView.userInteractionEnabled = NO;
    self.mosaicCanvasView.userInteractionEnabled = selected;
    [self bringDragViewToFront];
}

- (void)didSelectDrawColor:(id)color
{
    if (color && [color isKindOfClass:UIColor.class]) {
        self.paintColor = color;
        self.emojiImage = nil;
    } else if (color && [color isKindOfClass:NSString.class]) {
        self.paintColor = nil;
        if (self.emojiConfig && [self.emojiConfig objectForKey:color]) {
            self.emojiImage = [self.emojiConfig objectForKey:color];
        } else {
            self.emojiImage = [self generateEmojiImage:color];
        }
    }
}

- (UIImage *)generateEmojiImage:(NSString*)emoji
{
    CGSize fontsize = CGSizeMake(20, 20);// [emoji calculateSizeWithFont:[UIFont systemFontOfSize:12] maximumWidth:100];
    
    UIGraphicsBeginImageContextWithOptions(fontsize, false, 0);
    [UIColor.clearColor set];
    CGRect rect = CGRectMake(0, 0, fontsize.width, fontsize.height);
    UIRectFill(rect);
    [emoji drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (image) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObject:image forKey:emoji];
        [dict setDictionary:self.emojiConfig?:@{}];
    }
    return image;
}

- (void)revokeDrawAction
{
    [self.canvasView revokeLastMask];
    [self.colorPanel setRevokeEnabled:[self.canvasView canRevoke]];
}

- (void)revokeMosaicAction
{
    [self.mosaicCanvasView revokeLastMask];
    [self.mosaicPanel setRevokeEnabled:[self.mosaicCanvasView canRevoke]];
}


- (void)cropPhoto
{
    [self resetEditToolbarState];
    UIImage * image = [self snapshotImage];
    GDorisEditerCropController * cropVC = [[GDorisEditerCropController alloc] initWithImage:image];
    __weak typeof(self) weakSelf = self;
    cropVC.doirsEditerCropImageAction = ^(UIImage * _Nonnull cropImage) {
        [weakSelf editerCropImage:cropImage];
    };
    [self presentViewController:cropVC animated:NO completion:^{
        
    }];
}


- (void)textPhoto
{
    [self resetEditToolbarState];
    [self operaAreaHidden:YES anmiated:NO];
    GDorisInputViewController * inputVC = [[GDorisInputViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    inputVC.generateTextLabelAction = ^(YYLabel * _Nonnull label) {
        [weakSelf textInputDone:label];
    };
    inputVC.generateTextLayoutAction = ^(YYTextLayout * _Nonnull textLayout) {
        [weakSelf textInputDoneWithTextLayout:textLayout];
        [weakSelf operaAreaHidden:NO anmiated:NO];
    };
    [self presentViewController:inputVC animated:YES completion:nil];
}

- (void)emojiPhoto
{
    [self resetEditToolbarState];
    [self operaAreaHidden:YES anmiated:NO];

}

- (void)hiddenEmojiPanel
{

}

- (void)filterPhoto
{
    [self resetEditToolbarState];
    [self.filterToolbar configureWithItems:self.filterItems];
    self.filterToolbar.hidden = NO;
}

- (void)filterImageWithLookup:(NSString *)lookup
{
    if (lookup.length > 0) {
        CIFilter *colorCube = [CIFilter colorCubeWithLUTImageNamed:lookup dimension:64];
        CIImage *inputImage = [[CIImage alloc] initWithImage:self.originImage];
        [colorCube setValue:inputImage forKey:@"inputImage"];
        CIImage *outputImage = [colorCube outputImage];
        
        CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:(__bridge id)(CGColorSpaceCreateDeviceRGB()) forKey:kCIContextWorkingColorSpace]];
        UIImage *newImage = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
        self.image = newImage;
        self.imageView.image = newImage;
    } else {
        self.image = self.originImage;
        self.imageView.image = self.originImage;
    }
    
}

#pragma mark - layz load

- (GDorisCanvasView *)canvasView
{
    if (!_canvasView) {
        CGRect rect = self.imageView.bounds;
        _canvasView = [[GDorisCanvasView alloc] init];
        _canvasView.frame = rect;
        _canvasView.hidden = YES;
        _canvasView.delegate = self;
        _canvasView.dataSource = self;
        [self.imageView addSubview:_canvasView];
        [self bringSubviewToFront];
    }
    return _canvasView;
}

- (GDorisCanvasView *)mosaicCanvasView
{
    if (!_mosaicCanvasView) {
        _mosaicCanvasView = [[GDorisCanvasView alloc] init];
        CGRect rect = self.imageView.bounds;
        _mosaicCanvasView.frame = rect;
        _mosaicCanvasView.hidden = YES;
        _mosaicCanvasView.delegate = self;
        _mosaicCanvasView.dataSource = self;
        [self.imageView addSubview:_mosaicCanvasView];
        [self bringSubviewToFront];
    }
    return _mosaicCanvasView;
}

- (GDorisEditerColorPanel *)colorPanel
{
    if (!_colorPanel) {
        _colorPanel = [[GDorisEditerColorPanel alloc] initWithFrame:CGRectMake(0, self.toolBar.g_top-63, [UIScreen mainScreen].bounds.size.width, 63)];
        _colorPanel.hidden = YES;
        [_colorPanel configColors:[self colorPanelColors]];
        [_colorPanel setRevokeEnabled:NO];
        [self.operationArea addSubview:_colorPanel];
        __weak typeof(self) weakSelf = self;
        _colorPanel.revokeActionBlock = ^{
            [weakSelf revokeDrawAction];
        };
        _colorPanel.colorDidSelectBlock = ^(id  _Nonnull color) {
            [weakSelf didSelectDrawColor:color];
        };
    }
    return _colorPanel;
}

- (NSArray *)colorPanelColors
{
    return @[GDorisColor(250, 250, 250),
             GDorisColor(43, 43, 43),
             @"😁",@"👍",@"🤣",
             GDorisColor(255, 29, 19),
             GDorisColor(251, 245, 7),
             GDorisColor(21, 225, 19),
             GDorisColor(251, 55, 254),
             GDorisColor(140, 6, 255),
             @"😴",@"🤧",@"🤮"];
}

- (GDorisEditerMosaicPanel *)mosaicPanel
{
    if (!_mosaicPanel) {
        _mosaicPanel = [[GDorisEditerMosaicPanel alloc] initWithFrame:CGRectMake(0, self.toolBar.g_top-63, [UIScreen mainScreen].bounds.size.width, 63)];
        _mosaicPanel.hidden = YES;
        [self.operationArea addSubview:_mosaicPanel];
        __weak typeof(self) weakSelf = self;
        _mosaicPanel.mosaicDidSelectBlock = ^(NSInteger type) {
            weakSelf.mosaicType = type;
        };
        _mosaicPanel.revokeActionBlock = ^{
            [weakSelf revokeMosaicAction];
        };
    }
    return _mosaicPanel;
}

- (GDorisFilterToolbar *)filterToolbar
{
    if (!_filterToolbar) {
        _filterToolbar = [[GDorisFilterToolbar alloc] init];
        [self.view addSubview:_filterToolbar];
        [self bringSubviewToFront];
        _filterToolbar.frame = CGRectMake(0, self.toolBar.g_top-83, [UIScreen mainScreen].bounds.size.width, 63+20);
        _filterToolbar.hidden = YES;
        __weak typeof(self) weakSelf = self;;
        _filterToolbar.filterAction = ^(GDorisFilterItem * _Nonnull item) {
            [weakSelf filterImageWithLookup:item.lookup_img];
        };
    }
    [self.view bringSubviewToFront:_filterToolbar];
    return _filterToolbar;
}

- (NSArray *)dragViews
{
    if (!_dragViews) {
        _dragViews = [[NSMutableArray alloc] init];
    }
    return _dragViews;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self containerViewDidZoom:scrollView];
}

- (void)containerViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    UIView * container = self.imageView;
    container.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - GDorisCanvasViewDelegate,GDorisCanvasViewDatasource

- (id<GDorisMark>)generateCanvasMark:(GDorisCanvasView *)canvasView
{
    if (canvasView == self.canvasView) {
        if (self.paintColor) {
            GDorisCurve * curve = [GDorisCurve new];
            curve.lineWidth = 10;
            curve.strokeColor = self.paintColor;
            return curve;
        } else {
            GDorisSticker * sticker = [GDorisSticker new];
            sticker.lineWidth = 20;
            sticker.stickers = @[self.emojiImage];
            return sticker;
        }
    } else if (canvasView == self.mosaicCanvasView) {
        GDorisMosaic * mosaic = [GDorisMosaic new];
        if (self.mosaicType == 1002) {
            mosaic.strokeColor = self.mosaicColor;
        } else {
            mosaic.strokeColor = self.blurColor;
        }
        mosaic.lineWidth = 30;
        return mosaic;
    }
    return nil;
}

- (void)dorisCanvasView:(GDorisCanvasView *)canvasView drawActionState:(DorisCanvasDrawState)state
{
    [self drawActionState:state];
    if (canvasView == self.canvasView) {
        if (state == DorisCanvasDrawStateEnd) {
            [self.colorPanel setRevokeEnabled:YES];
        }
    } else if (canvasView == self.mosaicCanvasView) {
        if (state == DorisCanvasDrawStateEnd) {
            [self.mosaicPanel setRevokeEnabled:YES];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    CGRect rect = self.colorPanel.hidden ? CGRectZero : self.colorPanel.frame;
    if (self.operationArea.hidden) {
        rect = CGRectZero;
    }

    if (!self.filterToolbar.hidden) {
        rect = CGRectMake(0, self.filterToolbar.g_top, self.filterToolbar.g_width, [UIScreen mainScreen].bounds.size.height-self.filterToolbar.g_top);
    }
    BOOL contains = CGRectContainsPoint(rect, point);
//    NSLog(@"gestureRecognizerShouldBegin-%ld",contains);
    return !contains;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark - helper

- (CGFloat)calculateHeight:(NSString *)string WithFont:(UIFont *)font constantWidth:(CGFloat)width
{
    CGSize size;
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.height;
}

@end
