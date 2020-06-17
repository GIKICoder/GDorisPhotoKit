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

static char kAssociatedObjectKey_identifier;
- (void)setIdentifier:(NSString *)identifier {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_identifier, identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)identifier {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_identifier);
}

- (void)doris_loadPhotoWithAsset:(GAsset *)asset completion:(void (^)(UIImage * result, NSError * error))completion
{
    GDorisLoaderQueue *serialQueue = [GDorisLoaderQueue queueWithName:LOAD_PHOTO_APP_QUEUE];
    [serialQueue setMaxConcurrentOperationCount:4];
    [[GDorisLoaderController sharedInstance] addQueue:serialQueue];
    if (self.identifier) {
        self.image = nil;
        GDorisPhotoLoaderOperation * op = (id)[[GDorisLoaderController sharedInstance] fetchOperationWithIdentifier:self.identifier queueNamed:LOAD_PHOTO_APP_QUEUE];
        if (op) {
            [op cancel];
        }
    }
    self.identifier = asset.identifier;
    GDorisPhotoLoaderOperation * operation = [[GDorisPhotoLoaderOperation alloc] initWithIdentifier:asset.identifier];
    operation.asset = asset;
    __weak typeof(self) weakSelf = self;
    operation.completion = ^(UIImage * _Nonnull image, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf) {
                strongSelf.image = image;
                if (completion) {
                    completion(image,error);
                }
            }
        });
    };
    [[GDorisLoaderController sharedInstance] addOperation:operation queueNamed:LOAD_PHOTO_APP_QUEUE];
    
}

@end
