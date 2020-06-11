//
//  IGDorisPhotoPickerDelegate.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/3.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAsset.h"
NS_ASSUME_NONNULL_BEGIN

@class GDorisPhotoPickerController;
@protocol IGDorisPhotoPickerDelegate <NSObject>
@optional

/**
 选择相册资源完成后回调

 @param picker GDorisPhotoPickerController
 @param assets NSArray<GAsset *>
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker didFinishPickingAssets:(NSArray<GAsset *> *)assets;

/**
 取消相册资源选择控制器

 @param picker GDorisPhotoPickerController
 */
- (void)dorisPhotoPickerDidCancel:(GDorisPhotoPickerController *)picker;

/**
 判断资源是否可选择

 @param picker GDorisPhotoPickerController
 @param asset GAsset
 @return 是否可选中
 */
- (BOOL)dorisPhotoPicker:(GDorisPhotoPickerController *)picker shouldSelectAsset:(GAsset *)asset;

/**
 选择相册资源

 @param picker GDorisPhotoPickerController
 @param asset GAsset
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker didSelectAsset:(GAsset *)asset;

/**
 取消选中相册资源

 @param picker GDorisPhotoPickerController
 @param asset GAsset
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker didDeselectAsset:(GAsset *)asset;

/**
 选中的asset资源改变时回调

 @param picker picker description
 @param assets assets description
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker selectItemsChanged:(NSArray<GAsset *> *)assets;
@end

NS_ASSUME_NONNULL_END
