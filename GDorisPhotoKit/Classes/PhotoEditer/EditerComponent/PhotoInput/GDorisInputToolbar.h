//
//  GDorisInputToolbar.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/1/15.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GDorisInputToolType) {
    GDorisInputToolType_Keyboard = 100,
    GDorisInputToolType_Style,
    GDorisInputToolType_Font,
};

@interface GDorisInputToolbar : UIView

@property(nonatomic, copy) void (^dorisInputToolbarAction)(GDorisInputToolType type);

@end

NS_ASSUME_NONNULL_END
