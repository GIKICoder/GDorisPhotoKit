//
//  GDorisPhotoBrowserBaseController.m
//  GDoris
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowserBaseController.h"
#import "GDorisBrowserBaseCell.h"
#import <objc/runtime.h>
@interface GDorisPhotoBrowserBaseController ()
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * photoDatas;
@property (nonatomic, assign) NSInteger  beginIndex;
@end

@implementation GDorisPhotoBrowserBaseController

- (instancetype)initWithPhotoItems:(NSArray *)photos beginIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        self.photoDatas = photos;
        self.beginIndex = index;
        self.currentIndex = index;
        self.lineSpace = 20;
        self.modalPresentationStyle = UIModalPresentationCustom;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.navigationController.navigationBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.browerLoader, @"BrowerLoader 不可为Nil~");
    self.view.backgroundColor = [UIColor clearColor];
    [self __setupUI];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.navigationController.navigationBar removeFromSuperview];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(-(_lineSpace / 2), 0,self.view.bounds.size.width + _lineSpace, self.view.bounds.size.height);
    if (self.beginIndex != 0) {
        [self scrollerCollectionViewWithIndex:self.beginIndex];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc~~",NSStringFromClass([self class]));
}


#pragma mark - setup UI

- (void)__setupUI
{
    [self.view addSubview:({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.delaysContentTouches = NO;
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _collectionView;
    })];
    if (self.browerLoader && [self.browerLoader respondsToSelector:@selector(registerBrowserCellClass)]) {
        NSArray * cellclazzs = [self.browerLoader registerBrowserCellClass];
        NSAssert(cellclazzs.count > 0, @"未注册browser cell class ");
        [cellclazzs enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class clazz = NSClassFromString(obj);
            if (clazz && obj) {
                [self.collectionView registerClass:clazz forCellWithReuseIdentifier:obj];
            }
        }];
        if (cellclazzs.count <= 0) {
            [self.collectionView registerClass:GDorisBrowserBaseCell.class forCellWithReuseIdentifier:NSStringFromClass(GDorisBrowserBaseCell.class)];
        }
    } else {
        [self.collectionView registerClass:GDorisBrowserBaseCell.class forCellWithReuseIdentifier:NSStringFromClass(GDorisBrowserBaseCell.class)];
    }
    [self.collectionView reloadData];
}

#pragma mark - private Method

- (void)scrollerCollectionViewWithIndex:(NSInteger)index
{
    if (objc_getAssociatedObject(self, _cmd)) return;
    else objc_setAssociatedObject(self, _cmd, @"FirstLoadScrollerCollectionKey", OBJC_ASSOCIATION_RETAIN);
    if (index < self.photoDatas.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        CGPoint offset = CGPointMake(self.collectionView.contentOffset.x + _lineSpace*0.5, self.collectionView.contentOffset.y);
        [self.collectionView setContentOffset:offset];
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
    NSString * identifier = [self.browerLoader generateBrowerCellClassIdentify:object];
    GDorisBrowserBaseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndex = indexPath.item;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisBrowserBaseCell * cell_doris = (id)cell;
    id object = nil;
    if (self.photoDatas.count > indexPath.item) {
        object =  [self.photoDatas objectAtIndex:indexPath.item];
    }
    if (cell_doris && [cell_doris respondsToSelector:@selector(configureDidEndDisplayWithObject:withIndex:)]) {
        [cell_doris configureDidEndDisplayWithObject:object withIndex:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, _lineSpace*0.5, 0, _lineSpace*0.5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _lineSpace;
}

#pragma mark - UIScrollView Delegate 

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / ([UIScreen mainScreen].bounds.size.width + _lineSpace);
    self.currentIndex = index;
}


#pragma mark - GDorisZoomPresentedAdapter

- (__kindof UIView *)presentedView
{
    GDorisBrowserBaseCell<IGDorisBrowerCellProtocol> * cell = (id)[self.collectionView visibleCells].firstObject;
    if (cell && [cell respondsToSelector:@selector(doris_containerView)]) {
        return [cell doris_containerView];
    }
    return cell.contentView;
}

- (NSInteger)indexOfPresentedView
{
    NSIndexPath *indexpath = [self.collectionView indexPathsForVisibleItems].firstObject;
    return indexpath.item;
}

- (__kindof UIView *)presentedBackgroundView
{
    return self.collectionView;
}

- (__kindof UIScrollView *)presentedScrollView
{
    GDorisBrowserBaseCell<IGDorisBrowerCellProtocol> * cell = (id)[self.collectionView visibleCells].firstObject;
    if (!cell) {
        NSIndexPath *indexpath =  [NSIndexPath indexPathForItem:self.beginIndex inSection:0];
        cell = (id)[self.collectionView cellForItemAtIndexPath:indexpath];
    }
    if ([cell respondsToSelector:@selector(scrollView)]) {
        return [cell scrollView];
    }
    return nil;
}
@end
