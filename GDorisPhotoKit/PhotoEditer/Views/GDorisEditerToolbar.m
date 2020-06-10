//
//  GDorisEditerToolbar.m
//  GDoris
//
//  Created by GIKI on 2018/10/3.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisEditerToolbar.h"
#import "UIView+GDoris.h"
#import "GDorisPhotoHelper.h"

@interface GDorisEditerToolbar ()

@property (nonatomic, strong) NSArray * buttons;

@end
@implementation GDorisEditerToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        NSArray * array = @[@"GDoris_PhotoEdit_draw_ic",@"GDoris_PhotoEdit_emoji_ic",@"GDoris_PhotoEdit_text_ic",@"GDoris_PhotoEdit_mosaic_ic",@"GDoris_PhotoEdit_crop_ic",@"GDoris_PhotoEdit_filter_ic"];
        CGFloat widthItem = [UIScreen mainScreen].bounds.size.width / array.count;
        __block NSMutableArray * buttonsM = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [self createButton:obj];
            button.tag = 1000+idx;
            [buttonsM addObject:button];
            [self addSubview:button];
            {
                CGFloat left = idx*widthItem;
                CGFloat top = 0;
                CGFloat width = widthItem;
                CGFloat height = 22;
                button.frame = CGRectMake(left, top, width, height);
            }
        }];
        self.buttons = buttonsM.copy;
    }
    return self;
}


- (UIButton *)createButton:(NSString *)icon
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClick:(UIButton*)sender
{
    if (self.editToolbarClickBlock) {
        self.editToolbarClickBlock(sender.tag,sender);
    }
}

- (void)resetToolbarSelectState
{
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
    }];
}

- (void)setToolbarSelected:(BOOL)selected itemType:(DorisEditerToolbarItemType)itemType
{
    UIButton * draw = [self viewWithTag:DorisEditerToolbarItemDraw];
    UIButton * mosaic = [self viewWithTag:DorisEditerToolbarItemMosaic];
    draw.selected = NO;
    mosaic.selected = NO;
    UIButton * button = [self viewWithTag:itemType];
    button.selected = selected;
    
}
@end
