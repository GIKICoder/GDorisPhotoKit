//
//  GDorisPickerBrowserLoader.m
//  GDoris
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPickerBrowserLoader.h"
#import "GDorisBrowserBaseCell.h"
#import "GAsset.h"
#import <SDWebImageYYPlugin/SDWebImageYYPlugin.h>
#import "SDPhotosPlugin.h"
#import "GDorisPickerBrowserCell.h"
#import "GDorisPhotoPickerBean.h"
#import "GDorisPickerBrowserVideoCell.h"
@implementation GDorisPickerBrowserLoader

- (NSArray<NSString *> *)registerBrowserCellClass
{
    return @[
        NSStringFromClass(GDorisPickerBrowserCell.class),
        NSStringFromClass(GDorisPickerBrowserVideoCell.class)
    ];
}

- (NSString *)generateBrowerCellClassIdentify:(GDorisPhotoPickerBean *)object
{
    GAsset * asset = object.asset;
    if (asset && [asset isKindOfClass:GAsset.class] && asset.assetType == GAssetTypeVideo) {
        return NSStringFromClass(GDorisPickerBrowserVideoCell.class);
    }
    return NSStringFromClass(GDorisPickerBrowserCell.class);
}

- (void)loadPhotoData:(id)object
                 cell:(UICollectionViewCell<IGDorisBrowerCellProtocol> *)cell
            imageView:(__kindof UIImageView *)imageView
           completion:(void (^)(UIImage * image, NSError * error))completion
{
    GDorisPhotoPickerBean * pickerBean = (id)object;
    GAsset * asset = pickerBean.asset;
    if (!asset || ![asset isKindOfClass:GAsset.class]) {
        return;
    }
    GDorisPickerBrowserCell * browserCell = (id)cell;
    BOOL isGif = (asset.assetSubType == GAssetSubTypeGIF);
    
    __weak __typeof(browserCell) weakCell = browserCell;
    __weak __typeof(imageView) weakView = imageView;
    CGSize size = asset.imageSize;
    if (asset.assetSubType != GAssetSubTypeGIF) {
        [browserCell fitImageSize:size containerSize:browserCell.scrollView.bounds.size completed:^(CGRect containerFrame, CGSize scrollContentSize) {
            weakCell.scrollView.contentSize = scrollContentSize;
            weakCell.scrollSize = scrollContentSize;
            // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
            weakView.frame = CGRectApplyAffineTransform(containerFrame, weakView.transform);
        }];
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    CGSize tzsize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (size.width && !isnan(size.width) && size.height && !isnan(size.height)) {
        tzsize = size;
    }
    PHAsset * ph_asset = asset.phAsset;
    NSURL * URL = [NSURL sd_URLWithAsset:ph_asset];
    imageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteIndicator;
    
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    imageRequestOptions.sd_targetSize = tzsize;
    NSMutableDictionary * context = [NSMutableDictionary new];
    context[SDWebImageContextStoreCacheType] = @(SDImageCacheTypeNone);
    context[SDWebImageContextPhotosImageRequestOptions] = imageRequestOptions;
    if (isGif) {
        context[SDWebImageContextPhotosRequestImageData] = @(YES);
        context[SDWebImageContextAnimatedImageClass] = YYImage.class;
        [imageView sd_setImageWithURL:URL placeholderImage:nil options:kNilOptions context:context progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakCell fitImageSize:image.size containerSize:weakCell.scrollView.bounds.size completed:^(CGRect containerFrame, CGSize scrollContentSize) {
                    weakCell.scrollView.contentSize = scrollContentSize;
                    weakCell.scrollSize = scrollContentSize;
                    // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
                    weakView.frame = CGRectApplyAffineTransform(containerFrame, weakView.transform);
                }];
            });
        }];
    } else {
        context[SDWebImageContextPhotosRequestImageData] = @(NO);
        [imageView sd_setImageWithURL:URL placeholderImage:nil options:kNilOptions context:context progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
        }];
    }
}


- (void)loadVideoItem:(id)object completion:(void (^)(AVPlayerItem * item, NSError * error))completion
{
    GDorisPhotoPickerBean * pickerBean = (id)object;
       GAsset * asset = pickerBean.asset;
       if (!asset || ![asset isKindOfClass:GAsset.class]) {
           return;
       }
    [asset requestPlayerItemWithCompletion:^(AVPlayerItem * _Nonnull playerItem, NSDictionary<NSString *,id> * _Nonnull info) {
        if (completion) {
            completion(playerItem,nil);
        }
    } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    }];
}
@end
