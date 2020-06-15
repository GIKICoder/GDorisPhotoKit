//
//  GDorisPhotoAlbumTableView.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/8/14.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAssetsManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoAlbumTableView : UIView

@property (nonatomic, assign) CGFloat  maxHeight;
@property (nonatomic, copy  ) void (^selectPhotoAlbum)(GAssetsGroup *assetsGroup);
@property (nonatomic, copy  ) void (^photoAlbumDismiss)(void);
@property (nonatomic, assign, readonly) NSInteger  selectIndex;
- (void)fulFill:(NSArray *)albums selectIndex:(NSInteger)index;

- (void)show;
- (void)dismiss;
@end
NS_ASSUME_NONNULL_END
