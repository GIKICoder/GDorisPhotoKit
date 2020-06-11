//
//  GDorisPhotoZoomAnimatedTransition.m
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisScrollerPanGesutreRecognizer.h"

NSString *const kDorisPhotoZoomImageKey = @"kDorisPhotoZoomImageKey";

CGRect GImageAspectFitRectForSize(UIImage *image, CGSize size){
    CGSize imageSize = CGSizeMake(100, 200);
    if (image) {
        imageSize = image.size;
    }
    CGFloat targetAspect = size.width / size.height;
    CGFloat sourceAspect = imageSize.width / imageSize.height;
    CGRect rect = CGRectZero;
    
    if (targetAspect > sourceAspect) {
        rect.size.width = size.width;
        rect.size.height = ceilf(rect.size.width / sourceAspect);;
        rect.origin.x = 0;
        rect.origin.y = 0;
    }
    else {
        rect.size.width = size.width;
        rect.size.height = ceilf(rect.size.width / sourceAspect);
        rect.origin.y = ceilf((size.height - rect.size.height) * 0.5);
        rect.origin.x = 0;
    }
    
    return rect;
}

@interface GDorisPhotoZoomAnimatedTransition ()
@property (nonatomic, weak  ) id<GDorisZoomPresentingAdapter>  presentingAdapter;
@property (nonatomic, weak  ) id<GDorisZoomPresentedAdapter>  presentedAdapter;
@property (nonatomic, assign) BOOL  isPresenting;
@property (nonatomic, assign) BOOL  isInteraction;
@property (nonatomic, strong) GDorisScrollerPanGesutreRecognizer *panGesture;
@end

@implementation GDorisPhotoZoomAnimatedTransition

+ (instancetype)zoomAnimatedWithPresenting:(id<GDorisZoomPresentingAdapter>)presenting
                                 presented:(id<GDorisZoomPresentedAdapter>)presented
{
    GDorisPhotoZoomAnimatedTransition * transition = [[GDorisPhotoZoomAnimatedTransition alloc] initWithPresenting:presenting presented:presented];
    return transition;
}

