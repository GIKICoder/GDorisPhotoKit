//
//  GDorisFilterToolbar.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/14.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisFilterToolbar.h"
#import "GDorisPhotoHelper.h"
#import "CIFilter+GDoris.h"
#import "UIImage+GDoris.h"

@interface GDorisFilterToolbarCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * filterLabel;
@end

@interface GDorisFilterToolbar ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * datas;
@end

@implementation GDorisFilterToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = NO;
        [collectionView registerClass:[GDorisFilterToolbarCell class] forCellWithReuseIdentifier:GDorisFilterToolbarCell.description];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(0, 15, [UIScreen mainScreen].bounds.size.width, 60);
}

- (void)configureWithItems:(NSArray <GDorisFilterItem *> *)filters
{
    self.datas = filters;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisFilterToolbarCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:GDorisFilterToolbarCell.description forIndexPath:indexPath];
    if (self.datas.count > indexPath.item) {
        GDorisFilterItem * item = [self.datas objectAtIndex:indexPath.item];
        cell.filterLabel.text = item.lookup_name;
        cell.imageView.image = item.filterIcon;
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    if (self.datas.count > indexPath.item) {
        GDorisFilterItem * item = [self.datas objectAtIndex:indexPath.item];
        if (self.filterAction) {
            self.filterAction(item);
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(40, 40+18);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 20, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
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


@implementation GDorisFilterToolbarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _imageView = [[UIImageView alloc] init];
            _imageView.layer.cornerRadius = 20;
            _imageView.layer.masksToBounds = YES;
            _imageView;
        })];
        
        [self.contentView addSubview:({
            _filterLabel = [UILabel new];
            _filterLabel.textColor = UIColor.whiteColor;
            _filterLabel.font = [UIFont systemFontOfSize:12];
            _filterLabel.textAlignment = NSTextAlignmentCenter;
            _filterLabel;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 40, 40);
    self.filterLabel.frame = CGRectMake(0, self.imageView.g_bottom+2, 40, 16);
}

@end


@implementation GDorisFilterItem

+ (instancetype)filterWithLookup:(NSString *)lookup title:(NSString *)title
{
    GDorisFilterItem * item = [[GDorisFilterItem alloc] initWithLookup:lookup title:title];
    return item;
}


- (instancetype)initWithLookup:(NSString *)lookup title:(NSString *)title
{
    if (self == [super init]) {
        self.lookup_img = lookup;
        self.lookup_name = title;
        self.filterIcon = [UIImage g_imageNamed:@"GDoris_photoEdit_filterImg_original"];
        if (lookup.length > 0) {
             [self filterImageWithLookup:lookup];
        }
    }
    return self;
}

- (void)filterImageWithLookup:(NSString *)lookup
{
    CIFilter *colorCube = [CIFilter colorCubeWithLUTImageNamed:lookup dimension:64];
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.filterIcon];
    [colorCube setValue:inputImage forKey:@"inputImage"];
    CIImage *outputImage = [colorCube outputImage];

    CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:(__bridge id)(CGColorSpaceCreateDeviceRGB()) forKey:kCIContextWorkingColorSpace]];
    UIImage *newImage = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
    self.filterIcon = newImage;
}
@end
