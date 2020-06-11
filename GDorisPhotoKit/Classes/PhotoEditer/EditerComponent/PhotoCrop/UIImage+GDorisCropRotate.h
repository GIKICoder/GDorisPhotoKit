//
//  UIImage+GDorisCropRotate.h
//  GDoris
//
//  Created by GIKI on 2018/9/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//
//  Code Reference: https://github.com/TimOliver/TOCropViewController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (GDorisCropRotate)

- (nonnull UIImage *)croppedImageWithFrame:(CGRect)frame angle:(NSInteger)angle circularClip:(BOOL)circular;

@end

NS_ASSUME_NONNULL_END
