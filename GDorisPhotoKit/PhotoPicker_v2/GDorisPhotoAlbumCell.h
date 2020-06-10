//
//  GDorisPhotoAlbumCell.h
//  GDoris
//
//  Created by GIKI on 2018/8/13.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCAssetsManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoAlbumCell : UITableViewCell

- (void)configCollectionModel:(XCAssetsGroup*)collection;

- (void)selectIndex:(BOOL)select;
@end

NS_ASSUME_NONNULL_END
