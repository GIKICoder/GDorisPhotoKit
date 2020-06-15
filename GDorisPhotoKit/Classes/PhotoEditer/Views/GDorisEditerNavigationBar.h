//
//  GDorisEditerNavigationBar.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisEditerNavigationBar : UIView

- (instancetype)initWithCustomBar:(CGRect)frame;

@property (nonatomic, strong, readonly) UILabel * titleLabel;
@property(nonatomic, copy) void (^confirmAction)(void);
@property(nonatomic, copy) void (^closeAction)(void);

@end

NS_ASSUME_NONNULL_END
