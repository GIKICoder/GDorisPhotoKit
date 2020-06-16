//
//  UIImageView+GDorisLoader.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//

#import "UIImageView+GDorisLoader.h"
#import "Conductor.h"
#import "ConductorInner.h"
#import "GDorisPhotoLoaderOperation.h"
#import <objc/runtime.h>
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
    if (self.identifier) {
        self.image = nil;
        GDorisPhotoLoaderOperation * op = (id)[[CDQueueController sharedInstance] operationWithIdentifier:self.identifier inQueueNamed:CONDUCTOR_APP_QUEUE];
        if (op) {
            [op cancel];
        }
    }
    self.identifier = asset.identifier;
    BOOL has = [[CDQueueController sharedInstance] hasOperationWithIdentifier:asset.identifier inQueueNamed:CONDUCTOR_APP_QUEUE];
    if (has) {
        [[CDQueueController sharedInstance] updatePriorityOfOperationWithIdentifier:asset.identifier inQueueNamed:CONDUCTOR_APP_QUEUE toNewPriority:NSOperationQueuePriorityHigh];
    } else {
        GDorisPhotoLoaderOperation * operation = [GDorisPhotoLoaderOperation operationWithIdentifier:asset.identifier];
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
        [[CDQueueController sharedInstance] addOperation:operation toQueueNamed:CONDUCTOR_APP_QUEUE];
    }
    
}

@end
