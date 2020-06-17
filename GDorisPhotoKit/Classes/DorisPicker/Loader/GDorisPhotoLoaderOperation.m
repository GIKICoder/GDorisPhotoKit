//
//  GDorisPhotoLoaderOperation.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//

#import "GDorisPhotoLoaderOperation.h"

@implementation GDorisPhotoLoaderOperation

+ (instancetype)photoWithAsset:(GAsset *)asset size:(CGSize)size
{
    GDorisPhotoLoaderOperation * operation = [[GDorisPhotoLoaderOperation alloc] initWithIdentifier:asset.identifier];
    operation.asset = asset;
    operation.size = size;
    return operation;
}

- (void)work
{
    if (self.fetchData) {
        [self requestImageData];
    } else {
        [self requestImage];
    }
 
}

- (void)cleanup
{
    if (self.completion) {
        self.completion = nil;
    }
}

- (void)requestImageData
{
    __weak typeof(self) weakSelf = self;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self.asset requestImageData:^(NSData * _Nonnull imageData, NSDictionary<NSString *,id> * _Nonnull info, BOOL isGIF, BOOL isHEIC) {
        if (weakSelf.requestDataBlock) {
            weakSelf.requestDataBlock(imageData, isGIF, weakSelf.identifier);
        }
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)requestImage
{
    __weak typeof(self) weakSelf = self;
    CGSize size = self.size;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self.asset requestThumbnailImageWithSize:size completion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
        BOOL isDegraded = [info[PHImageResultIsDegradedKey] boolValue];
        if (weakSelf.requestImageBlock) {
            weakSelf.requestImageBlock(result, weakSelf.identifier);
        }
        if (!isDegraded) {
            dispatch_semaphore_signal(sem);
        }
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}
@end
