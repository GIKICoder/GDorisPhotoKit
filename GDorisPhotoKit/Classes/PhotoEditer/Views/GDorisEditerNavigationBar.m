//
//  GDorisEditerNavigationBar.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisEditerNavigationBar.h"
#import "UIControl+GDoris.h"
#import "GDorisPhotoHelper.h"
#import "UIImage+GDoris.h"
#import "GDorisPhotoAppearance.h"
@interface GDorisEditerNavigationBar ()
@property (nonatomic, assign) BOOL  isCustom;
@property (nonatomic, strong) UIView * container;
@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) UIButton * rightButton;
@end

@implementation GDorisEditerNavigationBar


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
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:({
        _container = [UIView new];
        _container.backgroundColor = UIColor.clearColor;
        _container;
    })];
    [self.container addSubview:({
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage g_imageNamed:@"GDoris_photo_picker_white_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton g_enlargeHitWithEdges:UIEdgeInsetsMake(8, 8, 8, 8)];
        _closeButton;
    })];
    [self.container addSubview:({
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setTitle:@"完成" forState:UIControlStateNormal];
        [_rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _rightButton.backgroundColor = GDorisAppearanceINST.tintColor;
        _rightButton.layer.cornerRadius = 3;
        _rightButton.layer.masksToBounds = YES;
        _rightButton;
    })];
    [self layoutUI];
}

- (void)layoutUI
{
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
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 28));
        make.right.mas_equalTo(self.mas_right).mas_offset(-15);
        make.centerY.mas_equalTo(self.container.mas_centerY);
    }];
}

- (void)closeAction:(UIButton *)sender
{
    if (self.closeAction) {
        self.closeAction();
    }
}

- (void)titleButtonAction:(UIButton *)sender
{
    if (self.confirmAction) {
        self.confirmAction();
    }
}


@end
