//
//  GDorisDragDropView.m
//  GDoris
//
//  Created by GIKI on 2018/9/16.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisDragDropView.h"

CG_INLINE CGPoint Doris_CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect Doris_CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale) {
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * wScale, rect.size.height * hScale);
}

CG_INLINE CGFloat Doris_CGAffineTransformGetAngle(CGAffineTransform t) {
    return atan2(t.b, t.a);
}

CG_INLINE CGFloat Doris_CGPointGetDistance(CGPoint point1, CGPoint point2) {
    CGFloat fx = (point2.x - point1.x);
    CGFloat fy = (point2.y - point1.y);
    return sqrt((fx * fx + fy * fy));
}

@interface GDorisDragDropView()<UIGestureRecognizerDelegate> {
    
    NSInteger defaultInset;
    NSInteger defaultMinimumSize;
    
    CGPoint beginningPoint;
    CGPoint beginningCenter;
    
    CGRect initialBounds;
    CGFloat initialDistance;
    CGFloat deltaAngle;
}
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, strong) UIImageView *rotateImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *rotateGesture;
@property (nonatomic, strong) UIImageView *closeImageView;
@property (nonatomic, strong) UITapGestureRecognizer *closeGesture;
@property (nonatomic, strong) UIImageView *flipImageView;
@property (nonatomic, strong) UITapGestureRecognizer *flipGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL  isEditing;

@end

@implementation GDorisDragDropView

- (instancetype)initWithContentView:(__kindof UIView *)contentView
{
    if (!contentView) return nil;
    defaultInset = 11;
    defaultMinimumSize = 4 * defaultInset;
    
    CGRect frame = contentView.frame;
    frame = CGRectMake(0, 0, frame.size.width + defaultInset * 2, frame.size.height + defaultInset * 2);
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:self.tapGesture];
        
        // Setup content view
        self.contentView = contentView;
        self.contentView.center = Doris_CGRectGetCenter(self.bounds);
        self.contentView.userInteractionEnabled = NO;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if ([self.contentView.layer respondsToSelector:@selector(setAllowsEdgeAntialiasing:)]) {
            [self.contentView.layer setAllowsEdgeAntialiasing:YES];
        }
        [self addSubview:self.contentView];
        [self addSubview:self.closeImageView];
        [self addSubview:self.rotateImageView];
        [self addSubview:self.flipImageView];
        
        self.minimumSize = defaultMinimumSize;
        self.outlineBorderColor = [UIColor whiteColor];
        self.autoHideBorderDuration = 1.5;
        self.scaleEnable = YES;
        self.rotateEnable = YES;
        [self setDragEnabled:YES];
        [self setEditEnabled:NO];
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenEditerBorder) object:nil];
}

- (void)setDragEnabled:(BOOL)dragEnabled
{
    _dragEnabled = dragEnabled;
    if (dragEnabled) {
        [self removeMovelGesture];
        [self addGestureRecognizer:self.moveGesture];
    } else {
        [self removeMovelGesture];
    }
}

- (void)removeMovelGesture
{
    if (self.moveGesture && [self.gestureRecognizers containsObject:self.moveGesture]) {
        [self removeGestureRecognizer:self.moveGesture];
        self.moveGesture = nil;
    }
}

- (void)setEditEnabled:(BOOL)editEnabled
{
    _editEnabled = editEnabled;
    [self showEditBorder:editEnabled];
}

- (void)setOutlineBorderColor:(UIColor *)outlineBorderColor
{
    _outlineBorderColor = outlineBorderColor;
    self.contentView.layer.borderColor = outlineBorderColor.CGColor;
}

- (void)showEditBorder:(BOOL)show
{
    if (self.editEnabled && show) {
        self.closeImageView.hidden = NO;
        self.flipImageView.hidden = NO;
        self.rotateImageView.hidden = NO;
        self.contentView.layer.borderWidth = 1;
        [self startAutoHiddenEditer];
    } else {
        self.closeImageView.hidden = YES;
        self.flipImageView.hidden = YES;
        self.rotateImageView.hidden = YES;
        self.contentView.layer.borderWidth = 0;
    }
}

- (void)startAutoHiddenEditer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenEditerBorder) object:nil];
    [self performSelector:@selector(hiddenEditerBorder) withObject:nil afterDelay:self.autoHideBorderDuration];
}

- (void)hiddenEditerBorder
{
    [self showEditBorder:NO];
}
#pragma mark - getter Method

