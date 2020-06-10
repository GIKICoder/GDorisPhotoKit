//
//  GDorisAnimatedButton.h
//  GDoris
//
//  Created by GIKI on 2018/9/19.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GDorisPickerSelectType) {
    GDorisPickerSelectIcon,
    GDorisPickerSelectCount,
};
@interface GDorisAnimatedButton : UIButton

@property (nonatomic, assign) GDorisPickerSelectType  selectType;
@property (nonatomic, copy  ) NSString * selectIndex;
@property (nonatomic, strong) UIFont * countFont;

- (void)popAnimated;
@end

NS_ASSUME_NONNULL_END
