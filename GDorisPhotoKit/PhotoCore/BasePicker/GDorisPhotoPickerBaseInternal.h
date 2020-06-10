//
//  GDorisPhotoPickerBaseInternal.h
//  GDoris
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerBean.h"
#import "GDorisPhotoPickerBaseController.h"
#import "GDorisPhotoZoomAnimatedTransition.h"

@interface GDorisPhotoPickerBaseController ()

@property (nonatomic, strong) GDorisPhotoZoomAnimatedTransition * transition;

@property (nonatomic, strong) NSIndexPath * clickIndexPath;

@property (nonatomic, strong, readonly) NSArray * photoDatas;

@property (nonatomic, strong, readonly) NSArray * selectDatas;
/// 相册加载类
@property (nonatomic, strong, readonly) id<IGDorisAlbumLoader>  albumLoader;

- (void)doris_loadDefaultAlbums;

- (void)reloadPhotoUI;

- (BOOL)doris_canSelectAsset:(GDorisPhotoPickerBean *)object;

- (void)doris_didSelectAsset:(GDorisPhotoPickerBean *)object;

- (void)doris_didDeselectAsset:(GDorisPhotoPickerBean *)object;

@end
