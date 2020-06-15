//
//  GDorisInputColorToolbar.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/1/15.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisInputColorToolbar.h"
#import "GDorisPhotoHelper.h"
#import "GDorisEditerColorPanel.h"


@interface GDorisInputColorToolbar ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIButton * fillBtn;
@property (nonatomic, strong) NSArray * colors;
@end

@implementation GDorisInputColorToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
        [button setTitle:@"填充" forState:UIControlStateNormal];
        [button setTitle:@"文字" forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _fillBtn = button;
        [self addSubview:_fillBtn];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = NO;
        [collectionView registerClass:[GDorisEditerColorCell class] forCellWithReuseIdentifier:@"GDorisEditerColorCell"];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    {
        CGFloat width = 32;
        CGFloat height = 45;
        CGFloat left = 15;
        CGFloat top = 0;
        self.fillBtn.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = self.g_width - (15+32+10);
        CGFloat height = 45;
        CGFloat left = 15+32+10;
        CGFloat top = 0;
        self.collectionView.frame = CGRectMake(left, top, width, height);
    }

   
}

- (void)configColors:(NSArray<UIColor *> *)colors
{
    self.colors = colors;
    [self.collectionView reloadData];
}

- (void)buttonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (self.fillBtnActionBlock) {
        self.fillBtnActionBlock(button.selected);
    }
}

- (void)setSelectedByIndex:(NSInteger)index
{
    if (index >= self.colors.count) {
        index = 0;
    }
    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    cell.selected = YES;
}



#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisEditerColorCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GDorisEditerColorCell" forIndexPath:indexPath];
    if (self.colors.count > indexPath.item) {
        UIColor * color = [self.colors objectAtIndex:indexPath.item];
        if (![color isKindOfClass:[NSString class]]) {
            [cell configColor:color];
        }
    }
    if (indexPath.item == 0) {
        cell.selected = YES;
        if (cell.selected) {
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(UICollectionViewScrollPositionNone)];
        }
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = YES;
    if (self.colorDidSelectBlock) {
        if (self.colors.count > indexPath.item) {
            UIColor * color = [self.colors objectAtIndex:indexPath.item];
            self.colorDidSelectBlock(color);
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(26, 45);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 17;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}
@end
