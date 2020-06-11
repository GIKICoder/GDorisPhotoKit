//
//  GDorisSwipeGestureTransition.m
//  XCChat
//
//  Created by GIKI on 2020/3/27.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisSwipeGestureTransition.h"
#import <objc/runtime.h>

static int64_t kSwipeGestureMaskViewKey = -8991034;
typedef NS_ENUM(NSUInteger, ContainerMoveType) {
    ContainerMoveTypeTop = 0,
    ContainerMoveTypeBottom,
};
CGFloat const kDorisGestureMinimumTranslation = 20.0 ;

typedef enum : NSInteger {
    kDorisMoveDirectionNone,
    kDorisMoveDirectionUp,
    kDorisMoveDirectionDown,
    kDorisMoveDirectionRight,
    kDorisMoveDirectionLeft
} DorisMoveDirection;

#ifndef GDORIS_OPTIONS_CONTAINS
#define GDORIS_OPTIONS_CONTAINS(options, value) (((options) & (value)) == (value))
#endif

@interface GDorisSwipeGestureTransition ()
@property (nonatomic, assign) BOOL  isPresenting;
@property (nonatomic, weak  ) UIViewController<GDorisSwipeGestureTargetAdpter> * weakController;
@property (nonatomic, weak  ) UIView  * targetView;
@property (nonatomic, weak  ) UIScrollView  * scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;
/// record targetView position
@property (nonatomic, assign) CGFloat  recordTargetPositionY;
@property (nonatomic, assign) CGFloat  recordTargetPositionX;
/// when scrollview scrolling, record scrollview position
@property (nonatomic, assign) CGFloat startScrollPosition;
@property (nonatomic, assign) BOOL onceEnded;
@property (nonatomic, assign) BOOL scrollBegin;
@property (nonatomic) ContainerMoveType containerPosition;
@property (nonatomic, assign) DorisMoveDirection direction;;
@end

@implementation GDorisSwipeGestureTransition

+ (instancetype)swipeGestureTransitionWithTarget:(UIViewController<GDorisSwipeGestureTargetAdpter> *)controller
{
    GDorisSwipeGestureTransition * transition = [[GDorisSwipeGestureTransition alloc] initWithTargetController:controller];
    return transition;
}

- (instancetype)initWithTargetController:(UIViewController<GDorisSwipeGestureTargetAdpter> *)controller
{
    if (self = [super init]) {
        self.weakController = controller;
        controller.dorisSwipeTransition = self;
        self.transtionDuration = 0.325;
        self.containerCorners = 10;
        self.swipeGestureEnabled = YES;
        self.containerOffset = 0;
        self.dismissDistance = [UIScreen mainScreen].bounds.size.height*0.5-30;
        self.swipeOptions = GDorisSwipeGestureVertical | GDorisSwipeGestureHorizontal;
    }
    return self;
}

- (void)addMoreMasklayer:(UIView *)view andUIRectCorner:(UIRectCorner)corner
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: view.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(self.containerCorners,self.containerCorners)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

- (void)addSwipeGesture
{
    if (self.weakController && [self.weakController isKindOfClass:UIViewController.class]) {
        UIPanGestureRecognizer * gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        gesture.delegate = self;
        [[self targetView] addGestureRecognizer:gesture];
        self.panGesture = gesture;
    }
}

- (void)removeSwipGesture
{
    if (self.weakController && [self.weakController isKindOfClass:UIViewController.class]) {
        if (self.panGesture && [[self targetView].gestureRecognizers containsObject:self.panGesture]) {
            [[self targetView] removeGestureRecognizer:self.panGesture];
            self.panGesture = nil;
        }
    }
}

