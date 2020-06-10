//
//  PHImageRequestOptions+SDPhotoPlugin.h
//  XCChat
//
//  Created by GIKI on 2020/3/8.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHImageRequestOptions (SDPhotoPlugin)
/**
 The `targetSize` value for image asset request. Defaults to `SDWebImagePhotosPixelSize`.
 */
@property (nonatomic, assign) CGSize sd_targetSize;

/**
 The `contentMode` value for image asset request. Defaults to `PHImageContentModeDefault`.
 */
@property (nonatomic, assign) PHImageContentMode sd_contentMode;
@end

NS_ASSUME_NONNULL_END
