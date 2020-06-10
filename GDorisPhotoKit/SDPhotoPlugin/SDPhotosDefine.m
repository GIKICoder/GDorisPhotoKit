//
//  SDPhotosDefine.m
//  XCChat
//
//  Created by GIKI on 2020/3/8.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "SDPhotosDefine.h"

NSString * _Nonnull const SDWebImagePhotosScheme = @"ph";
const CGSize SDWebImagePhotosPixelSize = {.width = 0, .height = 0};
const CGSize SDWebImagePhotosPointSize = {.width = -1, .height = -1};
const int64_t SDWebImagePhotosProgressExpectedSize = 100LL;

SDWebImageContextOption _Nonnull const SDWebImageContextPhotosFetchOptions = @"photosFetchOptions";
SDWebImageContextOption _Nonnull const SDWebImageContextPhotosImageRequestOptions = @"photosImageRequestOptions";
SDWebImageContextOption _Nonnull const SDWebImageContextPhotosRequestImageData = @"photosRequestImageData";
