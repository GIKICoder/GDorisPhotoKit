//
//  GDorisPhotoLoaderOperation.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//

#import "GDorisPhotoLoaderOperation.h"

@implementation GDorisPhotoLoaderOperation


- (void)work
{
    __weak typeof(self) weakSelf = self;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = floor((width - 0 - 0 - (4 * (4-1))) / 4);
    CGSize size = CGSizeMake(cellWidth, cellWidth);
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self.asset requestThumbnailImageWithSize:size completion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
        BOOL isDegraded = [info[PHImageResultIsDegradedKey] boolValue];
        if (weakSelf.completion) {
            weakSelf.completion(result, nil);
        }
        if (!isDegraded) {
            dispatch_semaphore_signal(sem);
        }
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)cleanup
{
    if (self.completion) {
        self.completion = nil;
    }
}
@end