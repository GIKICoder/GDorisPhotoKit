//
//  GDorisAlbumLoader.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/25.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisAlbumLoader.h"
#import "GDorisPhotoConfiguration.h"
#import "GAssetsManager.h"
#import "GDorisPhotoPickerBean.h"
@interface GDorisAlbumLoader ()

@property (nonatomic, strong) NSMutableArray * selectObjects;
@end

@implementation GDorisAlbumLoader

@synthesize albumDatas;
@synthesize photoDatas;


- (void)loadAlbumDatas:(GDorisPhotoConfiguration *)configuration
                 quick:(BOOL (^)(NSArray * collections))quick
            completion:(void (^)(NSArray * collections))completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DorisAlbumContentType albumType =  configuration.albumType;
        GAlbumContentType  type = [self.class covertAssetTypeWith:albumType];
        dispatch_block_t block = ^{
            NSArray * groups = [[GAssetsManager sharedInstance] fetchAllAlbumsWithAlbumContentType:type showEmptyAlbum:NO showSmartAlbum:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.albumDatas = groups;
                if (completion) {
                    completion(groups);
                }
            });
        };
        if (quick) {
            GAssetsGroup * group = [[GAssetsManager sharedInstance] fetchSystemAlbumWithContentType:type];
            if (group) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.albumDatas = @[group];
                    BOOL Continue = quick(self.albumDatas);
                    if (!Continue) {
                        return;
                    } else {
                        block();
                    }
                });
            } else {
                block();
            }
        } else {
            block();
        }
        
    });
}

- (void)loadPhotos:(GDorisPhotoConfiguration *)configuration
        collection:(id)collection
             quick:(BOOL (^)(NSArray * assets))quick
        completion:(void (^)(NSArray * assets))completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block NSMutableArray * tempArray = [NSMutableArray array];
        __block NSInteger index = 0;
        if (configuration.appearance.showCamera && configuration.appearance.isReveres) {
            GDorisPhotoPickerBean * camera = [[GDorisPhotoPickerBean alloc] init];
            camera.isCamera = YES;
            camera.index = index ++;
            [tempArray addObject:camera];
        }
        GAssetsGroup * group = collection;
        NSInteger fetchMaxCount = configuration.fetchPhotoMaxCount;
        __block NSInteger blockIndex = 0;
        NSInteger quickCount = configuration.firstNeedsLoadCount;
        if (fetchMaxCount > 0) {
            [group enumerateLasterAssetsWithCount:fetchMaxCount usingBlock:^(GAsset * _Nonnull resultAsset) {
                blockIndex ++;
                if (blockIndex == quickCount && quickCount > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.photoDatas = tempArray.copy;
                        if (quick) {
                            quick(weakSelf.photoDatas);
                        }
                    });
                }
                if (resultAsset) {
                    GDorisPhotoPickerBean * assetModel = [GDorisPhotoPickerBean new];
                    assetModel.asset = resultAsset;
                    assetModel.index = index ++;
                    [tempArray addObject:assetModel];
                }
            }];
        } else { ///全部获取
            GAlbumSortType sortType = configuration.appearance.isReveres ? GAlbumSortTypeReverse : GAlbumSortTypePositive;
            [group enumerateAssetsWithOptions:sortType usingBlock:^(GAsset * _Nonnull resultAsset) {
                blockIndex ++;
                if (blockIndex == quickCount && quickCount > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.photoDatas = tempArray.copy;
                        if (quick) {
                            quick(weakSelf.photoDatas);
                        }
                    });
                }
                if (resultAsset) {
                    GDorisPhotoPickerBean * assetModel = [GDorisPhotoPickerBean new];
                    assetModel.asset = resultAsset;
                    assetModel.index = index ++;
                    [tempArray addObject:assetModel];
                }
            }];
        }
        
        if (configuration.appearance.showCamera && !configuration.appearance.isReveres) {
            GDorisPhotoPickerBean * camera = [[GDorisPhotoPickerBean alloc] init];
            camera.isCamera = YES;
            camera.index = index ++;
            [tempArray addObject:camera];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoDatas = tempArray.copy;
            if (completion) {
                completion(self.photoDatas);
            }
        });
    });
}

