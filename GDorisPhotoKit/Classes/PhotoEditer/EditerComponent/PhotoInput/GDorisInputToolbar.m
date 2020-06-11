//
//  GDorisInputToolbar.m
//  XCChat
//
//  Created by GIKI on 2020/1/15.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisInputToolbar.h"
#import "GDorisPhotoHelper.h"
#import "Masonry.h"
#import "GDorisPhotoAppearance.h"
@interface GDorisInputToolbar ()
@property (nonatomic, strong) UIButton * keyboardBtn;
@property (nonatomic, strong) UIButton * styleBtn;
@property (nonatomic, strong) UIButton * fontBtn;
@end
@implementation GDorisInputToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.keyboardBtn = [self factoryCreateBtn:@"键盘" tag:100];
        self.styleBtn = [self factoryCreateBtn:@"样式" tag:101];
        self.fontBtn = [self factoryCreateBtn:@"字体" tag:102];
        [self addSubview:self.keyboardBtn];
        [self addSubview:self.styleBtn];
        [self addSubview:self.fontBtn];
        NSArray * array = @[self.keyboardBtn,self.styleBtn,self.fontBtn];
        CGFloat width = ([UIScreen mainScreen].bounds.size.width-20)/3.0;
        [array mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:width leadSpacing:10 tailSpacing:10];
        [array mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self);
        }];
    }
    return self;
}

- (UIButton* )factoryCreateBtn:(NSString *)text tag:(NSInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:GDorisColorCreate(@"262626") forState:UIControlStateNormal];
    [button setTitleColor:GDorisAppearanceINST.tintColor forState:UIControlStateSelected];
    [button setTitle:text forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    GDorisInputToolType type = sender.tag;
    if (type == GDorisInputToolType_Keyboard) {
        if (!sender.selected) {
            type = GDorisInputToolType_Keyboard;
        }
    }
    if (self.dorisInputToolbarAction) {
        self.dorisInputToolbarAction(type);
    }
}
@end
