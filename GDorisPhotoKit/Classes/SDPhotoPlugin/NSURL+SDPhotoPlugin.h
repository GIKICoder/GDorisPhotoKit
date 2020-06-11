//
//  NSURL+SDPhotoPlugin.h
//  XCChat
//
//  Created by GIKI on 2020/3/8.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class PHAsset;
@interface NSURL (SDPhotoPlugin)

/**
 The localIdentifier value for Photos URL, or nil for other URL.
 */
@property (nonatomic, copy, readonly, nullable) NSString *sd_assetLocalIdentifier;

/**
 The `PHAsset` value for Photos URL, or nil for other URL, or the `PHAsset` is not availble.
 */
@property (nonatomic, strong, readonly, nullable) PHAsset *sd_asset;

/**
 Check whether the current URL represents Photos URL.
 */
@property (nonatomic, assign, readonly) BOOL sd_isPhotosURL;

/**
 Create a Photos URL with `PHAsset` 's local identifier

 @param identifier `PHAsset` 's local identifier
 @return A Photos URL
 */
+ (nullable instancetype)sd_URLWithAssetLocalIdentifier:(nonnull NSString *)identifier;

/**
 Create a Photos URL with `PHAsset`

 @param asset `PHAsset` object
 @return A Photos URL
 */
+ (nullable instancetype)sd_URLWithAsset:(nonnull PHAsset *)asset;
@end

NS_ASSUME_NONNULL_END
