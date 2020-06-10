//
//  SDPhotosLoader.h
//  XCChat
//
//  Created by GIKI on 2020/3/8.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
@import SDWebImage;
#endif
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDPhotosLoader : NSObject<SDImageLoader>

/**
 The global shared instance for Photos loader.
 */
@property (nonatomic, class, readonly, nonnull) SDPhotosLoader *sharedLoader;

/**
 The default `fetchOptions` used for PHAsset fetch with the localIdentifier.
 Defaults to nil.
 */
@property (nonatomic, strong, nullable) PHFetchOptions *fetchOptions;

/**
 The default `imageRequestOptions` used for image asset request.
 Defatuls value are these:
 networkAccessAllowed = YES;
 resizeMode = PHImageRequestOptionsResizeModeFast;
 deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
 version = PHImageRequestOptionsVersionCurrent;
 */
@property (nonatomic, strong, nullable) PHImageRequestOptions *imageRequestOptions;

/**
 Whether we request only `PHAssetMediaTypeImage` asset and ignore other types (video/audio/unknown).
 When we found other type, an error `SDWebImagePhotosErrorNotImageAsset` will be reported.
 Defaults to YES. If you prefer to load other type like video asset's poster image, set this value to NO.
 */
@property (nonatomic, assign) BOOL requestImageAssetOnly;


@end

NS_ASSUME_NONNULL_END
