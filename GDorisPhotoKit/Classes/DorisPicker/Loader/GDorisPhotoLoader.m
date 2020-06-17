//
//  GDorisPhotoLoader.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/25.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoLoader.h"
#import "GAsset.h"
#import <SDWebImage/SDWebImage.h>
#import "SDPhotosPlugin.h"
#import "GDorisPhotoPickerCell.h"
#import "GDorisPhotoCameraCell.h"
#import "GDorisPhotoConfiguration.h"
#import "UIImageView+GDorisLoader.h"
#import "Conductor.h"
#import "ConductorInner.h"
/// 是否是小屏幕
#define PHOTO_LOADER_SCREEN_SMALL      ([UIScreen mainScreen].currentMode.size.width <= 640 ? YES : NO)

@interface GDorisPhotoLoader ()
@property (nonatomic, weak  ) GDorisPhotoConfiguration * configuration;
@property (nonatomic, assign) CGFloat  cellWidth;
@end

@implementation GDorisPhotoLoader


- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat cellWidth = floor((width - 0 - 0 - (4 * (4-1))) / 4);
        self.cellWidth = cellWidth;
        CGFloat scale = [[UIScreen mainScreen] nativeScale];
        CGSize size = CGSizeMake(cellWidth*scale, cellWidth*scale);
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        imageRequestOptions.networkAccessAllowed = YES;
        imageRequestOptions.sd_targetSize = size;
        imageRequestOptions.sd_contentMode = PHImageContentModeAspectFill;
        SDPhotosLoader.sharedLoader.imageRequestOptions = imageRequestOptions;
        // Request Video Asset Poster as well
        SDPhotosLoader.sharedLoader.requestImageAssetOnly = NO;
        
        CDOperationQueue *serialQueue = [CDOperationQueue queueWithName:CONDUCTOR_APP_QUEUE];
        [serialQueue setMaxConcurrentOperationCount:4];
        [[CDQueueController sharedInstance] addQueue:serialQueue];
    }
    return self;
}

- (void)loadPhotoData:(__kindof UIImageView *)imageView withObject:(GDorisPhotoPickerBean *)object
{
    [self doris_loadPhotoData:imageView withObject:object];
    return;
    [self sd_loadPhotoData:imageView withObject:object];
}

- (void)sd_loadPhotoData:(__kindof UIImageView *)imageView withObject:(GDorisPhotoPickerBean *)object
{
    GAsset * asset = object.asset;
    PHAsset * ph_asset = asset.phAsset;
    NSURL * URL = [NSURL sd_URLWithAsset:ph_asset];
    /// Cause memory leak
    //    imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayIndicator;
    NSMutableDictionary * context = [NSMutableDictionary new];
    context[SDWebImageContextPhotosRequestImageData] = @(NO);
    context[SDWebImageContextStoreCacheType] = @(SDImageCacheTypeNone);
    [imageView sd_setImageWithURL:URL
                 placeholderImage:nil
                          options:0
                          context:context.copy];
}


- (void)doris_loadPhotoData:(__kindof UIImageView *)imageView withObject:(GDorisPhotoPickerBean *)object
{
    [imageView doris_loadPhotoWithAsset:object.asset completion:^(UIImage * _Nonnull result, NSError * _Nonnull error) {
        
    }];
}


- (nonnull NSString *)generateCellClassIdentify:(nonnull GDorisPhotoPickerBean *)assetObject {
    
    if (assetObject.isCamera) {
        return NSStringFromClass(GDorisPhotoCameraCell.class);
    } else {
        return NSStringFromClass(GDorisPhotoPickerCell.class);
    }
}


- (nonnull NSArray<NSString *> *)registerCellClass {
    return @[NSStringFromClass(GDorisPhotoPickerCell.class),
             NSStringFromClass(GDorisPhotoCameraCell.class)];
}

/// 获取照片标签数据
/// @param object <#object description#>
/// @return @{@"TagType" : @(GDorisPhotoTagType),@"TagMsg" : @"GIF"}
- (NSDictionary *)generatePhotoTagData:(GDorisPhotoPickerBean *)object
{
    GAsset * asset = object.asset;
    if (asset.assetType == GAssetTypeVideo) {
        NSTimeInterval timeInterval = asset.duration;//获取需要转换的timeinterval
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter *formatter = [self videoFormatter];
        NSString *dateString = [formatter stringFromDate:date] ? : @"";
        return @{
            @"TagType" : @(GDorisPhotoType_video),
            @"TagMsg" : dateString
        };
    }
    if (asset.assetSubType == GAssetSubTypeGIF) {
        return @{
            @"TagType" : @(GDorisPhotoType_GIF),
            @"TagMsg" : @"GIF"
        };
    }
    if (asset.isLongImage) {
        return @{
            @"TagType" : @(GDorisPhotoType_long),
            @"TagMsg" : @"长图"
        };
    }
    return @{};
}

- (NSDateFormatter *)videoFormatter
{
    static NSDateFormatter * INST = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        INST = [[NSDateFormatter alloc] init];
        INST.dateFormat = @"mm:ss";
    });
    return INST;
}


@end
