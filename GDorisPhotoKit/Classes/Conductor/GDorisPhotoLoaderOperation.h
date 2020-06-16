//
//  GDorisPhotoLoaderOperation.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//

#import "CDKVOOperation.h"
#import "GAsset.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoLoaderOperation : CDOperation

@property (nonatomic, strong) GAsset * asset;
@property(nonatomic, copy) void (^completion)(UIImage * image, NSError * error);
@end

NS_ASSUME_NONNULL_END
