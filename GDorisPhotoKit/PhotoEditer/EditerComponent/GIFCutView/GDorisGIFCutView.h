//
//  GDorisGIFCutView.h
//  XCChat
//
//  Created by GIKI on 2020/1/20.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "GDorisGIFMetalData.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisGIFCutView : UIView

- (instancetype)initWithAnimationImage:(FLAnimatedImage *)image;
- (instancetype)initWithGIFMetalData:(GDorisGIFMetalData *)metalData;
@end

NS_ASSUME_NONNULL_END
