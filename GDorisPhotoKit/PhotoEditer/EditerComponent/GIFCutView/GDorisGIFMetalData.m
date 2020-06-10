//
//  GDorisGIFMetalData.m
//  XCChat
//
//  Created by GIKI on 2020/1/20.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisGIFMetalData.h"
#import <ImageIO/ImageIO.h>

@interface GDorisGIFMetalData ()

@property (nonatomic, strong) NSData * gifData;

@end
@implementation GDorisGIFMetalData

- (instancetype)initWithGifData:(NSData *)gifData
{
    self = [super init];
    if (self) {
        self.gifData = gifData;
        [self setupData];
    }
    return self;
}

- (instancetype)initWithGifPath:(NSString *)gifPath
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL fileURLWithPath:gifPath];
        NSData * data = [NSData dataWithContentsOfURL:url];
        self.gifData = data;
        [self setupData];
    }
    return self;
}

- (void)setupData {
   
    NSData * data = self.gifData;
    if (!data || ![data isKindOfClass:NSData.class]) {
        return;
    }
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                      (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @NO});
    //获取gif的帧数
    size_t frameCount = CGImageSourceGetCount(gifSource);
    _frameCount = frameCount;
    
    //获取GfiImage的基本数据
    NSDictionary *gifProperties = (__bridge NSDictionary *) CGImageSourceCopyProperties(gifSource, NULL);
    //由GfiImage的基本数据获取gif数据
    NSDictionary *gifDictionary =[gifProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
    //获取gif的播放次数 0-无限播放
    _loopCount = [[gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFLoopCount] integerValue];
    CFRelease((__bridge CFTypeRef)(gifProperties));
    
    NSMutableArray *frameImages = [NSMutableArray new];
    NSMutableArray *delayTimes = [NSMutableArray new];
    
    for (size_t i = 0; i < frameCount; ++i) {
        //得到每一帧的CGImage
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frameImages addObject:[UIImage imageWithCGImage:frame]];
        CGImageRelease(frame);
        
        //获取每一帧的图片信息
        NSDictionary *frameDict = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
        
        //获取Gif图片尺寸
        _width = [[frameDict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
        _height = [[frameDict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        
        //由每一帧的图片信息获取gif信息
        NSDictionary *gifDict = [frameDict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        //取出每一帧的delaytime
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        _totalTime = _totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        
        CFRelease((__bridge CFTypeRef)(frameDict));
    }
    _images = [frameImages copy];
    _delayTimes = [delayTimes copy];
    CFRelease(gifSource);
}


@end
