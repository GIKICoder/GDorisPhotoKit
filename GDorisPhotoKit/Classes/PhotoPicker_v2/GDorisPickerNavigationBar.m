//
//  GDorisPickerNavigationBar.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPickerNavigationBar.h"
#import "UIControl+GDoris.h"
#import "GDorisPhotoHelper.h"
#import "UIImage+GDoris.h"
@interface GDorisPickerNavigationBar ()
@property (nonatomic, assign) BOOL  isCustom;
@property (nonatomic, strong) UIView * container;
@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) UIButton * titleButton;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * iconView;
@end

@implementation GDorisPickerNavigationBar


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
        [_closeButton setImage:[UIImage g_imageNamed:@"GDoris_photo_picker_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton g_enlargeHitWithEdges:UIEdgeInsetsMake(8, 8, 8, 8)];
        _closeButton;
    })];
    [self.container addSubview:({
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleButton addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _titleButton;
    })];
    [self.titleButton addSubview:({
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [GDorisPhotoHelper colorWithHex:@"262626"];
        _titleLabel;
    })];
    [self.titleButton addSubview:({
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage g_imageNamed:@"GDoris_photo_picker_drop_down_ic"];
        _iconView;
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
    [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.container.mas_centerX);
        make.centerY.mas_equalTo(self.container.mas_centerY);
    }];
    UIImage * image = [UIImage g_imageNamed:@"GDoris_photo_picker_drop_down_ic"];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.titleButton);
        make.right.mas_equalTo(self.iconView.mas_left).mas_offset(0);
        make.height.mas_equalTo(image.size.height);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(image.size);
        make.centerY.mas_equalTo(self.titleButton.mas_centerY);
        make.right.mas_equalTo(self.titleButton.mas_right);
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
    BOOL selected = !sender.selected;
    [self configureSelected:selected];
    if (self.tapAlbumAction) {
        self.tapAlbumAction(selected);
    }
}

- (void)configureTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)configureSelected:(BOOL)selected
{
    self.titleButton.selected = selected;
    if (selected) {
        UIImage * image = [UIImage g_imageNamed:@"GDoris_photo_picker_drop_up_ic"];
        _iconView.image = image;
    } else {
       UIImage * image = [UIImage g_imageNamed:@"GDoris_photo_picker_drop_down_ic"];
       _iconView.image = image;
    }
}
@end
