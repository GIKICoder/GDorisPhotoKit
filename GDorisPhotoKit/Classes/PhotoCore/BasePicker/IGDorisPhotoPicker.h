//
//  IGDorisPhotoPicker.h
//  GDoris
//
//  Created by GIKI on 2020/3/25.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerBean.h"
NS_ASSUME_NONNULL_BEGIN
@class GDorisPhotoPickerBaseController,GDorisPhotoConfiguration;

typedef NS_ENUM(NSUInteger, GDorisPhotoTagType) {
    GDorisPhotoType_normal = 0,
    GDorisPhotoType_video,
    GDorisPhotoType_GIF,
    GDorisPhotoType_long
};

@protocol IGDorisPhotoLoader <NSObject>

@required
- (NSArray<NSString *> *)registerCellClass;
- (NSString *)generateCellClassIdentify:(GDorisPhotoPickerBean *)object;
- (void)loadPhotoData:(__kindof UIImageView *)imageView withObject:(GDorisPhotoPickerBean *)object;

@optional

/// 获取照片标签数据
/// @param object <#object description#>
/// @return @{@"TagType" : @(GDorisPhotoTagType),@"TagMsg" : @"GIF"}
- (NSDictionary *)generatePhotoTagData:(GDorisPhotoPickerBean *)object;

@end

@protocol IGDorisAlbumLoader <NSObject>

@required
@property (nonatomic, strong) NSArray * albumDatas;
@property (nonatomic, strong) NSArray * photoDatas;

/// 加载相册列表
/// @param configuration <#configuration description#>
/// @param quick <#quick description#>
/// @param completion <#completion description#>
- (void)loadAlbumDatas:(GDorisPhotoConfiguration *)configuration
                 quick:(BOOL (^)(NSArray * collections))quick
            completion:(void (^)(NSArray * collections))completion;

/// 加载相册下的图片
/// @param configuration <#configuration description#>
/// @param collection <#collection description#>
/// @param quick <#quick description#>
/// @param completion <#completion description#>
- (void)loadPhotos:(GDorisPhotoConfiguration *)configuration
        collection:(id)collection
             quick:(BOOL (^)(NSArray * assets))quick
        completion:(void (^)(NSArray * assets))completion;

/// 获取选中的相册资源
- (NSArray<GDorisPhotoPickerBean *> *)fetchSelectObjects;

/// 是否获取相册权限
- (BOOL)photoAuthorizationStatusAuthorized;

@optional
/// 检查照片是否可以被选中
/// @param object GDorisPhotoPickerBean
/// @param config GDorisPhotoConfiguration
- (BOOL)checkPhotoCanSelected:(GDorisPhotoPickerBean *)object config:(GDorisPhotoConfiguration *)config;

/// 处理照片选中
/// @param object <#object description#>
/// @param config <#config description#>
/// @brief 如果未实现,picker中有默认实现
- (NSArray *)photoDidSelected:(GDorisPhotoPickerBean *)object config:(GDorisPhotoConfiguration *)config;

/// 处理照片取消选中
/// @param object <#object description#>
/// @param config <#config description#>
/// @brief 如果未实现,picker中有默认实现
- (NSArray *)photoDidDeselected:(GDorisPhotoPickerBean *)object config:(GDorisPhotoConfiguration *)config;

/// 获取相册名称
/// @param collection collection description
- (NSString *)fetchAlbumTitleString:(id)collection;
@end

@protocol IGDorisPhotoPickerCell <NSObject>

@required
- (void)configurePhotoController:(GDorisPhotoPickerBaseController *)controller;
- (void)configureWithObject:(GDorisPhotoPickerBean *)object withIndex:(NSInteger)index;
- (void)updatePhotoCellStatus:(GDorisPhotoPickerBean *)object;

@optional

- (__kindof UIView *)doris_containerView;
@end


NS_ASSUME_NONNULL_END
