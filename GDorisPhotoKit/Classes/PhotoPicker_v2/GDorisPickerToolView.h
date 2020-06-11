//
//  GDorisPickerToolView.h
//  XCChat
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, DorisPickerToolbarType) {
    DorisPickerToolbarLeft,
    DorisPickerToolbarCenter,
    DorisPickerToolbarRight,
};

@interface GDorisPickerToolView : UIView
@property (nonatomic, strong, readonly) UIButton * leftButton;
@property (nonatomic, strong, readonly) UIButton * centerButton;
@property (nonatomic, strong, readonly) UIButton * rightButton;
@property (nonatomic, assign) BOOL  enabled;

@property(nonatomic, copy) void (^photoToolbarClickBlock)(DorisPickerToolbarType itemType);
@end

NS_ASSUME_NONNULL_END
