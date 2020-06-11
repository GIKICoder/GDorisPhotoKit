//
//  XCAssetsGroup.m
//  XCChat
//
//  Created by GIKI on 2019/8/13.
//  Copyright © 2019 xiaochuankeji. All rights reserved.
//

#import "XCAssetsGroup.h"
#import "XCAsset.h"
#import "XCAssetsManager.h"

@interface  XCAssetsGroup()

@property(nonatomic, strong, readwrite) PHAssetCollection *phAssetCollection;
@property(nonatomic, strong, readwrite) PHFetchResult *phFetchResult;

@end

@implementation  XCAssetsGroup

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection fetchAssetsOptions:(PHFetchOptions *)pHFetchOptions {
    self = [super init];
    if (self) {
        PHFetchResult *phFetchResult = [PHAsset fetchAssetsInAssetCollection:phAssetCollection options:pHFetchOptions];
        self.phFetchResult = phFetchResult;
        self.phAssetCollection = phAssetCollection;
    }
    return self;
}

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection {
    return [self initWithPHCollection:phAssetCollection fetchAssetsOptions:nil];
}

- (NSInteger)numberOfAssets {
    return self.phFetchResult.count;
}

- (NSString *)name {
    NSString *resultName = self.phAssetCollection.localizedTitle;
    return NSLocalizedString(resultName, resultName);
}

- (UIImage *)posterImageWithSize:(CGSize)size {
    // 系统的隐藏相册不应该显示缩略图
    if (self.phAssetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) {
        /// todo by giki
        return [UIImage imageNamed:@"Fire_pic_head_blue"];
    }
    
    __block UIImage *resultImage;
    NSInteger count = self.phFetchResult.count;
    if (count > 0) {
        PHAsset *asset = self.phFetchResult[count - 1];
        PHImageRequestOptions *pHImageRequestOptions = [[PHImageRequestOptions alloc] init];
        pHImageRequestOptions.synchronous = YES; // 同步请求
        pHImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        // targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        [[[ XCAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:asset targetSize:CGSizeMake(size.width * [[UIScreen mainScreen] scale], size.height * [[UIScreen mainScreen] scale]) contentMode:PHImageContentModeAspectFill options:pHImageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            resultImage = result;
        }];
    }
    return resultImage;
}

/// 获取前多少个相册资源
/// @param count 数量
/// @param albumSortType 排序方式
- (NSArray *)fetchTopCountAssets:(NSInteger)count sortType:(XCAlbumSortType)albumSortType
{
    CFTimeInterval startTime = CACurrentMediaTime();
    
    NSEnumerationOptions Options = NSEnumerationConcurrent;
    if (albumSortType == XCAlbumSortTypeReverse) {
        Options = NSEnumerationReverse;
    }
    __block NSMutableArray * tempsM = [NSMutableArray array];
    [self.phFetchResult enumerateObjectsWithOptions:(Options) usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XCAsset *asset = [[ XCAsset alloc] initWithPHAsset:obj];
        [tempsM addObject:asset];
        if (idx >= count) {
            *stop = YES;
        }
    }];
    CFTimeInterval endTime = CACurrentMediaTime();
    CFTimeInterval consumingTime = endTime - startTime;
    NSLog(@"fetchTopCountAssets耗时：%@", @(consumingTime));
    return tempsM.copy;
}

/// 获取最新的相册资源
/// @param count 回去的数量
/// @param enumerationBlock <#enumerationBlock description#>
- (void)enumerateLasterAssetsWithCount:(NSInteger)count usingBlock:(void (^)( XCAsset *resultAsset))enumerationBlock
{
    #ifdef DEBUG
        CFTimeInterval startTime = CACurrentMediaTime();
    #endif
        NSEnumerationOptions Options = NSEnumerationReverse;
        __block NSInteger total = 0;
        [self.phFetchResult enumerateObjectsWithOptions:(Options) usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            XCAsset *asset = [[ XCAsset alloc] initWithPHAsset:obj];
            if (enumerationBlock) {
                enumerationBlock(asset);
            }
            total ++;
            if (total >= count) {
                *stop = YES;
            }
        }];
    #ifdef DEBUG
        CFTimeInterval endTime = CACurrentMediaTime();
        CFTimeInterval consumingTime = endTime - startTime;
        NSLog(@"enumerateAssetsWithOptions耗时：%@", @(consumingTime));
    #endif
        /**
         *  For 循环遍历完毕，这时再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
         */
        if (enumerationBlock) {
            enumerationBlock(nil);
        }
}

- (void)enumerateAssetsWithOptions:( XCAlbumSortType)albumSortType usingBlock:(void (^)( XCAsset *resultAsset))enumerationBlock {
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
#endif
    NSEnumerationOptions Options = NSEnumerationConcurrent;
    if (albumSortType == XCAlbumSortTypeReverse) {
        Options = NSEnumerationReverse;
    }
    [self.phFetchResult enumerateObjectsWithOptions:(Options) usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XCAsset *asset = [[ XCAsset alloc] initWithPHAsset:obj];
      
        if (enumerationBlock) {
            enumerationBlock(asset);
        }
    }];
#ifdef DEBUG
    CFTimeInterval endTime = CACurrentMediaTime();
    CFTimeInterval consumingTime = endTime - startTime;
    NSLog(@"enumerateAssetsWithOptions耗时：%@", @(consumingTime));
#endif
    /**
     *  For 循环遍历完毕，这时再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
     */
    if (enumerationBlock) {
        enumerationBlock(nil);
    }
}

- (void)enumerateAssetsUsingBlock:(void (^)( XCAsset *resultAsset))enumerationBlock {
    [self enumerateAssetsWithOptions: XCAlbumSortTypePositive usingBlock:enumerationBlock];
}

@end