//
//  GDorisSwipeGestureTransition.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/27.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol GDorisSwipeGestureTargetAdpter <NSObject>
@optional
- (UIView *)doris_targetGestureView;
@end

typedef NS_OPTIONS(NSUInteger, GDorisSwipeGestureOptions) {
    GDorisSwipeGestureNone = 1 << 0,
    GDorisSwipeGestureHorizontal = 1 << 1,
    GDorisSwipeGestureVertical = 1 << 2,
};


@interface GDorisSwipeGestureTransition : NSObject<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

+ (instancetype)swipeGestureTransitionWithTarget:(UIViewController<GDorisSwipeGestureTargetAdpter> *)controller;

/// 转场动画时长 default:0.25
@property (nonatomic, assign) NSTimeInterval  transtionDuration;

/// 页面偏移量 default:0
@property (nonatomic, assign) CGFloat  containerOffset;

/// 是否需要顶部蒙层 default:NO
@property (nonatomic, assign) BOOL  needsTopMask;

/// 顶部蒙层颜色 default: [UIColor.blackColor colorWithAlphaComponent:0.5]
@property (nonatomic, strong) UIColor * maskColor;

/// 转场后页面顶部圆角 default: 10
@property (nonatomic, assign) CGFloat  containerCorners;

/// 是否开启拖拽手势 default: YES
@property (nonatomic, assign) BOOL  swipeGestureEnabled;

/// 拖拽手势支持的拖拽方向
@property (nonatomic, assign) GDorisSwipeGestureOptions  swipeOptions;

/// 页面下滑消失距离 default: [UIScreen mainScreen].bounds.size.height*0.5
@property (nonatomic, assign) CGFloat  dismissDistance;

/**
 如果有scrollView需要处理scrollveiw滑动事件.
 在scrollview delegate方法中调用如下方法即可

 @param scrollView <#scrollView description#>
 */
- (void)__scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)__scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)__scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface UIViewController (DorisSwipeGesture)
@property (nonatomic, strong) GDorisSwipeGestureTransition * dorisSwipeTransition;
@end

NS_ASSUME_NONNULL_END
