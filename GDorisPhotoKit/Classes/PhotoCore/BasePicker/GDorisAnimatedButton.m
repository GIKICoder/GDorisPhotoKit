//
//  GDorisAnimatedButton.m
//  GDoris
//
//  Created by GIKI on 2018/9/19.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisAnimatedButton.h"
#import "GDorisPhotoHelper.h"
@interface GDorisAnimatedButton ()
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * numberLabel;
@property (nonatomic, strong) UIImage * selectImage;
@end

@implementation GDorisAnimatedButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_selectType == GDorisPickerSelectCount) {
        _iconView.frame = self.bounds;
        _iconView.layer.cornerRadius = self.frame.size.width * 0.5;
        _iconView.layer.masksToBounds = YES;
        _numberLabel.frame = self.iconView.bounds;
    }
}

- (void)setSelectType:(GDorisPickerSelectType)selectType
{
    _selectType = selectType;
    if (selectType == GDorisPickerSelectCount) {
        self.iconView.hidden = YES;
        self.iconView.frame = self.bounds;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (_selectType == GDorisPickerSelectCount) {
       _iconView.hidden = !selected;
       self.imageView.hidden = selected;
    }
}

- (void)setSelectIndex:(NSString *)selectIndex
{
    _selectIndex = selectIndex;
    if (_selectType == GDorisPickerSelectCount) {
        _numberLabel.text = selectIndex;
    }
}

- (void)setCountFont:(UIFont *)countFont
{
    if (_selectType == GDorisPickerSelectCount) {
        self.numberLabel.font = countFont;
    }
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.backgroundColor = GDorisColorCreate(@"FF5758");
        [self addSubview:_iconView];
        _numberLabel = [UILabel new];
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.textColor = GDorisColorCreate(@"ffffff");
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [_iconView addSubview:_numberLabel];
    }
    return _iconView;
}


#pragma mark - public Method

- (void)popAnimated
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:popAnimation forKey:nil];
}
@end