// Gesture
- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if (!self.targetView) {
        return;
    }
    BOOL horizontal = GDORIS_OPTIONS_CONTAINS(self.swipeOptions, GDorisSwipeGestureHorizontal);
    BOOL vertical = GDORIS_OPTIONS_CONTAINS(self.swipeOptions, GDorisSwipeGestureVertical);
    CGPoint translation = [recognizer translationInView:self.targetView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _recordTargetPositionY = self.targetView.transform.ty;
        _recordTargetPositionX = self.targetView.transform.tx;
        _direction = kDorisMoveDirectionNone;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        _direction = [self determineCameraDirectionIfNeeded:translation];
        switch (_direction) {
            case kDorisMoveDirectionRight:
            case kDorisMoveDirectionLeft:
                if (horizontal) {
                    [self horizontalGestureRecognizedChanged:recognizer];
                }
                break;
            default:
                if (vertical) {
                    [self verticalGestureRecognizedChanged:recognizer];
                }
                break;
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        switch (_direction) {
            case kDorisMoveDirectionRight:
            case kDorisMoveDirectionLeft:
                if (horizontal) {
                    [self horizontalGestureRecognizedEnded:recognizer];
                }
                break;
            default:
                if (vertical) {
                    [self verticalGestureRecognizedEnded:recognizer];
                }
                break;
        }
    }
}

- (void)horizontalGestureRecognizedEnded:(UIPanGestureRecognizer *)recognizer
{
    if (self.targetView.transform.tx > self.targetView.frame.size.width/2) {
        CGAffineTransform _transform = CGAffineTransformMakeTranslation(self.targetView.frame.size.width, 0);
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.targetView.transform = _transform;
        } completion:^(BOOL finished) {
            [self.weakController dismissViewControllerAnimated:NO completion:nil];
        }];
    } else {
        CGAffineTransform _transform = CGAffineTransformMakeTranslation(0, 0);
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.targetView.transform = _transform;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)horizontalGestureRecognizedChanged:(UIPanGestureRecognizer *)recognizer
{
    CGAffineTransform
    _transform = self.targetView.transform;
    _transform.tx = (_recordTargetPositionX + [recognizer translationInView: self.targetView].x );
    if (_transform.tx < 0) {
        _transform.tx = 0;
    }/* else if( _transform.tx > 0) {
      _transform.tx = (_transform.tx / 2);
      self.targetView.transform = _transform;
      } */else {
          self.targetView.transform = _transform;
      }
}

- (void)verticalGestureRecognizedEnded:(UIPanGestureRecognizer *)recognizer
{
    CGFloat velocityInViewY = [recognizer velocityInView:self.targetView].y;
    [self containerMoveForVelocityInView:velocityInViewY];
}

