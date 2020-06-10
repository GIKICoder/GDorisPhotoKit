//
//  GDorisPickerBrowserThumbnailView.m
//  XCChat
//
//  Created by GIKI on 2020/4/8.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisPickerBrowserThumbnailView.h"
#import "GDorisPhotoHelper.h"
#import "XCAsset.h"
@interface GDorisPhotoPickerThumbnailCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIView * borderView;
@end

@implementation GDorisPhotoPickerThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView  addSubview:({
            _imageView = [UIImageView new];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.clipsToBounds = YES;
            _imageView;
        })];
        [self.contentView addSubview:({
            _borderView = [UIView new];
            _borderView.layer.borderWidth = 2;
            _borderView.layer.borderColor = GDorisColorCreate(@"FF5758").CGColor;
            _borderView.hidden = YES;
            _borderView;
        })];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.borderView.frame = self.bounds;
}

- (void)configAsset:(GDorisPhotoPickerBean *)assetModel
{
    XCAsset * asset = assetModel.asset;
    __weak typeof(self) weakSelf = self;
    [asset requestThumbnailImageWithSize:CGSizeMake(55, 55) completion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
        weakSelf.imageView.image = result;
    }];
}

@end

@interface GDorisPickerBrowserThumbnailView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) NSArray * assetModels;

@end

@implementation GDorisPickerBrowserThumbnailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectIndex = -1;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = NO;
        [collectionView registerClass:[GDorisPhotoPickerThumbnailCell class] forCellWithReuseIdentifier:@"GDorisPhotoPickerThumbnailCell"];
        self.collectionView = collectionView;
        [self addSubview:self.collectionView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.effectView.frame = self.bounds;
    self.collectionView.frame = CGRectMake(0, (self.bounds.size.height-55)*0.5, self.bounds.size.width, 55);
}

#pragma mark - public Method

- (void)configDorisAssetItems:(NSArray<GDorisPhotoPickerBean *>*)assets
{
    if (assets.count == 0) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    self.assetModels = assets;
    [self.collectionView reloadData];
}

- (void)scrollToIndex:(NSInteger)index
{
    if (index >= self.assetModels.count) {
        self.selectIndex = -1;
        [self.collectionView reloadData];
        return;
    }
    self.selectIndex = index;
    [self.collectionView reloadData];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
   [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisPhotoPickerThumbnailCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GDorisPhotoPickerThumbnailCell" forIndexPath:indexPath];
    if (self.assetModels.count > indexPath.item) {
        GDorisPhotoPickerBean * assetModel = [self.assetModels objectAtIndex:indexPath.item];
        [cell configAsset:assetModel];
        if (indexPath.item == self.selectIndex) {
            cell.borderView.hidden = NO;
        } else {
            cell.borderView.hidden = YES;
        }
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndex = indexPath.item;
    [self.collectionView reloadData];
    if (self.thumbnailCellDidSelect) {
        GDorisPhotoPickerBean * assetModel = [self.assetModels objectAtIndex:indexPath.item];
        self.thumbnailCellDidSelect(assetModel);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(55, 55);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 14;
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

