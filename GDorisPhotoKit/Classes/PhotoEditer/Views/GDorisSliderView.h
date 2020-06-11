//
//  GDorisSliderView.h
//  XCChat
//
//  Created by GIKI on 2019/4/13.
//  Copyright © 2019年 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XCCVideoSliderEvent) {
    XCCVideoSliderEventDidBegin = 1001,
    XCCVideoSliderEventValueChanged,
    XCCVideoSliderEventDidEnd,
};

@class GDorisSliderView;
@protocol XCCVideoSliderDelegate <NSObject>

@optional

- (void)slider:(GDorisSliderView *)slider forSliderEvents:(XCCVideoSliderEvent)sliderEvents;

@end

@interface GDorisSliderView : UIView

@property (nonatomic, weak  ) id<XCCVideoSliderDelegate>   delegate;
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
@property (nonatomic, strong) UIColor *trackBufferTintColor;
/// 滑块颜色，有滑块图片时，滑块颜色失效
@property (nonatomic, strong) UIColor *thumbTintColor;
/// 滑块图片
@property (nonatomic, strong) UIImage *currentThumbImage;
/// 滑动轨道是否有圆角 Default:YES
@property (nonatomic, assign)  BOOL isTruckCornerRidus;
/// 滑块是否有圆角, Default:YES
@property (nonatomic, assign)  BOOL isThumbCornerRidus;
/// 轨道高度
@property (nonatomic, assign)  CGFloat trackHeight;
/// 滑块尺寸 Default: ViewHeight
@property (nonatomic, assign)  CGSize thumbTintSize;

/**
 minimumValue <= limitMinimumValue <= value <= limitMaximumValue <= maximumValue
 */
/// 当前值
@property (nonatomic, assign)  float value;
/// 最小值，默认0.0
@property (nonatomic, assign)  float minimumValue;
/// 最大值，默认1.0
@property (nonatomic, assign)  float maximumValue;
/// 限制最小值
@property (nonatomic, assign)  float limitMinimumValue;
/// 限制最大值
@property (nonatomic, assign)  float limitMaximumValue;
/// 缓存条进度
@property (nonatomic, assign) float  bufferValue;
@end

NS_ASSUME_NONNULL_END
