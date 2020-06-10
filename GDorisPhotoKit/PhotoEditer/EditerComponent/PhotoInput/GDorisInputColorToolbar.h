//
//  GDorisInputColorToolbar.h
//  XCChat
//
//  Created by GIKI on 2020/1/15.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisInputColorToolbar : UIView

@property(nonatomic, copy) void (^colorDidSelectBlock)(UIColor *color);
@property(nonatomic, copy) void (^fillBtnActionBlock)(BOOL isFill);

- (void)configColors:(NSArray<UIColor *> *)colors;
- (void)setSelectedByIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