- (void)verticalGestureRecognizedChanged:(UIPanGestureRecognizer *)recognizer
{
    CGAffineTransform
    _transform = self.targetView.transform;
    _transform.ty = (_recordTargetPositionY + [recognizer translationInView: self.targetView].y );
    if (_transform.ty < 0) {
        _transform.ty = 0;
    } else if( _transform.ty < 0) {
        _transform.ty = (_transform.ty / 2);
        self.targetView.transform = _transform;
    } else {
        self.targetView.transform = _transform;
    }
}
/*
 // Gesture
 - (void)panGestureRecognized1:(UIPanGestureRecognizer *)recognizer {
 
 if (!self.targetView) {
 return;
 }
 
 if (recognizer.state == UIGestureRecognizerStateBegan) {
 _recordTargetPositionY = self.targetView.transform.ty;
 }
 else if (recognizer.state == UIGestureRecognizerStateChanged) {
 CGAffineTransform
 _transform = self.targetView.transform;
 _transform.ty = (_recordTargetPositionY + [recognizer translationInView: self.targetView].y );
 if (_transform.ty < 0) {
 _transform.ty = 0;
 } else if( _transform.ty < 0) {
 _transform.ty = (_transform.ty / 2);
 self.targetView.transform = _transform;
 } else {
 self.targetView.transform = _transform;
 }
 
 } else if (recognizer.state == UIGestureRecognizerStateEnded) {
 CGFloat velocityInViewY = [recognizer velocityInView:self.targetView].y;
 [self containerMoveForVelocityInView:velocityInViewY];
 }
 }
 
 - (void)panGestureRecognized2:( UIPanGestureRecognizer *)recognizer
 {
 if (!self.targetView) {
 return;
 }
 CGPoint translation = [recognizer translationInView:self.targetView];
 if (recognizer.state == UIGestureRecognizerStateBegan ){
 _direction = kDorisMoveDirectionNone;
 _recordTargetPositionX = self.targetView.transform.tx;
 } else if (recognizer.state == UIGestureRecognizerStateChanged ){ ///&& _direction == kDorisMoveDirectionNone
 _direction = [self determineCameraDirectionIfNeeded:translation];
 switch (_direction) {
 case kDorisMoveDirectionDown:
 NSLog (@"Start moving down" );
 break;
 case kDorisMoveDirectionUp:
 NSLog (@"Start moving up" );
 break;
 case kDorisMoveDirectionRight:
 {
 CGAffineTransform
 _transform = self.targetView.transform;
 _transform.tx = (_recordTargetPositionX + [recognizer translationInView: self.targetView].x );
 if (_transform.tx < 0) {
 _transform.tx = 0;
 }else {
 self.targetView.transform = _transform;
 }
 }
 NSLog (@"Start moving right" );
 break;
 case kDorisMoveDirectionLeft:
 NSLog (@"Start moving left" );
 break;
 default:
 break;
 }
 } else if (recognizer.state == UIGestureRecognizerStateEnded ) {
 NSLog (@"Stop");
 if (self.targetView.transform.tx > self.targetView.frame.size.width/2) {
 NSLog(@"超过一半");
 CGAffineTransform _transform = CGAffineTransformMakeTranslation(self.targetView.frame.size.width, 0);
 [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
 self.targetView.transform = _transform;
 } completion:^(BOOL finished) {
 [self.weakController dismissViewControllerAnimated:NO completion:nil];
 }];
 } else {
 CGAffineTransform _transform = CGAffineTransformMakeTranslation(0, 0);
 [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
 self.targetView.transform = _transform;
 } completion:^(BOOL finished) {
 }];
 }
 }
 
 }
 */

- (DorisMoveDirection )determineCameraDirectionIfNeeded:( CGPoint)translation
{
    if (_direction != kDorisMoveDirectionNone)
        return _direction;
    
    // determine if horizontal swipe only if you meet some minimum velocity
    if (fabs(translation.x) > kDorisGestureMinimumTranslation)
    {
        BOOL gestureHorizontal = NO;
        if (translation.y == 0.0 )
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0 );
        if (gestureHorizontal)
        {
            if (translation.x > 0.0 )
                return kDorisMoveDirectionRight;
            else
                return kDorisMoveDirectionLeft;
        }
    }
    // determine if vertical swipe only if you meet some minimum velocity
    else if (fabs(translation.y) > kDorisGestureMinimumTranslation)
    {
        BOOL gestureVertical = NO;
        if (translation.x == 0.0 )
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0 );
        if (gestureVertical)
        {
            if (translation.y > 0.0 )
                return kDorisMoveDirectionDown;
            else
                return kDorisMoveDirectionUp;
        }
    }
    return _direction;
}


/// Container Move
- (void)containerMoveForVelocityInView:(CGFloat)velocityInViewY {
    
    ContainerMoveType moveType;
    CGFloat ty = self.targetView.transform.ty;
    CGFloat offset = self.dismissDistance;
    if(ty < 0) {
        moveType = ([UIScreen mainScreen].bounds.size.height < velocityInViewY) ? ContainerMoveTypeBottom : ContainerMoveTypeTop;
    } else {
        if (offset <= 0) {
            moveType = (velocityInViewY < 0) ?ContainerMoveTypeTop :ContainerMoveTypeBottom;
        } else {
            if (ty < offset) {
                moveType = ContainerMoveTypeTop;
            } else {
                moveType = ContainerMoveTypeBottom;
            }
        }
    }
    if (moveType == ContainerMoveTypeBottom) {
        [self containerMoveBottom];
    } else if (moveType == ContainerMoveTypeTop) {
        [self containerMoveTop];
    }
}

