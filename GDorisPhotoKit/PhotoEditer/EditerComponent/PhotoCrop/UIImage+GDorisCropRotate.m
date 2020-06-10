//
//  UIImage+GDorisCropRotate.m
//  GDoris
//
//  Created by GIKI on 2018/9/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "UIImage+GDorisCropRotate.h"

@implementation UIImage (GDorisCropRotate)

- (BOOL)hasAlpha
{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)croppedImageWithFrame:(CGRect)frame angle:(NSInteger)angle circularClip:(BOOL)circular
{
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, ![self hasAlpha] && !circular, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (circular) {
            CGContextAddEllipseInRect(context, (CGRect){CGPointZero, frame.size});
            CGContextClip(context);
        }
        
        //To conserve memory in not needing to completely re-render the image re-rotated,
        //map the image to a view and then use Core Animation to manipulate its rotation
        if (angle != 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
            imageView.layer.minificationFilter = kCAFilterNearest;
            imageView.layer.magnificationFilter = kCAFilterNearest;
            imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * (M_PI/180.0f));
            CGRect rotatedRect = CGRectApplyAffineTransform(imageView.bounds, imageView.transform);
            UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, rotatedRect.size}];
            [containerView addSubview:imageView];
            imageView.center = containerView.center;
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [containerView.layer renderInContext:context];
        }
        else {
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [self drawAtPoint:CGPointZero];
        }
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:croppedImage.CGImage scale: self.scale orientation:UIImageOrientationUp];
}

@end
