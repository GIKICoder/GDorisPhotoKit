//
//  UIView+GDoris.h
//  GDoris
//
//  Created by GIKI on 2018/9/17.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GDoris)
@property (nonatomic) CGFloat g_left;
@property (nonatomic) CGFloat g_top;
@property (nonatomic) CGFloat g_right;
@property (nonatomic) CGFloat g_bottom;
@property (nonatomic) CGFloat g_width;
@property (nonatomic) CGFloat g_height;
@property (nonatomic) CGFloat g_centerX;    
@property (nonatomic) CGFloat g_centerY;
@property (nonatomic) CGPoint g_origin;
@property (nonatomic) CGSize  g_size;

@property (nonatomic, readonly) UIViewController * g_viewController;

- (UIImage *)g_snapshotImage;

- (UIImage *)g_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;
@end

NS_ASSUME_NONNULL_END
