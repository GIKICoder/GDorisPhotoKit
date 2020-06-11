//
//  GDorisPhotoPickerBaseController.m
//  GDoris
//
//  Created by GIKI on 2020/3/22.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerBaseController.h"
#import "GDorisPhotoPickerBaseInternal.h"
#import "NSArray+GDoris.h"
@interface GDorisPhotoPickerBaseController ()
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, assign) CGFloat  cellWidth;
@end

@implementation GDorisPhotoPickerBaseController

#pragma mark - initialize Method

- (instancetype)initWithConfiguration:(GDorisPhotoConfiguration *)configuration
{
    self = [super init];
    if (self) {
        self.configuration = configuration;
        [self initializePicker];
    }
    return self;
}

- (instancetype)init
{
    GDorisPhotoConfiguration * config = [GDorisPhotoConfiguration defaultConfiguration];
    return  [self initWithConfiguration:config];
}

- (void)initializePicker
{
    CGFloat padding = self.configuration.appearance.edgeInset.left + self.configuration.appearance.edgeInset.right;
    CGFloat cell_padding = self.configuration.appearance.pickerPadding;
    CGFloat count = self.configuration.appearance.pickerColumns;
    CGFloat screen_w = [UIScreen mainScreen].bounds.size.width;
    self.cellWidth = floor((screen_w - padding - cell_padding * (count-1)) * 1.0 / count);
}

#pragma mark - life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar removeFromSuperview];
    [self __setupUI];
    [self reloadPhotoUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (void)dealloc
{
    
}

- (NSArray *)photoDatas
{
    return self.albumLoader.photoDatas;
}

- (id<IGDorisAlbumLoader>)albumLoader
{
    return self.configuration.albumLoader;
}

- (NSArray *)selectDatas
{
    if ([self.albumLoader respondsToSelector:@selector(fetchSelectObjects)]) {
        return [self.configuration.albumLoader fetchSelectObjects];
    }
    return nil;
}

#pragma mark - setup UI

- (void)__setupUI
{
    [self __setupCollectionView];
}

- (void)__setupCollectionView
{
    UICollectionViewFlowLayout * layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    /// Tips:在iOS 10中，引入了新的单元预取API 启用此功能会显著降低滚动性能。
    if(@available(iOS 10.0, *))  {
        _collectionView.prefetchingEnabled = NO;
    }
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = self.view.bounds;
    NSArray * array = [self.configuration.photoLoader registerCellClass];
    NSAssert(array.count > 0, @"没有注册photo cell class");
    if (array && array.count > 0) {
        [array enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class clazz = NSClassFromString(obj);
            if (clazz && obj) {
                [self.collectionView registerClass:clazz forCellWithReuseIdentifier:obj];
            }
        }];
    }
}

#pragma mark - load Albums

- (void)doris_loadDefaultAlbums
{
    [self __loadAlbums];
}

- (void)__loadAlbums
{
    __weak typeof(self) weakSelf = self;
    [self.albumLoader loadAlbumDatas:self.configuration quick:^BOOL(NSArray * _Nonnull collections) {
        
        return YES;
    } completion:^(NSArray * _Nonnull collections) {
        [weakSelf __loadPhotoDatasWithCollection:collections.firstObject];
    }];
}

- (void)__loadPhotoDatasWithCollection:(id)collection
{
    __weak typeof(self) weakSelf = self;
    [self.albumLoader loadPhotos:self.configuration collection:collection quick:^BOOL(NSArray * _Nonnull assets) {
        return YES;
    } completion:^(NSArray * _Nonnull assets) {
        [weakSelf reloadPhotoUI];
    }];
}

#pragma mark - action Method

- (void)reloadPhotoUI
{
    if (self.collectionView && self.collectionView.superview) {
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id object = nil;
    if (self.photoDatas.count > indexPath.item) {
        object =  [self.photoDatas objectAtIndex:indexPath.item];
    }
    NSString * identifier = [self.configuration.photoLoader generateCellClassIdentify:object];
    UICollectionViewCell<IGDorisPhotoPickerCell> * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(configurePhotoController:)]) {
        [cell configurePhotoController:self];
    }
    if ([cell respondsToSelector:@selector(configureWithObject:withIndex:)]) {
        [cell configureWithObject:object withIndex:indexPath.item];
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellWidth, self.cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.configuration.appearance.edgeInset;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.configuration.appearance.pickerPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.configuration.appearance.pickerPadding;
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.dorisSwipeTransition __scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.dorisSwipeTransition __scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.dorisSwipeTransition __scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)__updatePickerUIStatus
{
    NSArray * cells = [self.collectionView visibleCells];
    NSArray * indexPaths = [self.collectionView indexPathsForVisibleItems];
    [cells enumerateObjectsUsingBlock:^(UICollectionViewCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj respondsToSelector:@selector(updatePhotoCellStatus:)]) {
            UICollectionViewCell<IGDorisPhotoPickerCell> * cell = (id)obj;
            NSIndexPath * indexPath = [indexPaths g_objectAtIndexSafely:idx];
            GDorisPhotoPickerBean * object = [self.photoDatas g_objectAtIndexSafely:indexPath.item];
            [cell updatePhotoCellStatus:object];
        }
    }];
}

#pragma mark - extension Method

- (BOOL)doris_canSelectAsset:(GDorisPhotoPickerBean *)object
{
    id<IGDorisAlbumLoader> loader = self.albumLoader;
    if ([loader respondsToSelector:@selector(checkPhotoCanSelected:config:)]) {
        return  [loader checkPhotoCanSelected:object config:self.configuration];
    }
    return YES;
}

- (void)doris_didSelectAsset:(GDorisPhotoPickerBean *)object
{
    id<IGDorisAlbumLoader> loader = self.albumLoader;
    if (loader && [loader respondsToSelector:@selector(photoDidSelected:config:)]) {
        [loader photoDidSelected:object config:self.configuration];
    }
    [self __updatePickerUIStatus];
}

- (void)doris_didDeselectAsset:(GDorisPhotoPickerBean *)object
{
    id<IGDorisAlbumLoader> loader = self.albumLoader;
    if (loader && [loader respondsToSelector:@selector(photoDidDeselected:config:)]) {
        [loader photoDidDeselected:object config:self.configuration];
    }
    [self __updatePickerUIStatus];
}

#pragma mark - GDorisZoomPresentingAdapter

- (__kindof UIView *)presentingView
{
    if (self.clickIndexPath) {
        NSInteger index = self.clickIndexPath.item;
        if (self.photoDatas.count <= index) {
            return nil;
        }
        UICollectionViewCell<IGDorisPhotoPickerCell> *cell = (id)[self.collectionView cellForItemAtIndexPath:self.clickIndexPath];
        self.clickIndexPath = nil;
        if (cell && [cell respondsToSelector:@selector(doris_containerView)]) {
            return [cell doris_containerView];
        }
    }
    return nil;
}

- (__kindof UIView *)presentingViewAtIndex:(NSInteger)index
{
    if (self.photoDatas.count <= index) {
        return nil;
    }
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell<IGDorisPhotoPickerCell> *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    if (cell && [cell respondsToSelector:@selector(doris_containerView)]) {
        return [cell doris_containerView];
    }
    return nil;
}

@end