/// 获取相册名称
/// @param collection collection description
- (NSString *)fetchAlbumTitleString:(GAssetsGroup *)collection
{
    return collection.name;
}

/// 是否获取相册权限
- (BOOL)photoAuthorizationStatusAuthorized
{
    GAssetAuthorizationStatus status = [GAssetsManager authorizationStatus];
    if (status == GAssetAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

/// 检查照片是否可以被选中
/// @param object GDorisPhotoPickerBean
/// @param config GDorisPhotoConfiguration
- (BOOL)checkPhotoCanSelected:(GDorisPhotoPickerBean *)object config:(GDorisPhotoConfiguration *)config
{
    GAsset * asset = object.asset;
    DorisPhotoRegularType type = [self.class covertRegularType:asset.assetType];
    if (config.onlySelectOneMediaType && config.onlyEnableSelectAssetType != type && object.selectDisabled) {
//        [XCProgressHUD showToastHUD:[UIApplication sharedApplication].keyWindow info:@"不能同时选择照片和视频"];
        return NO;
    }
    NSInteger maxCount = [self fetchSelectMaxCount:object config:config];
    BOOL temp = (self.selectObjects.count < maxCount);
    if (!temp) {
        NSString * name = @"张照片";
        if (asset.assetType == GAssetTypeVideo) {
            name = @"个视频";
        }
        NSString * msg = [NSString stringWithFormat:@"最多只能选择%ld%@",(long)maxCount,name];
//        [XCProgressHUD showToastHUD:[UIApplication sharedApplication].keyWindow info:msg];
        return temp;
    }
    return YES;
}

/// 处理照片选中
/// @param object <#object description#>
/// @param config <#config description#>
/// @brief 如果未实现,picker中有默认实现
- (NSArray *)photoDidSelected:(GDorisPhotoPickerBean *)object config:(GDorisPhotoConfiguration *)config
{
    if (object && ![self.selectObjects containsObject:object]) {
        object.isSelected = YES;
        object.selectIndex = self.selectObjects.count;
        [self.selectObjects addObject:object];
        NSInteger maxCount = [self fetchSelectMaxCount:object config:config];
        if (maxCount <= self.selectObjects.count) {
            GAsset * asset = object.asset;
            DorisPhotoRegularType type = [self.class covertRegularType:asset.assetType];
            config.onlyEnableSelectAssetType = type;
            [self processPhotoDisabled:config overMax:YES];
        } else {
            if (config.onlySelectOneMediaType && config.onlyEnableSelectAssetType == DorisPhotoRegularTypeAll) {
                GAsset * asset = object.asset;
                config.onlyEnableSelectAssetType = [self.class covertRegularType:asset.assetType];
                [self processOneMidiaTypePhotoDisabled:config];
            }
        }
    }
    return self.selectObjects.copy;
}

/// 处理照片取消选中
/// @param object <#object description#>
/// @param config <#config description#>
/// @brief 如果未实现,picker中有默认实现
- (NSArray *)photoDidDeselected:(GDorisPhotoPickerBean *)object config:(GDorisPhotoConfiguration *)config
{
    if (object && [self.selectObjects containsObject:object]) {
        object.isSelected = NO;
        object.selectIndex = 0;
        object.animated = NO;
        NSInteger maxCount = [self fetchSelectMaxCount:object config:config];
        NSInteger preCount = self.selectObjects.count;
        [self.selectObjects removeObject:object];
        if (preCount >= maxCount && self.selectObjects.count < maxCount) {
            [self processPhotoDisabled:config overMax:NO];
        } else if (self.selectObjects.count <= 0) {
            if (config.onlyEnableSelectAssetType != DorisPhotoRegularTypeAll) {
                config.onlyEnableSelectAssetType = DorisPhotoRegularTypeAll;
                [self processOneMidiaTypePhotoDisabled:config];
            }
        }
        [self.selectObjects enumerateObjectsUsingBlock:^(GDorisPhotoPickerBean *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj && [obj isKindOfClass:GDorisPhotoPickerBean.class]) {
                obj.selectIndex = idx;
            }
        }];
    }
    return self.selectObjects.copy;
}

- (NSArray<GDorisPhotoPickerBean *> *)fetchSelectObjects
{
    return self.selectObjects.copy;
}

#pragma mark - lazy load

- (NSMutableArray *)selectObjects
{
    if (!_selectObjects) {
        _selectObjects = [[NSMutableArray alloc] init];
    }
    return _selectObjects;
}

#pragma mark - help method

- (NSInteger)fetchSelectMaxCount:(GDorisPhotoPickerBean *)object config:(GDorisPhotoConfiguration *)config
{
    GAsset * asset = object.asset;
    NSDictionary * regular = config.selectCountRegular;
    DorisPhotoRegularType regularType = DorisPhotoRegularTypeAll;
    NSNumber * maxCount_N = [regular objectForKey:@(regularType)];
    if (config.onlySelectOneMediaType) {
        if (asset.assetType == GAssetTypeVideo) {
            NSNumber * video_N = [regular objectForKey:@(DorisPhotoRegularTypeVideo)];
            if (video_N) {
                maxCount_N = video_N;
            }
        } else if (asset.assetType == GAssetTypeImage) {
            NSNumber * photo_N = [regular objectForKey:@(DorisPhotoRegularTypePhoto)];
            if (photo_N) {
                maxCount_N = photo_N;
            }
        }
    }
    NSInteger maxCount = NSIntegerMax;
    if (maxCount_N) {
        maxCount = [maxCount_N integerValue];
    }
    return maxCount;
}

- (void)processPhotoDisabled:(GDorisPhotoConfiguration *)config overMax:(BOOL)overMax
{
    [self.photoDatas enumerateObjectsUsingBlock:^(GDorisPhotoPickerBean *    _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!overMax && !obj.isSelected) {
            obj.selectDisabled = NO;
        } else if (overMax && !obj.isSelected) {
            obj.selectDisabled = YES;
        }
    }];
}

