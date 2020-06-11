//
//  GDorisPhotoPickerBrowserController.h
//  XCChat
//
//  Created by GIKI on 2020/4/4.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisPhotoBrowserBaseController.h"

NS_ASSUME_NONNULL_BEGIN
@class GDorisPhotoPickerBrowserController,GDorisPhotoPickerBean;
@protocol GDorisPhotoPickerBrowserDelegate <NSObject>

@optional
/**
 选择相册资源完成后回调
 
 @param browser GDorisPhotoPickerBrowserController
 @param photos NSArray<GDorisPhotoPickerBean *>
 */
- (void)dorisPhotoBrowser:(GDorisPhotoPickerBrowserController *)browser didFinishPickerPhotos:(NSArray *)photos;

/**
 取消图片预览控制器
 
 @param browser GDorisPhotoPickerBrowserController
 */
- (void)dorisPhotoBrowserDidCancel:(GDorisPhotoPickerBrowserController *)browser;

/**
 判断资源是否可选择
 
 @param browser GDorisPhotoPickerBrowserController
 @param bean GDorisPhotoPickerBean
 @return 是否可选中
 */
- (BOOL)dorisPhotoBrowser:(GDorisPhotoPickerBrowserController *)browser shouldSelectPhoto:(GDorisPhotoPickerBean *)bean;

/**
 选择相册资源
 
 @param browser GDorisPhotoPickerBrowserController
 @param bean GDorisPhotoPickerBean
 */
- (void)dorisPhotoBrowser:(GDorisPhotoPickerBrowserController *)browser didSelectPhoto:(GDorisPhotoPickerBean *)bean;

/**
 取消选中相册资源
 
 @param browser GDorisPhotoPickerBrowserController
 @param bean GDorisPhotoPickerBean
 */
- (void)dorisPhotoBrowser:(GDorisPhotoPickerBrowserController *)browser didDeselectPhoto:(GDorisPhotoPickerBean *)bean;

/**
 获取已经选中的相册资源

 @param browser GDorisPhotoPickerBrowserController
 @return selectItems
 */
- (NSArray<GDorisPhotoPickerBean *> *)dorisPhotoBrowserSelectedPhotos:(GDorisPhotoPickerBrowserController *)browser;
@end

@interface GDorisPhotoPickerBrowserController : GDorisPhotoBrowserBaseController

@property (nonatomic, weak  ) id<GDorisPhotoPickerBrowserDelegate>   delegate;

@end

NS_ASSUME_NONNULL_END
