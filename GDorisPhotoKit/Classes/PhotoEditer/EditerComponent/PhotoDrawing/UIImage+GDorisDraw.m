//
//  UIImage+GDorisDraw.m
//  GDoris
//
//  Created by GIKI on 2018/10/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "UIImage+GDorisDraw.h"

@implementation UIImage (GDorisDraw)

- (UIImage *)mosaicLevel:(NSUInteger)level size:(CGSize)canvasSize
{
    if (@available(iOS 10.4, *)) {
        return  [self mosaicByCIImageLevel:level size:canvasSize];
    } else {
        return  [self mosaicByNormalLevel:level];
    }
}

- (UIImage *)mosaicByCIImageLevel:(NSUInteger)level size:(CGSize)canvasSize
{
    static CIContext *context = nil;
    if (context == nil) {
        context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
    }
    CIImage *ciImage = [CIImage imageWithCGImage:self.CGImage];
    ciImage = [ciImage imageByApplyingTransform:[self __preferredTransform]];
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeScale(canvasSize.width/ciImage.extent.size.width, canvasSize.height/ciImage.extent.size.height)];
    ciImage = [ciImage imageByApplyingOrientation:kCGImagePropertyOrientationDownMirrored];

    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage  forKey:kCIInputImageKey];
    [filter setValue:@(level) forKey:kCIInputScaleKey];
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[outImage extent]];
    UIImage *mosaicImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return mosaicImage;
}

- (UIImage *)mosaicByNormalLevel:(NSUInteger)level
{
    //1、这一部分是为了把原始图片转成位图，位图再转成可操作的数据
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//颜色通道
    CGImageRef imageRef = self.CGImage;//位图
    CGFloat width = CGImageGetWidth(imageRef);//位图宽
    CGFloat height = CGImageGetHeight(imageRef);//位图高
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);//生成上下文
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), imageRef);//绘制图片到上下文中
    unsigned char *bitmapData = CGBitmapContextGetData(context);//获取位图的数据
    
    
    //2、这一部分是往右往下填充色值
    NSUInteger index,preIndex;
    unsigned char pixel[4] = {0};
    for (int i = 0; i < height; i++) {//表示高，也可以说是行
        for (int j = 0; j < width; j++) {//表示宽，也可以说是列
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    //把当前的色值数据保存一份，开始为i=0，j=0，所以一开始会保留一份
                    memcpy(pixel, bitmapData + index * 4, 4);
                }else{
                    //把上一次保留的色值数据填充到当前的内存区域，这样就起到把前面数据往后挪的作用，也是往右填充
                    memcpy(bitmapData +index * 4, pixel, 4);
                }
            }else{
                //这里是把上一行的往下填充
                preIndex = (i - 1) * width + j;
                memcpy(bitmapData + index * 4, bitmapData + preIndex * 4, 4);
            }
        }
    }
    
    //把数据转回位图，再从位图转回UIImage
    NSUInteger dataLength = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              8,
                                              32,
                                              width*4 ,
                                              colorSpace,
                                              kCGBitmapByteOrderDefault,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       8,
                                                       width*4,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    CFRelease(resultImageRef);
    CFRelease(mosaicImageRef);
    CFRelease(colorSpace);
    CFRelease(provider);
    CFRelease(context);
    CFRelease(outputContext);
    return resultImage;
}

- (UIImage *)blurLevel:(NSInteger)level size:(CGSize)canvasSize
{
    if (@available(iOS 10.4, *)) {
        
        static CIContext *context = nil;
        if (context == nil) {
            context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
        }
        CIImage *ciImage = [CIImage imageWithCGImage:self.CGImage];
        ciImage = [ciImage imageByApplyingTransform:[self __preferredTransform]];
        ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeScale(canvasSize.width/ciImage.extent.size.width, canvasSize.height/ciImage.extent.size.height)];
        ciImage = [ciImage imageByApplyingOrientation:kCGImagePropertyOrientationDownMirrored];
        
        
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [filter setValue:ciImage forKey:kCIInputImageKey];
        // 指定模糊值 默认为10, 范围为0-100
        [filter setValue:[NSNumber numberWithFloat:level] forKey:@"inputRadius"];
        
        // 创建输出
        CIImage *result = [filter valueForKey:kCIOutputImageKey];
        CGImageRef outImage = [context createCGImage: result fromRect:[ciImage extent]];
        UIImage * blurImage = [UIImage imageWithCGImage:outImage];
        CGImageRelease(outImage);
        return blurImage;
    } else {
        return  [self mosaicByNormalLevel:level];
    }
   
}



/// transform method
- (CGAffineTransform)__preferredTransform
{
    if (self.imageOrientation == UIImageOrientationUp) {
        return CGAffineTransformIdentity;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize imageSize = CGSizeMake(self.size.width*self.scale, self.size.height*self.scale);
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, imageSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    return transform;
}

@end
