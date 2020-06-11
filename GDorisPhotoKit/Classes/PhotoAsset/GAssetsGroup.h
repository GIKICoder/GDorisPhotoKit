//
//  GAssetsGroup.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/8/13.
//  Copyright © 2019 GIKI. All rights reserved.
//
//  Code Reference: https://github.com/Tencent/QMUI_iOS
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHImageManager.h>

NS_ASSUME_NONNULL_BEGIN


@class  GAsset;

/// 相册展示内容的类型
typedef NS_ENUM(NSUInteger,  GAlbumContentType) {
     GAlbumContentTypeAll,                                  // 展示所有资源
     GAlbumContentTypeOnlyPhoto,                            // 只展示照片
     GAlbumContentTypeOnlyVideo,                            // 只展示视频
     GAlbumContentTypeOnlyAudio                             // 只展示音频
};

/// 相册展示内容按日期排序的方式
typedef NS_ENUM(NSUInteger,  GAlbumSortType) {
     GAlbumSortTypePositive,  // 日期最新的内容排在后面
     GAlbumSortTypeReverse  // 日期最新的内容排在前面
};


@interface  GAssetsGroup : NSObject

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection;

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection fetchAssetsOptions:(PHFetchOptions *)pHFetchOptions;

/// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 的值
@property(nonatomic, strong, readonly) PHAssetCollection *phAssetCollection;

/// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 后，产生一个对应的 PHAssetsFetchResults 保存到 phFetchResult 中
@property(nonatomic, strong, readonly) PHFetchResult *phFetchResult;

/// 相册的名称
- (NSString *)name;

/// 相册内的资源数量，包括视频、图片、音频（如果支持）这些类型的所有资源
- (NSInteger)numberOfAssets;

/**
 *  相册的缩略图，即系统接口中的相册海报（Poster Image）
 *
 *  @return 相册的缩略图
 */
- (UIImage *)posterImageWithSize:(CGSize)size;

/// 获取前多少个相册资源
/// @param count 数量
/// @param albumSortType 排序方式
- (NSArray *)fetchTopCountAssets:(NSInteger)count sortType:(GAlbumSortType)albumSortType;

/**
 *  枚举相册内所有的资源
 *
 *  @param albumSortType    相册内资源的排序方式，可以选择日期最新的排在最前面，也可以选择日期最新的排在最后面
 *  @param enumerationBlock 枚举相册内资源时调用的 block，参数 result 表示每次枚举时对应的资源。
 *                          枚举所有资源结束后，enumerationBlock 会被再调用一次，这时 result 的值为 nil。
 *                          可以以此作为判断枚举结束的标记
 */
- (void)enumerateAssetsWithOptions:(GAlbumSortType)albumSortType usingBlock:(void (^)(GAsset *resultAsset))enumerationBlock;

/// 获取最新的相册资源
/// @param count 回去的数量
/// @param enumerationBlock <#enumerationBlock description#>
- (void)enumerateLasterAssetsWithCount:(NSInteger)count
                            usingBlock:(void (^)( GAsset *resultAsset))enumerationBlock;

/**
 *  枚举相册内所有的资源，相册内资源按日期最新的排在最后面
 *
 *  @param enumerationBlock 枚举相册内资源时调用的 block，参数 result 表示每次枚举时对应的资源。
 *                          枚举所有资源结束后，enumerationBlock 会被再调用一次，这时 result 的值为 nil。
 *                          可以以此作为判断枚举结束的标记
 */
- (void)enumerateAssetsUsingBlock:(void (^)(GAsset *result))enumerationBlock;

@end

NS_ASSUME_NONNULL_END
