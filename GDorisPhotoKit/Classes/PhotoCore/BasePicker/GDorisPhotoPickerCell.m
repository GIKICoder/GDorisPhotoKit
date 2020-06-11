//
//  GDorisPhotoPickerCell.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/25.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerCell.h"
#import "GDorisAnimatedButton.h"
#import "GDorisPhotoHelper.h"
#import "UIControl+GDoris.h"
#import "GDorisPhotoConfiguration.h"
#import "GDorisPhotoPickerBaseInternal.h"
#import "UIImage+GDoris.h"
@interface GDorisPhotoPickerCell ()
@property (nonatomic, strong) UIImageView  * imageView;
@property (nonatomic, strong) UIView * operationCotainer;
@property (nonatomic, strong) GDorisAnimatedButton  *selectButton;
@property (nonatomic, strong) UILabel * videoTagLabel;
@property (nonatomic, strong) UILabel * photoTagLabel;
@property (nonatomic, strong) UILabel * editerLabel;
@property (nonatomic, assign) BOOL  isAnimated;

@property (nonatomic, weak  ) GDorisPhotoConfiguration  * configuration;
@property (nonatomic, weak  ) GDorisPhotoPickerBaseController * controller;
@property (nonatomic, strong) GDorisPhotoPickerBean * objectBean;
@end

@implementation GDorisPhotoPickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _imageView = [UIImageView new];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.clipsToBounds = YES;
            _imageView.layer.cornerRadius = 6;
            _imageView.layer.masksToBounds = YES;
            _imageView;
        })];
        [self.contentView addSubview:({
            _operationCotainer = [UIView new];
            _operationCotainer.layer.cornerRadius = 6;
            _operationCotainer.layer.masksToBounds = YES;
            _operationCotainer;
        })];
        
        [self.operationCotainer addSubview:({
            _selectButton = [GDorisAnimatedButton buttonWithType:UIButtonTypeCustom];
            [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_selectButton setImage:[UIImage g_imageNamed:@"GDoris_photo_picker_cell_unselect_ic"] forState:UIControlStateNormal];
            [_selectButton setImage:[UIImage g_imageNamed:@"PhotoLibrary_selected"] forState:UIControlStateSelected];
            _selectButton.selectType = GDorisPickerSelectCount;
            [_selectButton g_enlargeHitWithEdges: UIEdgeInsetsMake(20, 20, 20, 20)];
            _selectButton;
        })];
        
        [self.operationCotainer addSubview:({
            _videoTagLabel = [UILabel new];
            _videoTagLabel.textColor = [UIColor whiteColor];
            _videoTagLabel.font = [UIFont systemFontOfSize:13];
            _videoTagLabel.textAlignment = NSTextAlignmentRight;
            _videoTagLabel.hidden = YES;
            _videoTagLabel;
        })];
        [self.operationCotainer addSubview:({
            _photoTagLabel = [UILabel new];
            _photoTagLabel.textColor = [UIColor whiteColor];
            _photoTagLabel.font = [UIFont systemFontOfSize:12];
            _photoTagLabel.textAlignment = NSTextAlignmentCenter;
            _photoTagLabel.layer.cornerRadius = 4;
            _photoTagLabel.layer.masksToBounds = YES;
            _photoTagLabel.backgroundColor = GDorisAppearanceINST.tintColor;
            _photoTagLabel.text = @"GIF";
            _photoTagLabel.hidden = YES;
            _photoTagLabel;
        })];
        
        [self.operationCotainer addSubview:({
            _editerLabel = [UILabel new];
            _editerLabel.text = @"已编辑";
            _editerLabel.textColor = [UIColor whiteColor];
            _editerLabel.font = [UIFont systemFontOfSize:11];
            _editerLabel.textAlignment = NSTextAlignmentCenter;
            _editerLabel.layer.cornerRadius = 4;
            _editerLabel.layer.masksToBounds = YES;
            _editerLabel.backgroundColor = GDorisAppearanceINST.tintColor;
            _editerLabel.hidden = YES;
            _editerLabel;
        })];
        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    self.operationCotainer.frame = self.contentView.bounds;
    
    CGSize bsize = {22.5,22.5};
    CGFloat btop = 3;
    CGFloat bleft = self.contentView.frame.size.width - bsize.width - 3;
    CGRect brect = {{bleft,btop},bsize};
    self.selectButton.frame = brect;
    
    CGSize vsize = {self.bounds.size.width-5,22};
    CGPoint vpoint = {0,self.bounds.size.height - vsize.height};
    CGRect vrect = {vpoint,vsize};
    self.videoTagLabel.frame = vrect;
    
    CGSize gsize = {30,20};
    CGPoint gpoint = {self.bounds.size.width - gsize.width,self.bounds.size.height - gsize.height};
    CGRect grect = {gpoint,gsize};
    self.photoTagLabel.frame = grect;
    
    CGSize esize = {35,20};
    CGPoint epoint = {10,self.bounds.size.height - gsize.height-5};
    CGRect erect = {epoint,esize};
    self.editerLabel.frame = erect;
}


