//
//  PHImageRequestOptions+SDPhotoPlugin.m
//  XCChat
//
//  Created by GIKI on 2020/3/8.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "PHImageRequestOptions+SDPhotoPlugin.h"
#import "SDPhotosDefine.h"
#import <objc/runtime.h>

@implementation PHImageRequestOptions (SDPhotoPlugin)

- (CGSize)sd_targetSize {
    NSValue *value = objc_getAssociatedObject(self, @selector(sd_targetSize));
    if (!value) {
        return SDWebImagePhotosPixelSize;
    }
#if SD_MAC
    CGSize targetSize = value.sizeValue;
#else
    CGSize targetSize = value.CGSizeValue;
#endif
    return targetSize;
}

- (void)setSd_targetSize:(CGSize)sd_targetSize {
    objc_setAssociatedObject(self, @selector(sd_targetSize), @(sd_targetSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char kAssociatedObjectKey_SDContentMode;
- (void)setSd_contentMode:(PHImageContentMode)sd_contentMode {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_SDContentMode, @(sd_contentMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PHImageContentMode)sd_contentMode {
    NSNumber * number = ((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_SDContentMode));
    if (!number) {
        return PHImageContentModeDefault;
    }
    return [number integerValue];
}
@end
