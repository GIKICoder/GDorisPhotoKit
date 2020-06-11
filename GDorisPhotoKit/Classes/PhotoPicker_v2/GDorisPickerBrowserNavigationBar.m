//
//  GDorisPickerBrowserNavigationBar.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/8.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPickerBrowserNavigationBar.h"
#import "GDorisAnimatedButton.h"
#import "UIControl+GDoris.h"
#import "GDorisPhotoHelper.h"
@interface GDorisPickerBrowserNavigationBar ()
@property (nonatomic, strong) UIView * container;
@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) GDorisAnimatedButton * selectCountBtn;
@property (nonatomic, assign) BOOL  isCustom;
@end
@implementation GDorisPickerBrowserNavigationBar

- (instancetype)initWithCustomBar:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isCustom = YES;
        [self doInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GDorisNavBarHeight)];
    if (self) {
       [self doInit];
    }
    return self;
}

- (void)doInit
{
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    [self addSubview:({
        _container = [UIView new];
        _container.backgroundColor = UIColor.clearColor;
        _container;
    })];
    [self.container addSubview:({
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"Fire_btn_cancel_white"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton g_enlargeHitWithEdges:UIEdgeInsetsMake(8, 8, 8, 8)];
        _closeButton;
    })];
    
    self.selectCountBtn = [GDorisAnimatedButton buttonWithType:UIButtonTypeCustom];
    self.selectCountBtn.frame = CGRectMake(0, 0, 28, 28);
    self.selectCountBtn.selectType = GDorisPickerSelectCount;
    self.selectCountBtn.countFont = [UIFont systemFontOfSize:17];
    UIImage * image = [UIImage imageNamed:@"PhotoLibrary_unselected"];
    [self.selectCountBtn setImage:image forState:UIControlStateNormal];
    [self.selectCountBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectCountBtn g_enlargeHitWithEdges:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.container addSubview:self.selectCountBtn];
    if (self.isCustom) {
        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    } else {
        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.mas_equalTo(self.mas_top).mas_offset(GDorisStatusBarHeight);
        }];
    }
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(24);
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.container.mas_centerY);
    }];
    [self.selectCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(24);
        make.right.mas_equalTo(self.container.mas_right).mas_offset(-15);
        make.centerY.mas_equalTo(self.container.mas_centerY);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    self.selectCountBtn.selected = selected;
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    if (selectIndex >= 0) {
        self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%ld",selectIndex+1];
    } else {
        self.selectCountBtn.selectIndex = @"";
    }
}

- (void)popAnimated
{
    [self.selectCountBtn popAnimated];
}

- (void)selectBtnClick:(UIButton *)sender
{
    if (self.selectAction) {
        self.selectAction();
    }
}

- (void)closeAction:(UIButton *)sender
{
    if (self.closeAction) {
        self.closeAction();
    }
}
@end
