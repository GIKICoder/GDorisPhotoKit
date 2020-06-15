//
//  GDorisGIFMetalData.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/1/20.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface GDorisGIFMetalData : NSObject

@property (copy, nonatomic, readonly) NSArray *images; ///< 图片数组
@property (copy, nonatomic, readonly) NSArray *delayTimes; ///< 每帧图的延迟
@property (assign, nonatomic, readonly) size_t frameCount; ///< 帧数
@property (assign, nonatomic, readonly) NSInteger loopCount; ///< 循环次数
@property (assign, nonatomic, readonly) NSTimeInterval totalTime; ///< 播放总时长
@property (assign, nonatomic, readonly) CGFloat width; ///< 图片宽度
@property (assign, nonatomic, readonly) CGFloat height; ///< 图片高度

- (instancetype)initWithGifData:(NSData *)gifData;
- (instancetype)initWithGifPath:(NSString *)gifPath;

@end

NS_ASSUME_NONNULL_END
