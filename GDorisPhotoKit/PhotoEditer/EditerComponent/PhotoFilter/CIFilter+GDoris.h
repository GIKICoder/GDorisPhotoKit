//
//  CIFilter+GDoris.h
//  XCChat
//
//  Created by GIKI on 2020/1/19.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIFilter (GDoris)

+ (CIFilter *)colorCubeWithLUTImageNamed:(NSString *)imageName dimension:(NSInteger)n;

@end

NS_ASSUME_NONNULL_END