- (void)containerMoveBottom
{
    CGAffineTransform _transform = CGAffineTransformMakeTranslation( 0, self.targetView.frame.size.height);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.targetView.transform = _transform;
    } completion:^(BOOL finished) {
        [self.weakController dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)containerMoveTop
{
    CGAffineTransform _transform = CGAffineTransformMakeTranslation( 0, 0);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.targetView.transform = _transform;
    } completion:^(BOOL finished) {
        
    }];
}

- (UIView *)targetView
{
    if (_targetView) {
        return _targetView;
    }
    if (!self.weakController) {
        return nil;
    }
    if ([self.weakController respondsToSelector:@selector(doris_targetGestureView)]) {
        _targetView = [self.weakController doris_targetGestureView];
    }
    _targetView = self.weakController.view;
    return _targetView;
}

#pragma mark - Public Method

- (void)setNeedsTopMask:(BOOL)needsTopMask
{
    _needsTopMask = needsTopMask;
    if (needsTopMask) {
        [self setContainerCorners:self.containerCorners];
    }
}

- (void)setContainerCorners:(CGFloat)containerCorners
{
    _containerCorners = containerCorners;
    if (self.needsTopMask) {
        [self addMoreMasklayer:self.weakController.view andUIRectCorner:UIRectCornerTopLeft|UIRectCornerTopRight];
    }
}

- (void)setSwipeGestureEnabled:(BOOL)swipeGestureEnabled
{
    _swipeGestureEnabled = swipeGestureEnabled;
    if (swipeGestureEnabled) {
        [self addSwipeGesture];
    } else {
        [self removeSwipGesture];
    }
}

#pragma mark - Scroller Gesture Method

- (void)__scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL vertical = GDORIS_OPTIONS_CONTAINS(self.swipeOptions, GDorisSwipeGestureVertical);
    if (!vertical) {
        return;
    }
    CGFloat velocityInViewY    = [scrollView.panGestureRecognizer velocityInView:   self.targetView].y;
    CGFloat translationInViewY = [scrollView.panGestureRecognizer translationInView:self.targetView].y;
    
    if(scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [self.targetView endEditing:YES];
    }
    if((scrollView.panGestureRecognizer.state) && (scrollView.contentOffset.y <= 0)) {
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0 );
    } else {
        scrollView.showsVerticalScrollIndicator = YES;
    }
    
    BOOL bordersRunContainer = ( (scrollView.contentOffset.y == 0) && (0 < velocityInViewY));
    BOOL onceScrollingBeginDragging = NO;
    CGAffineTransform _transform = self.targetView.transform;
    CGFloat top = 0;
    
    if(scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded)
        onceScrollingBeginDragging = NO;
    
    if(bordersRunContainer) {
        _onceEnded = NO;
        onceScrollingBeginDragging = NO;
        _transform.ty = ((top - _startScrollPosition) + translationInViewY );
        if(_transform.ty < top) _transform.ty = top;
        if(_scrollBegin){
            [UIView animateWithDuration:.325 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.targetView.transform = _transform;
            } completion:^(BOOL finished) {
                
            }];
            _scrollBegin = NO;
        } else {
            self.targetView.transform = _transform;
        }
    } else {
        
        if((top == _transform.ty) && !onceScrollingBeginDragging) {
            onceScrollingBeginDragging = YES;
        }
        if(top < _transform.ty) {
            if (velocityInViewY < 0. ) {
                _transform = self.targetView.transform;
                _transform.ty = ((top - _startScrollPosition) + translationInViewY );
                if(_transform.ty < top) _transform.ty = top;
                self.targetView.transform = _transform;
            }
        }
    }
}

- (void)__scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    BOOL vertical = GDORIS_OPTIONS_CONTAINS(self.swipeOptions, GDorisSwipeGestureVertical);
    if (!vertical) {
        return;
    }
    _startScrollPosition = scrollView.contentOffset.y;
    _scrollBegin = YES;
    if(_startScrollPosition < 0) _startScrollPosition = 0;
}

