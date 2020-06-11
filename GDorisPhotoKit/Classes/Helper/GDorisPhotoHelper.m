//
//  GDorisPhotoHelper.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoHelper.h"

@implementation GDorisPhotoHelper

+ (UIColor *)colorWithHex:(NSString *)hexColor
{
    return [self colorWithHex:hexColor alpha:1.f];
}

+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)alpha
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:alpha];
}

+ (UIImage *)createImageWithColor: (UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!theImage) {
        theImage = [UIImage new];
    }
    
    return theImage;
}

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size  {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!theImage) {
        theImage = [UIImage new];
    }
    
    return theImage;
}


+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!newImage) {
        newImage = [UIImage new];
    }
    return newImage;
}

+ (void)fitImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize Completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed
{
    CGFloat containerWidth = containerSize.width;
    CGFloat containerHeight = containerSize.height;
    CGFloat containerScale = containerWidth / containerHeight;
    
    CGFloat width = 0, height = 0, x = 0, y = 0 ;
    CGSize contentSize = CGSizeZero;
    width = containerWidth;
    height = containerWidth * (imageSize.height / imageSize.width);
    if (imageSize.width / imageSize.height >= containerScale) {
        x = 0;
        y = (containerHeight - height) / 2.0;
        contentSize = CGSizeMake(containerWidth, containerHeight);
        
    } else {
        x = 0;
        y = 0;
        contentSize = CGSizeMake(containerWidth, height);
    }
    if (completed) completed(CGRectMake(x, y, width, height), contentSize);
}
@end
