//
//  IGDorisPhotoPickerDelegate.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/3.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCAsset.h"
NS_ASSUME_NONNULL_BEGIN

@class GDorisPhotoPickerController;
@protocol IGDorisPhotoPickerDelegate <NSObject>
@optional

/**
 选择相册资源完成后回调

 @param picker GDorisPhotoPickerController
 @param assets NSArray<XCAsset *>
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker didFinishPickingAssets:(NSArray<XCAsset *> *)assets;

/**
 取消相册资源选择控制器

 @param picker GDorisPhotoPickerController
 */
- (void)dorisPhotoPickerDidCancel:(GDorisPhotoPickerController *)picker;

/**
 判断资源是否可选择

 @param picker GDorisPhotoPickerController
 @param asset XCAsset
 @return 是否可选中
 */
- (BOOL)dorisPhotoPicker:(GDorisPhotoPickerController *)picker shouldSelectAsset:(XCAsset *)asset;

/**
 选择相册资源

 @param picker GDorisPhotoPickerController
 @param asset XCAsset
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker didSelectAsset:(XCAsset *)asset;

/**
 取消选中相册资源

 @param picker GDorisPhotoPickerController
 @param asset XCAsset
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker didDeselectAsset:(XCAsset *)asset;

/**
 选中的asset资源改变时回调

 @param picker picker description
 @param assets assets description
 */
- (void)dorisPhotoPicker:(GDorisPhotoPickerController *)picker selectItemsChanged:(NSArray<XCAsset *> *)assets;
@end

NS_ASSUME_NONNULL_END
