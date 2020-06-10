//
//  GDorisEditerToolbar.h
//  GDoris
//
//  Created by GIKI on 2018/10/3.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DorisEditerToolbarItemType) {
    DorisEditerToolbarItemDraw = 1000,
    DorisEditerToolbarItemEmjio,
    DorisEditerToolbarItemText,
    DorisEditerToolbarItemMosaic,
    DorisEditerToolbarItemCrop,
    DorisEditerToolbarItemFilter
};

@interface GDorisEditerToolbar : UIView
@property(nonatomic, copy) void (^editToolbarClickBlock)(DorisEditerToolbarItemType itemType,UIButton *sender);

- (void)setToolbarSelected:(BOOL)selected itemType:(DorisEditerToolbarItemType)itemType;

- (void)resetToolbarSelectState;
@end


NS_ASSUME_NONNULL_END