- (UIPanGestureRecognizer *)moveGesture {
    if (!_moveGesture) {
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
    }
    return _moveGesture;
}

- (UIPanGestureRecognizer *)rotateGesture {
    if (!_rotateGesture) {
        _rotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
        _rotateGesture.delegate = self;
    }
    return _rotateGesture;
}

- (UITapGestureRecognizer *)closeGesture {
    if (!_closeGesture) {
        _closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseGesture:)];
        _closeGesture.delegate = self;
    }
    return _closeGesture;
}

- (UITapGestureRecognizer *)flipGesture {
    if (!_flipGesture) {
        _flipGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFlipGesture:)];
        _flipGesture.delegate = self;
    }
    return _flipGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    }
    return _tapGesture;
}

- (UIImageView *)closeImageView {
    if (!_closeImageView) {
        _closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, defaultInset * 2, defaultInset * 2)];
        _closeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _closeImageView.backgroundColor = [UIColor clearColor];
        _closeImageView.userInteractionEnabled = YES;
        _closeImageView.image = [UIImage imageNamed:@"GDoris_Edit_Close"];
        [_closeImageView addGestureRecognizer:self.closeGesture];
        CGPoint origin = self.contentView.frame.origin;
        _closeImageView.center = origin;
        _closeImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _closeImageView;
}

- (UIImageView *)rotateImageView {
    if (!_rotateImageView) {
        _rotateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, defaultInset * 2, defaultInset * 2)];
        _rotateImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rotateImageView.backgroundColor = [UIColor clearColor];
        _rotateImageView.userInteractionEnabled = YES;
        [_rotateImageView addGestureRecognizer:self.rotateGesture];
        _rotateImageView.image = [UIImage imageNamed:@"GDoris_PhotoEdit_drag_ic"];
        CGPoint origin = self.contentView.frame.origin;
        CGSize size = self.contentView.frame.size;
        _rotateImageView.center = CGPointMake(origin.x + size.width, origin.y + size.height);
        _rotateImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _rotateImageView;
}

- (UIImageView *)flipImageView {
    if (!_flipImageView) {
        _flipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, defaultInset * 2, defaultInset * 2)];
        _flipImageView.contentMode = UIViewContentModeScaleAspectFit;
        _flipImageView.backgroundColor = [UIColor clearColor];
        _flipImageView.userInteractionEnabled = YES;
        [_flipImageView addGestureRecognizer:self.flipGesture];
        _flipImageView.image = [UIImage imageNamed:@"GDoris_Edit_Filp"];
        CGPoint origin = self.contentView.frame.origin;
        CGSize size = self.contentView.frame.size;
        _flipImageView.center = CGPointMake(origin.x + size.width, origin.y);
        _flipImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _flipImageView;
}

#pragma mark - Gesture Method

- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer
{
    [self startAutoHiddenEditer];
    if (self.dragBounces || self.dragAdsorption) {
        [self handleMoveBouncesGesture:recognizer];
    } else {
        [self handleMoveNormalGesture:recognizer];
    }
}

- (void)handleMoveNormalGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint touchLocation = [recognizer locationInView:self.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            beginningPoint = touchLocation;
            beginningCenter = self.center;
            break;
            
        case UIGestureRecognizerStateChanged:
            self.center = CGPointMake(beginningCenter.x + (touchLocation.x - beginningPoint.x),
                                      beginningCenter.y + (touchLocation.y - beginningPoint.y));
            break;
            
        case UIGestureRecognizerStateEnded:
            self.isEditing = NO;
            self.center = CGPointMake(beginningCenter.x + (touchLocation.x - beginningPoint.x),
                                      beginningCenter.y + (touchLocation.y - beginningPoint.y));
            
            break;
            
        default:
            break;
    }
}