- (instancetype)initWithPresenting:(id<GDorisZoomPresentingAdapter>)presenting
                         presented:(id<GDorisZoomPresentedAdapter>)presented
{
    if (self = [super init]) {
        
        self.presentedAdapter = presented;
        self.presentingAdapter = presenting;
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    self.transtionDuration = 0.38;
    if ([self.presentedAdapter isKindOfClass:[UIViewController class]]) {
        UIViewController * controller = (id)self.presentedAdapter;
        self.translationDistance = CGRectGetWidth(controller.view.bounds);
    } else {
        self.translationDistance = [UIScreen mainScreen].bounds.size.width;
    }
    self.draggingEnable = YES;
    self.draggingUpEnable = YES;
    self.hiddenFromTargetView = YES;
    self.dismissDelay = NO;
    self.showTargetCornerRadius = YES;
    self.transitionTargetAspectFit = YES;
}

- (void)addPanGesture
{
    if (self.presentedAdapter && [self.presentedAdapter isKindOfClass:UIViewController.class]) {
        self.panGesture = [[GDorisScrollerPanGesutreRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        self.panGesture.delegate = self;
        UIViewController * vc = (id)self.presentedAdapter;
        [vc.view addGestureRecognizer:self.panGesture];
    }
}

- (void)removePanGesture
{
    if (self.presentedAdapter && [self.presentedAdapter isKindOfClass:UIViewController.class]) {
        UIViewController * vc = (id)self.presentedAdapter;
        if (self.panGesture && [vc.view.gestureRecognizers containsObject:self.panGesture]) {
            [vc.view removeGestureRecognizer:self.panGesture];
            self.panGesture = nil;
        }
    }
    
}

- (void)setDraggingEnable:(BOOL)draggingEnable
{
    _draggingEnable = draggingEnable;
    if (draggingEnable) {
        [self removePanGesture];
        [self addPanGesture];
    } else {
        [self removePanGesture];
    }
}

#pragma mark - handlePanGestureRecognizer

- (void)processModalViewHidden:(BOOL)hidden
{
    if (!self.hiddenFromTargetView) return;
    
    id<GDorisZoomPresentingAdapter> toAdapter = self.presentingAdapter;
    id<GDorisZoomPresentedAdapter>  fromAdapter = self.presentedAdapter;
    
    if ([toAdapter respondsToSelector:@selector(presentingViewAtIndex:)] && [fromAdapter respondsToSelector:@selector(indexOfPresentedView)]) {
        NSInteger index = [fromAdapter indexOfPresentedView];
        UIView * presentingView = [toAdapter presentingViewAtIndex:index];
        if(presentingView) presentingView.hidden = hidden;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateFailed ) {
        return;
    }
    if (!self.draggingEnable) return;
    UIView * inView = [UIApplication sharedApplication].keyWindow;
    if (self.presentedAdapter && [self.presentedAdapter isKindOfClass:UIViewController.class]) {
        UIViewController * vc = (id)self.presentedAdapter;
        inView = vc.view;
    }
    CGPoint translationPoint = [recognizer translationInView:inView];
    UIView *presentedView = inView;
    if ([self.presentedAdapter respondsToSelector:@selector(presentedView)]) {
        UIView * presetedView_ = [self.presentedAdapter presentedView];
        if (presetedView_.frame.size.height > inView.frame.size.height) {
            presentedView = presetedView_;
        } else {
            presentedView = presetedView_.superview;
        }
    }
    UIView * backgroundView = inView;
    if ([self.presentedAdapter respondsToSelector:@selector(presentedBackgroundView)]) {
        backgroundView = self.presentedAdapter.presentedBackgroundView;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint locationPoint = [recognizer locationInView:inView];
        BOOL canGesure = [self canGestureEffective:locationPoint];
        if (!canGesure) {
            recognizer.state = UIGestureRecognizerStateFailed;
            return;
        }
        self.isInteraction = YES;
        if (self.hiddenFromTargetView) {
            [self processModalViewHidden:YES];
        }
    } else if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat progress = sqrt(pow(translationPoint.x, 2) + pow(translationPoint.y, 2)) / self.translationDistance;
        progress = MIN(1.0, MAX(0.0, progress));
        presentedView.transform = CGAffineTransformIdentity;
        presentedView.transform = CGAffineTransformScale(CGAffineTransformTranslate(CGAffineTransformIdentity, translationPoint.x, translationPoint.y), 1 - progress / 2., 1 - progress / 2.);
        [self processBeginGestureHandler:progress];
        if (!self.draggingUpEnable && translationPoint.y < 0) {
            backgroundView.backgroundColor = [backgroundView.backgroundColor colorWithAlphaComponent:1.f];
        } else {
            CGFloat alpha = MAX((1 - progress), 0.25);//+0.25
            backgroundView.backgroundColor = [backgroundView.backgroundColor colorWithAlphaComponent:alpha];
        }
    }  else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat progress = sqrt(pow(translationPoint.x, 2) + pow(translationPoint.y, 2)) / self.translationDistance;
        progress = MIN(1.0, MAX(0.0, progress));
        if ((!self.draggingUpEnable && translationPoint.y < 0) || progress <= 0.15) {
            [UIView animateWithDuration:0.2 animations:^{
                backgroundView.backgroundColor = [backgroundView.backgroundColor colorWithAlphaComponent:1.f];
                presentedView.transform = CGAffineTransformIdentity;
            }];
            [self processModalViewHidden:NO];
            [self processEndGestureHandler:YES];
        } else {
            [self processEndGestureHandler:NO];
            if (self.presentedAdapter && [self.presentedAdapter isKindOfClass:UIViewController.class]) {
                UIViewController * vc = (id)self.presentedAdapter;
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }
        self.isInteraction = NO;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer
{
    if ([self.presentedAdapter respondsToSelector:@selector(presentedScrollView)]) {
        self.panGesture.scrollview = self.presentedAdapter.presentedScrollView;
    }
    return recognizer == self.panGesture;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.presentedAdapter respondsToSelector:@selector(presentedScrollView)]) {
        UIScrollView * scrollview = self.presentedAdapter.presentedScrollView;
        if (scrollview.scrollEnabled) {
            if ([self.presentedAdapter respondsToSelector:@selector(view)]) {
                UIView * inView = [UIApplication sharedApplication].keyWindow;
                if (self.presentedAdapter && [self.presentedAdapter isKindOfClass:UIViewController.class]) {
                    UIViewController * vc = (id)self.presentedAdapter;
                    inView = vc.view;
                }
                if (scrollview.contentSize.height > inView.frame.size.height) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.presentedAdapter respondsToSelector:@selector(presentedScrollView)]) {
        UIScrollView * scrollview = self.presentedAdapter.presentedScrollView;
        if (scrollview.scrollEnabled) {
            if ([self.presentedAdapter respondsToSelector:@selector(view)]) {
                UIView * inView = [UIApplication sharedApplication].keyWindow;
                if (self.presentedAdapter && [self.presentedAdapter isKindOfClass:UIViewController.class]) {
                    UIViewController * vc = (id)self.presentedAdapter;
                    inView = vc.view;
                }
                if (scrollview.contentSize.height > inView.frame.size.height) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)processBeginGestureHandler:(CGFloat)progress
{
    if (self.presentedAdapter && [self.presentedAdapter respondsToSelector:@selector(beginGestureHandler:)]) {
        [self.presentedAdapter beginGestureHandler:progress];
    }
}

- (void)processEndGestureHandler:(BOOL)isCanceled
{
    if (self.presentedAdapter && [self.presentedAdapter respondsToSelector:@selector(endGestureHandler:)]) {
        [self.presentedAdapter endGestureHandler:isCanceled];
    }
}

- (BOOL)canGestureEffective:(CGPoint)point
{
    if (self.presentedAdapter && [self.presentedAdapter respondsToSelector:@selector(gestureEffectiveFrame)]) {
        CGRect effective = [self.presentedAdapter gestureEffectiveFrame];
        if (CGRectEqualToRect(effective, CGRectZero)) {
            return NO;
        } else {
            BOOL contains = CGRectContainsPoint(effective, point);
            return contains;
        }
    }
    return YES;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return self.transtionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting) {
        [self presentZoomTransition:transitionContext];
    } else {
        
        void (^invokeBlock)(void) = ^void(void) {
            [self dismissZoomTransition:transitionContext];
        };
        if (self.dismissDelay) {
            id<GDorisZoomPresentingAdapter> toAdapter = self.presentingAdapter;
            id<GDorisZoomPresentedAdapter> fromAdapter = self.presentedAdapter;
            if ([fromAdapter respondsToSelector:@selector(indexOfPresentedView)] && [toAdapter respondsToSelector:@selector(presentingViewAtIndex:)]) {
                NSInteger index = [fromAdapter indexOfPresentedView];
                [toAdapter presentingViewAtIndex:index];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (invokeBlock) {
                    invokeBlock();
                }
            });
        } else {
            if (invokeBlock) {
                invokeBlock();
            }
        }
        
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
    UIViewController * fromViewController = (id)[transitioning viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController = (id)[transitioning viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitioning containerView];
    UIColor *windowBackgroundColor = [containerView backgroundColor];
    containerView.backgroundColor = [UIColor blackColor];
    
    UIView *fromTargetView = nil;
    CGRect fromRect = CGRectMake(([UIScreen mainScreen].bounds.size.width)*0.5, ([UIScreen mainScreen].bounds.size.height)*0.5, 0, 0);
    if ([self.presentingAdapter respondsToSelector:@selector(presentingView)]) {
        UIView * presentingView = self.presentingAdapter.presentingView;
        if (presentingView) {
            fromTargetView = presentingView;
            UIView * targetTemp = fromTargetView;
            if (targetTemp.superview) {
                targetTemp = targetTemp.superview;
            }
            fromRect = [containerView convertRect:fromTargetView.frame fromView:targetTemp];
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.frame = fromRect;
    [containerView addSubview:imageView];
    [containerView sendSubviewToBack:[fromViewController view]];
    
    CGRect finalFrame = [transitioning finalFrameForViewController:toViewController];
    CGRect transitionViewFinalFrame = finalFrame;
    if ([fromTargetView isKindOfClass:[UIImageView class]]) {
        UIImageView * targetImage = (UIImageView * )fromTargetView;
        UIImage * image = targetImage.image;
        imageView.image = image;
        if (self.transitionTargetAspectFit) {
            transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
        } else {
            transitionViewFinalFrame = CGRectMake(0.5*(finalFrame.size.width-image.size.width), 0.5*(finalFrame.size.height-image.size.height), image.size.width, image.size.height);
        }
        
    } else if ([fromTargetView isKindOfClass:[UIButton class]]) {
        UIButton * targetButton = (UIButton * )fromTargetView;
        UIImage * image = [targetButton imageForState:UIControlStateNormal];
        if (!image) {
            image = targetButton.currentBackgroundImage;
        }
        if (image) {
            imageView.image = image;
            transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
        } else {
            image = [self captureView:targetButton];
            imageView.image = image;
            transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
        }
    } else if (fromTargetView && [fromTargetView isKindOfClass:[UIView class]]) {
        UIImage * image = [self captureView:fromTargetView];
        imageView.image = image;
        transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
    }
    
    /// First loadImage,if End of animation. First time filling
    [[NSNotificationCenter defaultCenter] postNotificationName:kDorisPhotoZoomImageKey object:imageView.image];
    UIView * maskView = nil;
    if ([fromViewController modalPresentationStyle] == UIModalPresentationCustom) {
        maskView = [UIView new];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.frame = [UIScreen mainScreen].bounds;
        [fromViewController.view addSubview:maskView];
    }
    NSTimeInterval duration = [self transitionDuration:transitioning];
    if (imageView.frame.size.width == 0||imageView.frame.size.height == 0) {
        duration = 0;
    }
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        if ([fromViewController modalPresentationStyle] != UIModalPresentationCustom) {
            fromViewController.view.alpha = 0;
        }
        imageView.frame = transitionViewFinalFrame;
    }
                     completion:^(BOOL finished) {
        if (maskView && maskView.superview) {
            [maskView removeFromSuperview];
        }
        containerView.backgroundColor = windowBackgroundColor;
        fromViewController.view.alpha = 1;
        [imageView removeFromSuperview];
        if (![transitioning transitionWasCancelled]) {
            [containerView addSubview:[toViewController view]];
        }
        [transitioning completeTransition:![transitioning transitionWasCancelled]];
    }];
}

- (void)dismissZoomTransition:(id<UIViewControllerContextTransitioning>)transitioning
{
    UIViewController * fromViewController = (id)[transitioning viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController = (id)[transitioning viewControllerForKey:UITransitionContextToViewControllerKey];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *containerView = [transitioning containerView];
    UIColor *windowBackgroundColor = [window backgroundColor];
    
//    toViewController.view.frame = [transitioning finalFrameForViewController:toViewController];
    
    id<GDorisZoomPresentingAdapter> toAdapter = self.presentingAdapter;
    id<GDorisZoomPresentedAdapter> fromAdapter = self.presentedAdapter;
    
    if ([fromViewController modalPresentationStyle] == UIModalPresentationNone) {
        toViewController.view.alpha = 0;
        window.backgroundColor = [UIColor blackColor];
        [containerView addSubview:[toViewController view]];
        [containerView sendSubviewToBack:[toViewController view]];
    }
    
    UIView *toTargetView = nil;
    
    UIView *fromTargetView = nil;
    if ([fromAdapter respondsToSelector:@selector(indexOfPresentedView)] && [toAdapter respondsToSelector:@selector(presentingViewAtIndex:)]) {
        NSInteger index = [fromAdapter indexOfPresentedView];
        toTargetView = [toAdapter presentingViewAtIndex:index];
    }
    if ([fromAdapter respondsToSelector:@selector(presentedView)]) {
        fromTargetView = fromAdapter.presentedView;
    }
    
    UIImage * fromImage = nil;
    if ([fromTargetView isKindOfClass:[UIImageView class]]) {
        UIImageView * targetImage = (UIImageView * )fromTargetView;
        fromImage = targetImage.image;
        
    } else if ([fromTargetView isKindOfClass:[UIButton class]]) {
        UIButton * targetButton = (UIButton * )fromTargetView;
        fromImage = [targetButton imageForState:UIControlStateNormal];
        if (!fromImage) {
            fromImage = targetButton.currentBackgroundImage;
        }
        if (!fromImage) {
            fromImage = [self captureView:targetButton];
        }
    }
    if (!fromImage) {
        fromImage = [self captureView:fromTargetView];
    }
    CGRect startTransitionFrame = GImageAspectFitRectForSize(fromImage, fromTargetView.bounds.size);
    startTransitionFrame = [containerView convertRect:startTransitionFrame fromView:fromTargetView];
    
    CGRect needTransitionFrame = CGRectMake([UIScreen mainScreen].bounds.size.width*0.5,[UIScreen mainScreen].bounds.size.height*0.5 , 0, 0);
    CGFloat alpha = 0;
    if (toTargetView) {
        needTransitionFrame = [containerView convertRect:toTargetView.bounds fromView:toTargetView];
        alpha = 1;
    }
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:fromImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.showTargetCornerRadius) {
        imageView.layer.cornerRadius = toTargetView.layer.cornerRadius;
        imageView.clipsToBounds = YES;
    }
    if (!CGRectIsEmpty(startTransitionFrame)) {
        imageView.frame = startTransitionFrame;
    }
    [containerView addSubview:imageView];
    fromTargetView.hidden = YES;
    if (self.hiddenFromTargetView) {
        toTargetView.hidden = YES;
    }
    NSTimeInterval duration = [self transitionDuration:transitioning];
    if (needTransitionFrame.size.width == 0 || needTransitionFrame.size.height == 0) {
        imageView.frame = needTransitionFrame;
    }
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        toViewController.view.alpha = 1.f;
        fromViewController.view.alpha = 0.f;
        imageView.frame = needTransitionFrame;
        imageView.alpha = alpha;
    } completion:^(BOOL finished) {
        
        window.backgroundColor = windowBackgroundColor;
        [imageView removeFromSuperview];
        if (self.hiddenFromTargetView) {
            toTargetView.hidden = NO;
        }
        if ([transitioning transitionWasCancelled]) {
            fromTargetView.hidden = NO;
            fromViewController.view.alpha = 1.f;
            [toViewController.view removeFromSuperview];
        }
        [transitioning completeTransition:![transitioning transitionWasCancelled]];
    }];
}

#pragma mark - help Method


- (__kindof UIViewController *)getZoomTransitionController:(UIViewController *)controller
{
    UIViewController *zoomVC = nil;
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController * tabbar = (UITabBarController *)controller;
        zoomVC = (id)tabbar.selectedViewController;
        if ([zoomVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController * nav = (UINavigationController *)zoomVC;
            zoomVC = (id)nav.topViewController;
        }
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController * nav = (UINavigationController *)controller;
        zoomVC = (id)nav.topViewController;
    } else {
        zoomVC = (id)controller;
    }
    return zoomVC;
}

- (UIImage *)captureView:(UIView *)view
{
    return [self captureView:view withFrame:view.bounds];
}

- (UIImage *)captureView:(UIView *)view withFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return nil;
    }
    BOOL temp = YES;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        temp = [view drawViewHierarchyInRect:frame afterScreenUpdates:YES];
    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!temp) {
        return nil;
    }
    return image;
}
@end

