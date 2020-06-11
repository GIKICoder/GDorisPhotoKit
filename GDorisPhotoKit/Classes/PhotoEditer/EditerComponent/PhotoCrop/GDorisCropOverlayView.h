//
//  GDorisCropOverlayView.h
//  GDoris
//
//  Created by GIKI on 2018/9/5.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisCropOverlayView : UIView

/**
 隐藏内部网格线，无动画。
 */
@property (nonatomic, assign) BOOL gridHidden;

/** 添加/删除内部水平网格线*/
@property (nonatomic, assign) BOOL displayHorizontalGridLines;

/** 添加/删除内部垂直网格线*/
@property (nonatomic, assign) BOOL displayVerticalGridLines;

/** 显示和隐藏内部网格线 */
- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
