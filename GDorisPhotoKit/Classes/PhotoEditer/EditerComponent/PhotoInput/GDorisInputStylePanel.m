//
//  GDorisInputStylePanel.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/1/15.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisInputStylePanel.h"
#import "GDorisSliderView.h"
#import "GDorisPhotoHelper.h"
#import "GDorisPhotoAppearance.h"
@interface GDorisInputStylePanel ()
@property (nonatomic, strong) UILabel * alphaLabel;
@property (nonatomic, strong) GDorisSliderView * sliderView;
@property (nonatomic, strong) UIView * functionPanel;
@end

@implementation GDorisInputStylePanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            _alphaLabel = [UILabel new];
            _alphaLabel.font = [UIFont systemFontOfSize:15];
            _alphaLabel.textColor = GDorisColorCreate(@"262626");
            _alphaLabel.text = @"透明度";
            _alphaLabel;
        })];
        [self addSubview:({
            _sliderView = [[GDorisSliderView alloc] initWithFrame:CGRectZero];
            _sliderView.trackHeight = 2;
            _sliderView.value = 1;
            _sliderView.maximumTrackTintColor = GDorisColorCreate(@"999999");
            _sliderView.minimumTrackTintColor = GDorisAppearanceINST.tintColor;
            _sliderView.thumbTintSize = CGSizeMake(20, 20);
            _sliderView.thumbTintColor = GDorisAppearanceINST.tintColor;
            _sliderView;
        })];
        [self.alphaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(30);
        }];
        [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.alphaLabel.mas_right).mas_offset(20);
            make.right.mas_equalTo(self.mas_right).mas_offset(-20);
            make.height.mas_equalTo(40);
            make.centerY.mas_equalTo(self.alphaLabel.mas_centerY);
        }];
        [self addSubview:({
            _functionPanel = [UIView new];
            _functionPanel;
        })];
        [self.functionPanel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.mas_equalTo(self.alphaLabel.mas_bottom).mas_offset(30);
            make.height.mas_equalTo(70);
        }];
        [self setupFunctionBtns];
        
    }
    return self;
}


- (void)setupFunctionBtns
{
    NSArray * titles = @[@"横向",@"竖向",@"居左",@"居中",@"居右",@"拼音",@"粗体",@"阴影",@"描边"];
    __block NSMutableArray * btns = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         UIButton * btn = [self factoryCreateButtonWithTitle:obj tag:idx];
         [self.functionPanel addSubview:btn];
         [btns addObject:btn];
    }];
//    [btns mas_distributeLatticeViewsWithFixedItemWidth:40 fixedItemHeight:40 fixedLineSpacing:10 fixedInteritemSpacing:10 warpCount:5 topSpacing:5 bottomSpacing:5 leadSpacing:15 tailSpacing:15];
}

- (UIButton *)factoryCreateButtonWithTitle:(NSString *)title tag:(NSInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:GDorisAppearanceINST.tintColor forState:UIControlStateSelected];
    [button setTitleColor:GDorisColorCreate(@"262626") forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClick:(UIButton*)sender
{}

@end
