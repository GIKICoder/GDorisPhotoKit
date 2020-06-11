//
//  GAssetsManager.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/8/13.
//  Copyright © 2019 GIKI. All rights reserved.
//
//  Code Reference: https://github.com/Tencent/QMUI_iOS

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHAssetChangeRequest.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHImageManager.h>
#import <Photos/PHAssetCreationRequest.h>
#import "GAssetsGroup.h"
#import "GAsset.h"
NS_ASSUME_NONNULL_BEGIN


@class PHCachingImageManager;
@class  GAsset;

/// Asset 授权的状态
typedef NS_ENUM(NSUInteger,  GAssetAuthorizationStatus) {
     GAssetAuthorizationStatusNotDetermined,      // 还不确定有没有授权
     GAssetAuthorizationStatusAuthorized,         // 已经授权
     GAssetAuthorizationStatusNotAuthorized       // 手动禁止了授权
};

typedef void (^XCWriteAssetCompletionBlock)(GAsset * __nullable asset, NSError * __nullable error);


/// 保存图片到指定相册（传入 UIImage）
extern void GImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(UIImage *image,  GAssetsGroup *albumAssetsGroup, XCWriteAssetCompletionBlock completionBlock);

/// 保存图片到指定相册（传入图片路径）
extern void GSaveImageAtPathToSavedPhotosAlbumWithAlbumAssetsGroup(NSString *imagePath,  GAssetsGroup *albumAssetsGroup, XCWriteAssetCompletionBlock completionBlock);

/// 保存视频到指定相册
extern void GSaveVideoAtPathToSavedPhotosAlbumWithAlbumAssetsGroup(NSString *videoPath,  GAssetsGroup *albumAssetsGroup, XCWriteAssetCompletionBlock completionBlock);

/**
 *  构建  GAssetsManager 这个对象并提供单例的调用方式主要出于下面两点考虑：
 *  1. 保存照片/视频的方法较为复杂，为了方便封装系统接口，同时灵活地扩展功能，需要有一个独立对象去管理这些方法。
 *  2. 使用 PhotoKit 获取图片，基本都需要一个 PHCachingImageManager 的实例，为了减少消耗，
 *      GAssetsManager 单例内部也构建了一个 PHCachingImageManager，并且暴露给外面，方便获取
 *     PHCachingImageManager 的实例。
 */
@interface  GAssetsManager : NSObject

/// 获取  GAssetsManager 的单例
+ (instancetype)sharedInstance;

/// 获取当前应用的“照片”访问授权状态
+ ( GAssetAuthorizationStatus)authorizationStatus;

/**
 *  调起系统询问是否授权访问“照片”的 UIAlertView
 *  @param handler 授权结束后调用的 block，默认不在主线程上执行，如果需要在 block 中修改 UI，记得 dispatch 到 mainqueue
 */
+ (void)requestAuthorization:(void(^)( GAssetAuthorizationStatus status))handler;

/// 获取系统相册
/// @param contentType <#contentType description#>
- (GAssetsGroup *)fetchSystemAlbumWithContentType:( GAlbumContentType)contentType;

/// 获取全部相册
/// @param contentType <#contentType description#>
/// @param showEmptyAlbum <#showEmptyAlbum description#>
/// @param showSmartAlbum <#showSmartAlbum description#>
- (NSArray<GAssetsGroup *> *)fetchAllAlbumsWithAlbumContentType:(GAlbumContentType)contentType showEmptyAlbum:(BOOL)showEmptyAlbum showSmartAlbum:(BOOL)showSmartAlbum;

/**
 *  获取所有的相册，包括个人收藏，最近添加，自拍这类“智能相册”
 *
 *  @param contentType               相册的内容类型，设定了内容类型后，所获取的相册中只包含对应类型的资源
 *  @param showEmptyAlbum            是否显示空相册（经过 contentType 过滤后仍为空的相册）
 *  @param showSmartAlbumIfSupported 是否显示"智能相册"
 *  @param enumerationBlock          参数 resultAssetsGroup 表示每次枚举时对应的相册。枚举所有相册结束后，enumerationBlock 会被再调用一次，
 *                                   这时 resultAssetsGroup 的值为 nil。可以以此作为判断枚举结束的标记。
 */
- (void)enumerateAllAlbumsWithAlbumContentType:(GAlbumContentType)contentType showEmptyAlbum:(BOOL)showEmptyAlbum showSmartAlbumIfSupported:(BOOL)showSmartAlbumIfSupported usingBlock:(void (^)(GAssetsGroup *resultAssetsGroup))enumerationBlock;

