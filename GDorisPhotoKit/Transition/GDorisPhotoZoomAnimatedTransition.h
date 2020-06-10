//
//  GDorisPhotoZoomAnimatedTransition.h
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kDorisPhotoZoomImageKey;

@protocol GDorisZoomGestureHandlerProtocol <NSObject>

@optional
- (void)beginGestureHandler:(CGFloat)progress;
- (void)endGestureHandler:(BOOL)isCanceled;
- (CGRect)gestureEffectiveFrame;
@end

@protocol GDorisZoomPresentingAdapter <GDorisZoomGestureHandlerProtocol>
@optional
- (__kindof UIView *)presentingView;
- (__kindof UIView *)presentingViewAtIndex:(NSInteger)index;
@end

@protocol GDorisZoomPresentedAdapter <GDorisZoomGestureHandlerProtocol>
@optional
- (__kindof UIView *)presentedView;
- (NSInteger)indexOfPresentedView;
- (__kindof UIView *)presentedBackgroundView;
- (__kindof UIScrollView *)presentedScrollView;
@end

@interface GDorisPhotoZoomAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

/// 初始化转场动画
/// @param presenting 转场的适配器
/// @param presented 需要转场的适配器.一般为UIViewController
+ (instancetype)zoomAnimatedWithPresenting:(id<GDorisZoomPresentingAdapter>)presenting
                                 presented:(id<GDorisZoomPresentedAdapter>)presented;
/**
 transtionDuration
 default:0.25
 */
@property (nonatomic, assign) NSTimeInterval  transtionDuration;

/**
 是否延迟Dismiss
 Default: NO
 */
@property (nonatomic, assign) BOOL  dismissDelay;

/**
 translationDistance
 default: controller.view.width
 */
@property (nonatomic, assign) CGFloat translationDistance;

/**
 zoom转场后是否隐藏转场View
 default: NO
 */
@property (nonatomic, assign) BOOL  hiddenFromTargetView;

/**
 是否开启拖拽手势
 default: YES
 */
@property (nonatomic, assign) BOOL  draggingEnable;

/**
 是否开启向上拖拽 Dismiss
 default: YES
 */
@property (nonatomic, assign) BOOL  draggingUpEnable;

/**
 动画过程中是否展示targetView的CornerRadius属性
 default: YES
 */
@property (nonatomic, assign) BOOL  showTargetCornerRadius;

/// 转场动画是否适应目标view大小, default:YES
@property (nonatomic, assign) BOOL  transitionTargetAspectFit;
@end

