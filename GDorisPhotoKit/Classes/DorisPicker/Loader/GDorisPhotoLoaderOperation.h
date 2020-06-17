//
//  GDorisPhotoLoaderOperation.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//

#import "GDorisLoaderOperation.h"
#import "GAsset.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoLoaderOperation : GDorisLoaderOperation

+ (instancetype)photoWithAsset:(GAsset *)asset size:(CGSize)size;

@property (nonatomic, assign) CGSize  size;
@property (nonatomic, strong) GAsset * asset;
/// 获取ImageData
@property (nonatomic, assign) BOOL  fetchData;
@property(nonatomic, copy) void (^completion)(UIImage * image, NSError * error,NSString * idst);

@end

NS_ASSUME_NONNULL_END
