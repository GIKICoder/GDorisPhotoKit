//
//  GDorisPickerNavigationBar.h
//  XCChat
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPickerNavigationBar : UIView

- (instancetype)initWithCustomBar:(CGRect)frame;

@property (nonatomic, strong, readonly) UILabel * titleLabel;
@property(nonatomic, copy) void (^tapAlbumAction)(BOOL selected);
@property(nonatomic, copy) void (^closeAction)(void);

- (void)configureTitle:(NSString *)title;
- (void)configureSelected:(BOOL)selected;
@end

NS_ASSUME_NONNULL_END
