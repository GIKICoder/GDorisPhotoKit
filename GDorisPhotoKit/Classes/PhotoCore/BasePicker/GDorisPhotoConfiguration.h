//
//  GDorisPhotoConfiguration.h
//  XCChat
//
//  Created by GIKI on 2020/3/22.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisPhotoAppearance.h"
#import "IGDorisPhotoPicker.h"
NS_ASSUME_NONNULL_BEGIN


@interface GDorisPhotoConfiguration : NSObject

/// photoKits UI 样式
@property (nonatomic, strong) GDorisPhotoAppearance * appearance;

/// 图片加载类
@property (nonatomic, strong) id<IGDorisPhotoLoader>  photoLoader;

/// 相册加载类
@property (nonatomic, strong) id<IGDorisAlbumLoader>  albumLoader;

///  相册展示类型 default：DorisAlbumContentTypeAll
@property (nonatomic, assign) DorisAlbumContentType  albumType;

/// 单选模式
@property (nonatomic, assign) BOOL  radioMode;

/// 获取相册图片的最大数量 0: 表示全部获取
@property (nonatomic, assign) NSInteger  fetchPhotoMaxCount;

///  第一次加载显示的数量,可快速加载显示. default:40 首屏数量
@property (nonatomic, assign) NSInteger  firstNeedsLoadCount;

/// 最大选择数量,与selectCountRegular 不同时生效
@property (nonatomic, assign) NSInteger  selectMaxCount;
/**
 DorisPhotoPicker 最大选择数量规则Map
 Default: nil
 @breif: Key:@(DorisPhotoRegularType) value:@(MaxCount)
 */
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> * selectCountRegular;

///  只可以选择一种资源 Default: NO
@property (nonatomic, assign) BOOL  onlySelectOneMediaType;

/// 当前仅可选择的类型 Default: DorisPhotoRegularTypeAll
@property (nonatomic, assign) DorisPhotoRegularType  onlyEnableSelectAssetType;

+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