- (void)processOneMidiaTypePhotoDisabled:(GDorisPhotoConfiguration *)config
{
    [self.photoDatas enumerateObjectsUsingBlock:^(GDorisPhotoPickerBean *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GAsset * asset = obj.asset;
        if (config.onlyEnableSelectAssetType == DorisPhotoRegularTypeAll) {
            obj.selectDisabled = NO;
        } else {
            GAssetType  onlyType = [self.class covertRegular2AssetType:config.onlyEnableSelectAssetType];
            if (asset.assetType != onlyType) {
                obj.selectDisabled = YES;
            }
        }
    }];
}

+ (GAlbumContentType)covertAssetTypeWith:(DorisAlbumContentType)contentType
{
    switch (contentType) {
        case DorisAlbumContentTypeAll:
            return GAlbumContentTypeAll;
            break;
        case DorisAlbumContentTypeOnlyPhoto:
            return GAlbumContentTypeOnlyPhoto;
            break;
        case DorisAlbumContentTypeOnlyVideo:
            return GAlbumContentTypeOnlyVideo;
            break;
        default:
            return GAlbumContentTypeAll;
            break;
    }
}

+ (GAssetType)covertRegular2AssetType:(DorisPhotoRegularType)regularType
{
    switch (regularType) {
        case DorisPhotoRegularTypeAll:
            return GAssetTypeUnknow;
            break;
        case DorisPhotoRegularTypePhoto:
            return GAssetTypeImage;
            break;
        case DorisPhotoRegularTypeVideo:
            return GAssetTypeVideo;
            break;
        default:
            return GAssetTypeUnknow;
            break;
    }
}

+ (DorisPhotoRegularType)covertRegularType:(GAssetType)assetType
{
    switch (assetType) {
        case GAssetTypeImage:
            return DorisPhotoRegularTypePhoto;
            break;
        case GAssetTypeVideo:
            return DorisPhotoRegularTypeVideo;
            break;
        default:
            return DorisPhotoRegularTypeAll;
            break;
    }
}


@end
