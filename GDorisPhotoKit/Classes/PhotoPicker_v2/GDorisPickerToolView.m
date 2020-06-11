//
//  GDorisPickerToolView.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPickerToolView.h"
#import "GDorisPhotoHelper.h"
#import "GDorisPhotoAppearance.h"
@interface GDorisPickerToolView()
@property (nonatomic, strong) UIView * container;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * centerButton;
@property (nonatomic, strong) UIButton * rightButton;
@end

@implementation GDorisPickerToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = UIColor.whiteColor;
        [self addSubview:({
            _container = [UIView new];
            _container;
        })];
        [self.container addSubview:({
            _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _leftButton.enabled = YES;
            _leftButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [_leftButton setTitleColor:GDorisColorCreate(@"262626") forState:UIControlStateNormal];
            [_leftButton setTitleColor:GDorisColorCreate(@"262626") forState:UIControlStateHighlighted];
            [_leftButton setTitleColor:GDorisAppearanceINST.tintColor forState:UIControlStateDisabled];
            _leftButton.tag = DorisPickerToolbarLeft;
            _leftButton;
        })];
        [self.container addSubview:({
            _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_centerButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _centerButton.titleLabel.font = [UIFont systemFontOfSize:14];
            _centerButton.hidden = YES;
            [_centerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, -6)];
            [_centerButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_centerButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
            _centerButton.tag = DorisPickerToolbarCenter;
            _centerButton;
        })];
        [self.container addSubview:({
            _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [_rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
            [_rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateDisabled];
            _rightButton.enabled = NO;
            _rightButton.tag = DorisPickerToolbarRight;
            UIImage *imageN = [GDorisPhotoHelper createImageWithColor:GDorisAppearanceINST.tintColor size:CGSizeMake(67, 40)];
            UIImage *imageD = [GDorisPhotoHelper createImageWithColor:GDorisColorCreate(@"D5D9D7") size:CGSizeMake(67, 40)];
            [_rightButton setBackgroundImage:imageN forState:UIControlStateNormal];
            [_rightButton setBackgroundImage:imageD forState:UIControlStateDisabled];
            _rightButton;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    {
        CGFloat left = 0;
        CGFloat top = 0;
        CGFloat width = self.g_width;
        CGFloat height = GDORIS_IS_NOTCH ? self.g_height-GDoris_TabBarMargin :self.g_height;
        self.container.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat left = 15;
        CGFloat top = (self.container.g_height - 30)*0.5;
        CGFloat width =  94*0.5;
        CGFloat height =  30;
        self.leftButton.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 124*0.5;
        CGFloat height = 30;
        CGFloat left = (self.g_width-width)*0.5;
        CGFloat top = (self.container.g_height-height)*0.5;
        self.centerButton.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 72;
        CGFloat height = 40;
        CGFloat left = (self.g_width-width);
        CGFloat top = (self.container.g_height-height)*0.5;
        self.rightButton.frame = CGRectMake(left, top, width, height);
    }
}

- (void)buttonClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (self.photoToolbarClickBlock) {
        self.photoToolbarClickBlock(btn.tag);
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.rightButton.enabled = enabled;
}
@end
