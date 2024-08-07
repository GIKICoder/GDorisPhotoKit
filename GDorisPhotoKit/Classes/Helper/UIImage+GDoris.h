//
//  UIImage+GDoris.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/10.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (GDoris)

- (UIImage *)g_fixOrientation;

+ (UIImage *)g_imageNamed:(NSString *)name;
+ (UIImage *)g_imageNamedWithMain:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
