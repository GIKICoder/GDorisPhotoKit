//
//  GDorisPhotoHelper.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+GDoris.h"
#import "NSArray+GDoris.h"
#import "Masonry.h"

NS_ASSUME_NONNULL_BEGIN

#define GDorisColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define GDorisColorA(r, g, b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
// 随机色
#define GDorisRandomColor GDorisColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define GDorisColorCreate(colorHex) [GDorisPhotoHelper colorWithHex:colorHex]

#define GDorisWidth ([[UIScreen mainScreen] bounds].size.width)
#define GDorisHeight ([[UIScreen mainScreen] bounds].size.height)
#define GDORIS_IS_IPHONE_X         (GDorisHeight == 812.0)
#define GDORIS_IS_IPHONE_XR        (GDorisHeight == 896.0 && [[UIScreen mainScreen] scale] == 2.0)
#define GDORIS_IPHONE_MAX       (GDorisHeight == 896.0 && [[UIScreen mainScreen] scale] == 3.0)

/// 刘海屏
#define GDORIS_IS_NOTCH        (GDORIS_IS_IPHONE_X || GDORIS_IS_IPHONE_XR || GDORIS_IPHONE_MAX)
/// 是否是小屏幕
#define GDORIS_SCREEN_SMALL      ([UIScreen mainScreen].currentMode.size.width <= 640 ? YES : NO)

/// 底部margin iphonex 为34 其他为0
#define GDoris_TabBarMargin (GDORIS_IS_NOTCH ? (34.f) :(0.0f))

/// 导航栏高度 44
#define GDorisNavBarContentHeight (50.0f)
/// 隐藏状态栏的情况下 也有值
#define GDorisStatusBarHeight (GDORIS_IS_NOTCH ? (44.f) :(20.0f))
#define GDorisNavBarHeight (GDorisNavBarContentHeight+GDorisStatusBarHeight)

#define GDorisPhotoErrorDomain  @"GDorisPhoto.Error.domain"


@interface GDorisPhotoHelper : NSObject

+ (UIColor *)colorWithHex:(NSString *)hexColor;
+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)alpha;

+ (UIImage *)createImageWithColor: (UIColor *)color;
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image;

+ (void)fitImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize Completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed;
@end

NS_ASSUME_NONNULL_END