- (void)__scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    BOOL vertical = GDORIS_OPTIONS_CONTAINS(self.swipeOptions, GDorisSwipeGestureVertical);
    if (!vertical) {
        return;
    }
    ///todo by giki
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGFloat velocityInViewY = [scrollView.panGestureRecognizer velocityInView:window].y;
    if(!self.targetView) return;
    if(!_onceEnded){
        _onceEnded = YES;
        [self containerMoveForVelocityInView:velocityInViewY];
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    BOOL isAnimated = [transitionContext isAnimated];
    return isAnimated ? self.transtionDuration : 0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting) {
        [self presentZoomTransition:transitionContext];
    } else {
        [self dismissZoomTransition:transitionContext];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isPresenting = YES;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresenting = NO;
    return self;
}

#pragma mark - zoom animated

- (void)presentZoomTransition:(id<UIViewControllerContextTransitioning>)transitioning
{
    UIViewController *fromViewController   = [transitioning viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitioning viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect initialFrame = [transitioning initialFrameForViewController:fromViewController];
    CGRect finalFrame = [transitioning finalFrameForViewController:toViewController];
    CGRect origin = CGRectOffset(initialFrame, 0, CGRectGetHeight(finalFrame));
    UIView *containerView = [transitioning containerView];
    if (self.needsTopMask) {
        UIView * maskView = [UIView new];
        maskView.userInteractionEnabled = NO;
        maskView.tag = kSwipeGestureMaskViewKey;
        maskView.backgroundColor = self.maskColor ?: [UIColor.blackColor colorWithAlphaComponent:0.5];
        maskView.frame = fromViewController.view.bounds;
        [containerView addSubview:maskView];
    }
    toViewController.view.frame = origin;
    [[transitioning containerView] addSubview:[toViewController view]];
    finalFrame = CGRectOffset(finalFrame, 0, self.containerOffset);
    finalFrame = (CGRect){finalFrame.origin,{finalFrame.size.width,finalFrame.size.height-self.containerOffset}};
    NSTimeInterval duration = [self transitionDuration:transitioning];
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCurlUp
                     animations:^{
        toViewController.view.frame = finalFrame;
    }
                     completion:^(BOOL finished) {
        [toViewController.view layoutIfNeeded];
        [transitioning completeTransition:YES];
    }];
}

- (void)dismissZoomTransition:(id<UIViewControllerContextTransitioning>)transitioning
{
    UIViewController *fromViewController = [transitioning viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitioning viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect initialFrame = [transitioning initialFrameForViewController:fromViewController];
    CGRect finalFrame = [transitioning finalFrameForViewController:toViewController];
    CGRect destination = CGRectOffset(initialFrame, 0, CGRectGetHeight(finalFrame));
    
    if ([fromViewController modalPresentationStyle] == UIModalPresentationNone) {
        [[transitioning containerView] addSubview:[toViewController view]];
        [[transitioning containerView] sendSubviewToBack:[toViewController view]];
    }
    UIView *containerView = [transitioning containerView];
    UIView * maskView = [containerView viewWithTag:kSwipeGestureMaskViewKey];
    NSTimeInterval duration = [self transitionDuration:transitioning];
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^{
        fromViewController.view.frame = destination;
        fromViewController.view.alpha = 1;
        if (maskView && maskView.superview) {
            maskView.alpha = 0;
        }
    }
                     completion:^(BOOL finished) {
        if (maskView && maskView.superview) {
            [maskView removeFromSuperview];
        }
        fromViewController.view.frame = initialFrame;
        if ([transitioning transitionWasCancelled]) {
            [[toViewController view] removeFromSuperview];
        }
        [transitioning completeTransition:![transitioning transitionWasCancelled]];
    }];
}

@end


@implementation UIViewController (DorisSwipeGesture)

static char kAssociatedObjectKey_dorisSwipeTransition;
- (void)setDorisSwipeTransition:(GDorisSwipeGestureTransition *)dorisSwipeTransition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dorisSwipeTransition, dorisSwipeTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GDorisSwipeGestureTransition *)dorisSwipeTransition {
    return (GDorisSwipeGestureTransition *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dorisSwipeTransition);
}

@end
