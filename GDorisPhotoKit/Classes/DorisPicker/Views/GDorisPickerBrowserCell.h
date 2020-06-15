//
//  GDorisPickerBrowserCell.h
//  GDoris
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisBrowserBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
@class GDorisPhotoBrowserBaseController;
@interface GDorisPickerBrowserCell : GDorisBrowserBaseCell
@property (nonatomic, weak  ) GDorisPhotoBrowserBaseController  * controller;
@property (nonatomic, strong, readonly) UIImageView * containerView;
@end

NS_ASSUME_NONNULL_END