/// 获取所有相册，默认显示系统的“智能相册”，不显示空相册（经过 contentType 过滤后为空的相册）
- (void)enumerateAllAlbumsWithAlbumContentType:(GAlbumContentType)contentType usingBlock:(void (^)(GAssetsGroup *resultAssetsGroup))enumerationBlock;

/**
 *  保存图片或视频到指定的相册
 *
 *  @warning 无论用户保存到哪个自行创建的相册，系统都会在“相机胶卷”相册中同时保存这个图片。
 *           因为系统没有把图片和视频直接保存到指定相册的接口，都只能先保存到“相机胶卷”，从而生成了 Asset 对象，
 *           再把 Asset 对象添加到指定相册中，从而达到保存资源到指定相册的效果。
 *           即使调用 PhotoKit 保存图片或视频到指定相册的新接口也是如此，并且官方 PhotoKit SampleCode 中例子也是表现如此，
 *           因此这应该是一个合符官方预期的表现。
 *  @warning 无法通过该方法把图片保存到“智能相册”，“智能相册”只能由系统控制资源的增删。
 */
- (void)saveImageWithImageRef:(CGImageRef)imageRef albumAssetsGroup:(GAssetsGroup * __nullable)albumAssetsGroup orientation:(UIImageOrientation)orientation completionBlock:(XCWriteAssetCompletionBlock)completionBlock;

- (void)saveImageWithImagePathURL:(NSURL *)imagePathURL albumAssetsGroup:(GAssetsGroup * __nullable)albumAssetsGroup completionBlock:(XCWriteAssetCompletionBlock)completionBlock;

- (void)saveVideoWithVideoPathURL:(NSURL *)videoPathURL albumAssetsGroup:(GAssetsGroup * __nullable)albumAssetsGroup completionBlock:(XCWriteAssetCompletionBlock)completionBlock;

/**
 保存imageData 到相册
 */
- (void)saveImageWithImageData:(NSData *)imageData
             completionHandler:(void(^)(BOOL success, NSDate *creationDate, NSError *error))completionHandler;

/// 根据phasset_id 获取一个GAsset
/// @param localIdentifier phasset id
- (GAsset *)fetchAssetWithLocalIdentifier:(NSString *)localIdentifier;

/// 获取一个 PHCachingImageManager 的实例
- (PHCachingImageManager *)phCachingImageManager;

@end


@interface PHPhotoLibrary (XCUtils)

/**
 *  根据 contentType 的值产生一个合适的 PHFetchOptions，并把内容以资源创建日期排序，创建日期较新的资源排在前面
 *
 *  @param contentType 相册的内容类型
 *
 *  @return 返回一个合适的 PHFetchOptions
 */
+ (PHFetchOptions *)createFetchOptionsWithAlbumContentType:( GAlbumContentType)contentType;

/**
 *  获取所有相册
 *
 *  @param contentType    相册的内容类型，设定了内容类型后，所获取的相册中只包含对应类型的资源
 *  @param showEmptyAlbum 是否显示空相册（经过 contentType 过滤后仍为空的相册）
 *  @param showSmartAlbum 是否显示“智能相册”
 *
 *  @return 返回包含所有合适相册的数组
 */
+ (NSArray *)fetchAllAlbumsWithAlbumContentType:( GAlbumContentType)contentType showEmptyAlbum:(BOOL)showEmptyAlbum showSmartAlbum:(BOOL)showSmartAlbum;

/// 获取一个 PHAssetCollection 中创建日期最新的资源
+ (PHAsset *)fetchLatestAssetWithAssetCollection:(PHAssetCollection *)assetCollection;

/**
 *  保存图片或视频到指定的相册
 *
 *  @warning 无论用户保存到哪个自行创建的相册，系统都会在“相机胶卷”相册中同时保存这个图片。
 *           原因请参考  GAssetsManager 对象的保存图片和视频方法的注释。
 *  @warning 无法通过该方法把图片保存到“智能相册”，“智能相册”只能由系统控制资源的增删。
 */
- (void)addImageToAlbum:(CGImageRef)imageRef albumAssetCollection:(PHAssetCollection *)albumAssetCollection orientation:(UIImageOrientation)orientation completionHandler:(void(^)(BOOL success, NSDate *creationDate, NSError *error))completionHandler;

- (void)addImageToAlbum:(NSURL *)imagePathURL albumAssetCollection:(PHAssetCollection *)albumAssetCollection completionHandler:(void(^)(BOOL success, NSDate *creationDate, NSError *error))completionHandler;

- (void)addVideoToAlbum:(NSURL *)videoPathURL albumAssetCollection:(PHAssetCollection *)albumAssetCollection completionHandler:(void(^)(BOOL success, NSDate *creationDate, NSError *error))completionHandler;

@end


NS_ASSUME_NONNULL_END
