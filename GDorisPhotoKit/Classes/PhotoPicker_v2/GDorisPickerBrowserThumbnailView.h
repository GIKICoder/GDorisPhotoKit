//
//  GDorisPickerBrowserThumbnailView.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/8.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPickerBrowserThumbnailView : UIView

@property(nonatomic, copy) void (^thumbnailCellDidSelect)(GDorisPhotoPickerBean * asset);

@property (nonatomic, assign) NSInteger  selectIndex;

- (void)configDorisAssetItems:(NSArray<GDorisPhotoPickerBean *>*)assets;

- (void)scrollToIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
