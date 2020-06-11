//
//  GDorisPickerBrowserNavigationBar.h
//  XCChat
//
//  Created by GIKI on 2020/4/8.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPickerBrowserNavigationBar : UIView

@property(nonatomic, copy) void (^closeAction)(void);
@property(nonatomic, copy) void (^selectAction)(void);

@property (nonatomic, assign) NSInteger  selectIndex;
@property (nonatomic, assign) BOOL  selected;

- (void)popAnimated;
@end

NS_ASSUME_NONNULL_END