- (void)handleMoveBouncesGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translatedPoint = [gestureRecognizer translationInView:self];
    CGFloat x = gestureRecognizer.view.center.x + translatedPoint.x;
    CGFloat y = gestureRecognizer.view.center.y + translatedPoint.y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            [[self superview] bringSubviewToFront:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            if (!self.dragBounces) {
                if (x < self.frame.size.width / 2) {
                    x = self.frame.size.width / 2;
                } else if (x > self.superview.frame.size.width - self.frame.size.width / 2) {
                    x = self.superview.frame.size.width - self.frame.size.width / 2;
                }
                if (y < self.frame.size.height / 2) {
                    y = self.frame.size.width / 2;
                } else if (y > self.superview.frame.size.height - self.frame.size.height / 2){
                    y = self.superview.frame.size.height - self.frame.size.height / 2;
                }
            }
            gestureRecognizer.view.center = CGPointMake(x, y);
            break;
        }
        case UIGestureRecognizerStateEnded:{
            
            if (y < self.frame.size.height / 2) {
                y = self.frame.size.width / 2;
            } else if (y > self.superview.frame.size.height - self.frame.size.height / 2){
                y = self.superview.frame.size.height - self.frame.size.height / 2;
            }
            
            if (!self.dragAdsorption) {
                UIView * superview = self.superview;
                if (superview.superview) {
                    superview = superview.superview;
                }
                CGRect convertRect = [gestureRecognizer.view.superview convertRect:gestureRecognizer.view.frame toView:superview];
                if (convertRect.origin.x < self.superview.frame.origin.x) {
                    x =  gestureRecognizer.view.frame.size.width / 2;
                } else if (convertRect.origin.x + gestureRecognizer.view.frame.size.width > self.superview.frame.origin.x+self.superview.frame.size.width ){
                    x = self.superview.frame.size.width - gestureRecognizer.view.frame.size.width / 2;
                }
                [UIView animateWithDuration:0.25 animations:^{
                    gestureRecognizer.view.center = CGPointMake(x, y);
                }];
                
            }else{
                UIView * superview = self.superview;
                if (superview.superview) {
                    superview = superview.superview;
                }
                CGRect convertRect = [gestureRecognizer.view.superview convertRect:gestureRecognizer.view.frame toView:superview];
                if (Doris_CGRectGetCenter(convertRect).x > self.superview.center.x) {
                    [UIView animateWithDuration:0.25 animations:^{
                        gestureRecognizer.view.center = CGPointMake(self.superview.frame.size.width - self.frame.size.width / 2-self.adsorptionDistance, y);
                    }];
                } else {
                    [UIView animateWithDuration:0.25 animations:^{
                        gestureRecognizer.view.center = CGPointMake(self.frame.size.width / 2+self.adsorptionDistance, y);
                    }];
                }
            }
            
            [self.superview bringSubviewToFront:self];
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            break;
        }
        case UIGestureRecognizerStateFailed:{
            break;
        }
        default:
            break;
    }
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)handleRotateGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint touchLocation = [recognizer locationInView:self.superview];
    CGPoint center = self.center;
    [self startAutoHiddenEditer];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            deltaAngle = atan2f(touchLocation.y - center.y, touchLocation.x - center.x) - Doris_CGAffineTransformGetAngle(self.transform);
            initialBounds = self.bounds;
            initialDistance = Doris_CGPointGetDistance(center, touchLocation);
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            if (self.rotateEnable) {
                float angle = atan2f(touchLocation.y - center.y, touchLocation.x - center.x);
                float angleDiff = deltaAngle - angle;
                self.transform = CGAffineTransformMakeRotation(-angleDiff);
            }
            
            if (self.scaleEnable) {
                CGFloat scale = Doris_CGPointGetDistance(center, touchLocation) / initialDistance;
                CGFloat minimumScale = self.minimumSize / MIN(initialBounds.size.width, initialBounds.size.height);
                scale = MAX(scale, minimumScale);
                CGRect scaledBounds = Doris_CGRectScale(initialBounds, scale, scale);
                self.bounds = scaledBounds;
                [self setNeedsDisplay];
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            self.isEditing = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)handleCloseGesture:(UITapGestureRecognizer *)recognizer
{
    [self removeFromSuperview];
}

- (void)handleFlipGesture:(UITapGestureRecognizer *)recognizer
{
    [self startAutoHiddenEditer];
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.transform = CGAffineTransformScale(self.contentView.transform, -1, 1);
    } completion:^(BOOL finished) {
        self.isEditing = NO;
    }];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.editEnabled) {
        [self showEditBorder:YES];
    }
    [self startAutoHiddenEditer];
}

- (BOOL)hasIntersects
{
    BOOL tf = NO;
    for (UIView *view in self.superview.subviews) {
        if (view == self) continue;
        if ([self intersectsWithView:view]) {
            tf = YES;
        }
    }
    return tf;
}

- (BOOL)intersectsWithView:(UIView *)view
{
    CGRect selfRect = [self convertRect:self.bounds toView:nil];
    CGRect viewRect = [view convertRect:view.bounds toView:nil];
    return CGRectIntersectsRect(selfRect, viewRect);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
