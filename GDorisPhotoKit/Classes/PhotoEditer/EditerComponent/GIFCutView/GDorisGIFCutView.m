//
//  GDorisGIFCutView.m
//  XCChat
//
//  Created by GIKI on 2020/1/20.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisGIFCutView.h"
#import "GDorisPhotoHelper.h"
@interface GDorisGIFCutViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@end

@interface GDorisGIFCutView ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) FLAnimatedImage * animationImage;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) GDorisGIFMetalData * metalData;
@property (nonatomic, assign) NSInteger  displayCount;
@property (nonatomic, assign) CGFloat  cellWidth;
@end

@implementation GDorisGIFCutView

- (instancetype)initWithGIFMetalData:(GDorisGIFMetalData *)metalData
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.metalData = metalData;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithAnimationImage:(FLAnimatedImage *)image
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.animationImage = image;
        [self setupUI];
        [self setupDatas];
    }
    return self;
}

- (void)setupDatas
{
    NSInteger count = MIN(10, self.metalData.images.count);
    self.displayCount = count;
    CGFloat width = self.g_width/count;
    self.cellWidth = width;
     
    [self.collectionView reloadData];
}

- (void)setupUI
{
    [self addSubview:({
        UICollectionViewFlowLayout  * flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.clearColor;
        [_collectionView registerClass:GDorisGIFCutViewCell.class forCellWithReuseIdentifier:@"GDorisGIFCutViewCell"];
        _collectionView;
    })];
    [self.collectionView reloadData];
}

- (void)layoutSubviews
{
    self.collectionView.frame = self.bounds;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.metalData.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisGIFCutViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GDorisGIFCutViewCell" forIndexPath:indexPath];
    UIImage * image = [ self.metalData.images objectAtIndex:indexPath.item];
    cell.imageView.image = image;
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(20, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
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


@implementation GDorisGIFCutViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _imageView = [[UIImageView alloc] init];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.clipsToBounds = YES;
            _imageView;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}
@end
