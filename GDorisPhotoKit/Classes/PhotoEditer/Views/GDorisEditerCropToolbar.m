//
//  GDorisEditerCropToolbar.m
//  GDoris
//
//  Created by GIKI on 2018/10/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisEditerCropToolbar.h"
#import "UIView+GDoris.h"
@interface GDorisEditerCropToolbar ()
@property (nonatomic, strong) UIView * topContainer;
@property (nonatomic, strong) UIView * bottomContainer;
@property (nonatomic, strong) UIButton * rotateBtn;
@property (nonatomic, strong) UIButton * closeBtn;
@property (nonatomic, strong) UIButton * doneBtn;
@property (nonatomic, strong) UIButton * resetBtn;
@end

@implementation GDorisEditerCropToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.topContainer = [UIView new];
        [self addSubview:self.topContainer];
        self.bottomContainer = [UIView new];
        [self addSubview:self.bottomContainer];
        self.rotateBtn = [self createBtn:@"旋转" tag:1001];
        [self.topContainer addSubview:_rotateBtn];
        self.closeBtn = [self createBtn:@"关闭" tag:1002];
        [self.bottomContainer addSubview:_closeBtn];
        self.resetBtn = [self createBtn:@"还原" tag:1003];
        [self.bottomContainer addSubview:_resetBtn];
        self.doneBtn = [self createBtn:@"完成" tag:1004];
        [self.bottomContainer addSubview:_doneBtn];
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
        CGFloat height = 50;
        self.topContainer.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat left = 0;
        CGFloat top = self.topContainer.g_bottom;
        CGFloat width = self.g_width;
        CGFloat height = 63;
        self.bottomContainer.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 40;
        CGFloat height = 30;
        CGFloat left = 25;
        CGFloat top = 0.5 * (self.topContainer.g_height - height);
        self.rotateBtn.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 40;
        CGFloat height = 30;
        CGFloat left = 25;
        CGFloat top = 0.5 * (self.bottomContainer.g_height - height);
        self.closeBtn.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 40;
        CGFloat height = 30;
        CGFloat left = 0.5*(self.bottomContainer.g_width-width);
        CGFloat top = 0.5 * (self.bottomContainer.g_height - height);
        self.resetBtn.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 40;
        CGFloat height = 30;
        CGFloat left = self.bottomContainer.g_width-25-width;
        CGFloat top = 0.5 * (self.bottomContainer.g_height - height);
        self.doneBtn.frame = CGRectMake(left, top, width, height);
    }
}

- (UIButton *)createBtn:(NSString*)title tag:(NSInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.lightTextColor forState:UIControlStateDisabled];
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClick:(UIButton*)btn
{
    if (self.dorisCropToolbarActionBlock) {
        self.dorisCropToolbarActionBlock(btn.tag);
    }
}


@end
