//
//  UIImageView+GDorisLoader.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//

#import <UIKit/UIKit.h>
#import "GAsset.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (GDorisLoader)

- (void)doris_loadPhotoWithAsset:(GAsset *)asset size:(CGSize)size completion:(void (^)(UIImage * result, NSError * error))completion;
- (void)doris_loadPhotoDataWithAsset:(GAsset *)asset completion:(void (^)(NSData * result, BOOL isGIF, NSError * error))completion;

@end

NS_ASSUME_NONNULL_END
