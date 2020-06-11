//
//  GDorisFilterToolbar.h
//  XCChat
//
//  Created by GIKI on 2020/3/14.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisFilterItem : NSObject
@property (nonatomic, copy  ) NSString * lookup_img;
@property (nonatomic, copy  ) NSString * lookup_name;
@property (nonatomic, strong) UIImage * filterIcon;
@property (nonatomic, assign) BOOL  selected;

+ (instancetype)filterWithLookup:(NSString *)lookup title:(NSString *)title;
@end

@interface GDorisFilterToolbar : UIView

@property(nonatomic, copy) void (^filterAction)(GDorisFilterItem * item);

- (void)configureWithItems:(NSArray <GDorisFilterItem *> *)filters;

@end

NS_ASSUME_NONNULL_END