#pragma mark - action Method

- (void)selectButtonAction:(UIButton *)sender
{
    if (sender.selected) { // cancel
        [self.controller doris_didDeselectAsset:self.objectBean];
    } else { // select
        if ([self canSelect]) {
            [self.controller doris_didSelectAsset:self.objectBean];
        }
    }
}

- (BOOL)canSelect
{
    return [self.controller doris_canSelectAsset:self.objectBean];
}

#pragma mark - public Method

- (void)configurePhotoController:(GDorisPhotoPickerBaseController *)controller
{
    self.controller = controller;
    self.configuration = controller.configuration;
}

- (void)configureWithObject:(__kindof id)object withIndex:(NSInteger)index
{
    [self.configuration.photoLoader loadPhotoData:self.imageView withObject:object];
    [self configureTagWithObject:object];
    [self updatePhotoCellStatus:object];
}

- (void)updatePhotoCellStatus:(GDorisPhotoPickerBean *)object
{
    self.objectBean = object;
    if (self.configuration.radioMode) {
        self.selectButton.hidden = YES;
        return;
    }  else {
        self.selectButton.hidden = NO;
    }
    if (self.configuration.appearance.selectCountEnabled) {
        self.selectButton.selectType = GDorisPickerSelectCount;
        self.selectButton.selectIndex = [NSString stringWithFormat:@"%ld",(long)object.selectIndex+1];
    } else {
        self.selectButton.selectType = GDorisPickerSelectIcon;
    }
    
    if (object.isSelected && !object.animated) {
        self.selectButton.selected = object.isSelected;
        object.animated = YES;
        if (self.configuration.appearance.selectAnimated) {
            [self.selectButton popAnimated];
        }
    } else {
        self.selectButton.selected = object.isSelected;
    }
    
    if (!object.isSelected && object.selectDisabled) {
        self.operationCotainer.backgroundColor = [GDorisPhotoHelper colorWithHex:@"ffffff" alpha:0.5];
    } else if (object.isSelected) {
        self.operationCotainer.backgroundColor = [GDorisPhotoHelper colorWithHex:@"000000" alpha:0.4];
    } else {
        self.operationCotainer.backgroundColor = UIColor.clearColor;
    }

//    if (self.assetItem.editerImage) {
//        self.imageView.image = self.assetItem.editerImage;
//        self.editerLabel.hidden = NO;
//    } else {
//        self.editerLabel.hidden = YES;
//    }
}

- (void)configureTagWithObject:(id)object
{
    self.videoTagLabel.hidden = YES;
    self.photoTagLabel.hidden = YES;
    id<IGDorisPhotoLoader> loader = self.configuration.photoLoader;
    if (loader && [loader respondsToSelector:@selector(generatePhotoTagData:)]) {
        NSDictionary * param = [loader generatePhotoTagData:object];
        GDorisPhotoTagType type = [param[@"TagType"] integerValue];
        NSString * msg = param[@"TagMsg"];
        switch (type) {
            case GDorisPhotoType_video:
                {
                    self.videoTagLabel.hidden = NO;
                    self.videoTagLabel.text = msg;
                }
                break;
            case GDorisPhotoType_GIF:
            case GDorisPhotoType_long:
            {
                self.photoTagLabel.hidden = NO;
                self.photoTagLabel.text = msg;
            }
                break;
            default:
                break;
        }
    }
}

- (__kindof UIView *)doris_containerView
{
    return self.imageView;
}
@end
