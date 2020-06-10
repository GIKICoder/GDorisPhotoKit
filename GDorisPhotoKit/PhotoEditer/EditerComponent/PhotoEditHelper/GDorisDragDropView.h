//
//  GDorisDragDropView.h
//  GDoris
//
//  Created by GIKI on 2018/9/16.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisDragDropView : UIView

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, assign) BOOL  dragEnabled;

@property (nonatomic, assign) NSInteger minimumSize;

@property (nonatomic, assign) CGSize  maxSize;

@property (nonatomic, strong) UIColor *outlineBorderColor;

@property (nonatomic, assign) CGFloat  autoHideBorderDuration;

@property (nonatomic, assign) BOOL  editEnabled;

/// default: YES
@property (nonatomic, assign) BOOL  rotateEnable;
/// default: YES
@property (nonatomic, assign) BOOL  scaleEnable;

/// 是否开启拖拽弹簧效果 default:NO
@property (nonatomic, assign) BOOL  dragBounces;

/// 是否开启边界吸附效果 default:NO
@property (nonatomic, assign) BOOL  dragAdsorption;

///  吸附距离 default: 12
@property (nonatomic, assign) CGFloat  adsorptionDistance;

@property (nonatomic, strong) __kindof id userInfo;

- (instancetype)initWithContentView:(__kindof UIView *)contentView;

@end

NS_ASSUME_NONNULL_END
