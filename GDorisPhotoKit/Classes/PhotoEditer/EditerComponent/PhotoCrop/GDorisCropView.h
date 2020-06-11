//
//  GDorisCropView.h
//  GDoris
//
//  Created by GIKI on 2018/9/5.
//  Copyright © 2018年 GIKI. All rights reserved.
//
//  Code Reference: https://github.com/TimOliver/TOCropViewController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GDorisCropOverlayView;
@class GDorisCropView;
@protocol GDorisCropViewDelegate<NSObject>

- (void)cropViewDidBecomeResettable:(GDorisCropView *)cropView;
- (void)cropViewDidBecomeNonResettable:(GDorisCropView *)cropView;

@end

@interface GDorisCropView : UIView

/**
 需要裁剪的图片，实例化后不可更改
 */
@property (nonnull, nonatomic, strong, readonly) UIImage *image;

/**
 图片上的网格视图
 */
@property (nonnull, nonatomic, strong, readonly) GDorisCropOverlayView *gridOverlayView;

/**
 裁剪图像的容器视图
 */
@property (nonnull, nonatomic, readonly) UIView *foregroundContainerView;

/**
 A delegate object 
 */
@property (nullable, nonatomic, weak) id<GDorisCropViewDelegate> delegate;

/**
 启用网格视图手势，如果设置为NO.则不能使用手势调整网格视图
 Default vaue is YES.
 */
@property (nonatomic, assign) BOOL cropBoxResizeEnabled;

/**
 是否可以重置已经调整的视图
 */
@property (nonatomic, readonly) BOOL canBeReset;

/**
 图片裁剪框的Frame
 */
@property (nonatomic, readonly) CGRect cropBoxFrame;

/**
 在scrollView中图片视图的Frame
 */
@property (nonatomic, readonly) CGRect imageViewFrame;

/**
 裁剪区域的内边距
 */
@property (nonatomic, assign) UIEdgeInsets cropRegionInsets;

/**
 是否禁用半透明视图
 */
@property (nonatomic, assign) BOOL simpleRenderMode;

/**
 执行手动内容布局时(例如在屏幕旋转期间)，禁用任何内部布局
 */
@property (nonatomic, assign) BOOL internalLayoutDisabled;

/**
 裁剪框将被重新缩放到的宽高比(例如4:3为{4.0f，3.0f})
 将其设置为CGSizeZero会将纵横比重置为图像自身的比率。
 */
@property (nonatomic, assign) CGSize aspectRatio;

/**
 当裁剪框锁定到其当前宽高比时(但仍可调整大小)
 */
@property (nonatomic, assign) BOOL aspectRatioLockEnabled;

/**
 如果为true，则设置自定义宽高比，并且aspectRatioLockEnabled设置为YES，裁剪框将根据纵向或横向大小的图像交换其尺寸。 此值还控制尺寸在旋转图像时是否可以交换。
 Default is NO.
 */
@property (nonatomic, assign) BOOL aspectRatioLockDimensionSwapEnabled;

/**
 当用户点击“重置”时，宽高比是否也将被重置
 Default is YES
 */
@property (nonatomic, assign) BOOL resetAspectRatioEnabled;

/**
 如果裁剪框的高度大于宽度，则为true
 */
@property (nonatomic, readonly) BOOL cropBoxAspectRatioIsPortrait;

/**
 裁剪视图的旋转角度（沿逆时针方向旋转时始终为负）
 */
@property (nonatomic, assign) NSInteger angle;

/**
 隐藏过渡动画的所有裁剪元素
 */
@property (nonatomic, assign) BOOL croppingViewsHidden;

/**
 对于图像的坐标空间，裁剪视图聚焦的Frame
 */
@property (nonatomic, assign) CGRect imageCropFrame;

/**
 网格视图隐藏属性
 */
@property (nonatomic, assign) BOOL gridOverlayHidden;

/// 裁剪矩形的填充。 默认为14.0
@property (nonatomic) CGFloat cropViewPadding;

/**
 裁剪后的区域调整时间
  Default to 0.8
 */
@property (nonatomic) NSTimeInterval cropAdjustingDelay;

/**
 最小裁剪宽高比。
 */
@property (nonatomic, assign) CGFloat minimumAspectRatio;

/**
 图像缩放的最大比例。 仅在aspectRatioLockEnabled设置为true时生效。 默认为15.0
 */
@property (nonatomic, assign) CGFloat maximumZoomScale;

/**
 Create a default instance of the crop view with the supplied image
 */
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image;

/**
 初始化布局设置或者重置初始化属性设置。
 添加父视图之后，应该调用这个函数。
 */
- (void)performInitialSetup;

/**
 执行大尺寸转换（例如，方向旋转）时，
 暂时显示图形效果，如半透明效果。

 @param simpleMode 是否启用简单模式
 */
- (void)setSimpleRenderMode:(BOOL)simpleMode animated:(BOOL)animated;

/**
 当执行将改变滚动视图大小的屏幕旋转时，需要
 所有滚动视图数据在被iOS操作之前的快照。
 在提交旋转动画块之前，请在视图控制器中调用该方法。
 当屏幕旋转的时候，调用该方法
 */
- (void)prepareforRotation;

/**
 在屏幕旋转时执行裁剪视图的重新对齐。
 在视图控制器的屏幕旋转动画块中调用
 */
- (void)performRelayoutForRotation;

/**
 重置裁剪框和缩放比例
 @param animated The reset is animated
 */
- (void)resetLayoutToDefaultAnimated:(BOOL)animated;

/**
 更改裁剪框的宽高比
 @param aspectRatio 纵横比(例如16:9是16.0/9.0)。“CGSizeZero”会将其重置为图像本身的比例
 @param animated Whether the locking effect is animated
 */
- (void)setAspectRatio:(CGSize)aspectRatio animated:(BOOL)animated;

/**
 逆时针选择90度
 @param animated Whether the transition is animated
 */
- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated;

/**
 将整个画布旋转90度
 @param animated Whether the transition is animated
 @param clockwise 旋转是否顺时针。通过“否”表示逆时针方向
 */
- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated clockwise:(BOOL)clockwise;

/**
 将网格覆盖图形制作成可见的动画
 */
- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden animated:(BOOL)animated;

/**
 设置裁剪视图显示动画
 */
- (void)setCroppingViewsHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 设置背景视图显示动画
 */
- (void)setBackgroundImageViewHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 触发后，裁剪视图将执行重新布局，以确保裁剪框
 填充整个裁剪视图区域
 */
- (void)moveCroppedContentToCenterAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
