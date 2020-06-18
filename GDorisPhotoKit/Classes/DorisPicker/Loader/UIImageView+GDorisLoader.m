//
//  UIImageView+GDorisLoader.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//

#import "UIImageView+GDorisLoader.h"
#import "GDorisPhotoLoaderOperation.h"
#import <objc/runtime.h>
#import "GDorisLoaderController.h"

#define LOAD_PHOTO_APP_QUEUE @"com.photo.queue"

@interface UIImageView ()
@property (nonatomic, copy  ) NSString * identifier;
@end

@implementation UIImageView (GDorisLoader)

- (void)doris_loadPhotoWithAsset:(GAsset *)asset size:(CGSize)size completion:(void (^)(UIImage * result, NSError * error))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = nil;
    });
    GDorisLoaderQueue *serialQueue = [GDorisLoaderQueue queueWithName:LOAD_PHOTO_APP_QUEUE];
    [serialQueue setMaxConcurrentOperationCount:4];
    [[GDorisLoaderController sharedInstance] addQueue:serialQueue];
    if (self.identifier && self.identifier != asset.identifier) {
        GDorisPhotoLoaderOperation * op = (id)[[GDorisLoaderController sharedInstance] fetchOperationWithIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
        if (op) {
            [[GDorisLoaderController sharedInstance] reviseOperationPriority:(NSOperationQueuePriorityNormal) withIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
            //            [op cancel];
        }
    }
    self.identifier = asset.identifier;
    BOOL contain = [[GDorisLoaderController sharedInstance] containOperationWithIdentifier:asset.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
    if (contain) {
        [[GDorisLoaderController sharedInstance] reviseOperationPriority:(NSOperationQueuePriorityHigh) withIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
        return;
    }
    
    GDorisPhotoLoaderOperation * operation = [GDorisPhotoLoaderOperation photoWithAsset:asset size:size];
    __weak typeof(self) weakSelf = self;
    operation.requestImageBlock = ^(UIImage * _Nonnull image, NSString * _Nonnull identifier) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf && [strongSelf.identifier isEqualToString:identifier]) {
                strongSelf.image = image;
                if (completion) {
                    completion(image,nil);
                }
            } else {
                NSLog(@"identifier -- %@",identifier);
            }
        });
    };
    [[GDorisLoaderController sharedInstance] addOperation:operation queueNamed:LOAD_PHOTO_APP_QUEUE];
#ifdef DEBUG
    [[GDorisLoaderController sharedInstance] reviseOperationPriority:(NSOperationQueuePriorityHigh) withIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
#endif
}

- (void)doris_loadPhotoDataWithAsset:(GAsset *)asset completion:(void (^)(NSData * result, BOOL isGIF, NSError * error))completion
{
    GDorisLoaderQueue *serialQueue = [GDorisLoaderQueue queueWithName:LOAD_PHOTO_APP_QUEUE];
    [serialQueue setMaxConcurrentOperationCount:4];
    [[GDorisLoaderController sharedInstance] addQueue:serialQueue];
    if (self.identifier && self.identifier != asset.identifier) {
        GDorisPhotoLoaderOperation * op = (id)[[GDorisLoaderController sharedInstance] fetchOperationWithIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
        if (op) {
            [[GDorisLoaderController sharedInstance] reviseOperationPriority:(NSOperationQueuePriorityNormal) withIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
            [op cancel];
        }
    }
    self.identifier = asset.identifier;
    BOOL contain = [[GDorisLoaderController sharedInstance] containOperationWithIdentifier:asset.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
    if (contain) {
        [[GDorisLoaderController sharedInstance] reviseOperationPriority:(NSOperationQueuePriorityHigh) withIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
        return;
    }
    GDorisPhotoLoaderOperation * operation = [GDorisPhotoLoaderOperation photoWithAsset:asset size:CGSizeZero];
    operation.fetchData = YES;
    __weak typeof(self) weakSelf = self;
    operation.requestDataBlock = ^(NSData * _Nonnull data, BOOL isGIF, NSString * _Nonnull identifier) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf && [strongSelf.identifier isEqualToString:identifier]) {
                if (completion) {
                    completion(data,isGIF,nil);
                }
            } else {
                NSLog(@"identifier -- %@",identifier);
            }
        });
    };
    [[GDorisLoaderController sharedInstance] addOperation:operation queueNamed:LOAD_PHOTO_APP_QUEUE];
    [[GDorisLoaderController sharedInstance] reviseOperationPriority:(NSOperationQueuePriorityHigh) withIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
}

#pragma mark - category Method

static char kAssociatedObjectKey_identifier;
- (void)setIdentifier:(NSString *)identifier {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_identifier, identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)identifier {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_identifier);
}

@end
