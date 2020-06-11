//
//  SDPhotosError.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/8.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSErrorDomain const SDWebImagePhotosErrorDomain;

typedef NS_ERROR_ENUM(SDWebImagePhotosErrorDomain, SDWebImagePhotosError) {
    /// Photos framework access is not authorized by user
    SDWebImagePhotosErrorNotAuthorized = 10001,
    /// Photos URL is not image asset type (like Video or Audio)
    SDWebImagePhotosErrorNotImageAsset = 10002
};

