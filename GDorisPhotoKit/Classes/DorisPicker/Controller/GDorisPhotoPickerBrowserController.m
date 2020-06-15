//
//  GDorisPhotoPickerBrowserController.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/4.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerBrowserController.h"
#import "GDorisPickerBrowserNavigationBar.h"
#import "GDorisPickerToolView.h"
#import "GDorisPhotoHelper.h"
#import "GDorisPickerBrowserLoader.h"
#import "GDorisPhotoPickerBean.h"
#import "GDorisPickerBrowserThumbnailView.h"
#import "GAsset.h"
#import "GDorisPhotoEditerController.h"

#define GDorisPickerBrowserToolbarHeight (40+GDoris_TabBarMargin)

@interface GDorisPhotoPickerBrowserController ()<GDorisBrowserBaseCellDelegate>
@property (nonatomic, strong) GDorisPickerBrowserNavigationBar * browserNaviBar;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) GDorisPickerToolView * toolBarView;
@property (nonatomic, strong) GDorisPickerBrowserThumbnailView * thumbnailView;
@end

@implementation GDorisPhotoPickerBrowserController

- (instancetype)initWithPhotoItems:(NSArray *)photos beginIndex:(NSUInteger)index
{
    self = [super initWithPhotoItems:photos beginIndex:index];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.browerLoader = [GDorisPickerBrowserLoader new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - setupUI

- (void)setupUI
{
    self.browserNaviBar = [[GDorisPickerBrowserNavigationBar alloc] init];
    [self.view addSubview:self.browserNaviBar];
    
    __weak typeof(self) weakSelf = self;
    self.browserNaviBar.closeAction = ^{
        [weakSelf cancelBrowser];
    };
    self.browserNaviBar.selectAction = ^{
        [weakSelf selectAsset];
    };
    
    self.bottomView = [UIView new];
    self.bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-GDorisPickerBrowserToolbarHeight-80, [UIScreen mainScreen].bounds.size.width, GDorisPickerBrowserToolbarHeight+80);
    [self.view addSubview:self.bottomView];
    
    self.toolBarView = [[GDorisPickerToolView alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, GDorisPickerBrowserToolbarHeight)];
    self.toolBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.toolBarView.rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.bottomView addSubview:self.toolBarView];
    self.toolBarView.photoToolbarClickBlock = ^(DorisPickerToolbarType itemType) {
        [weakSelf photoToolbarClickAction:itemType];
    };
    
    self.thumbnailView = [[GDorisPickerBrowserThumbnailView alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width, 80)];
    self.thumbnailView.hidden = YES;
    self.thumbnailView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.bottomView addSubview:self.thumbnailView];
    self.thumbnailView.thumbnailCellDidSelect = ^(GDorisPhotoPickerBean * _Nonnull asset) {
        [weakSelf processSelectCount:asset];
         NSIndexPath * indexPath = [NSIndexPath indexPathForItem:asset.index inSection:0];
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
    };
    [self processThumbnailView];
}


- (void)cancelBrowser
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)photoToolbarClickAction:(DorisPickerToolbarType)itemType
{
    if (itemType == DorisPickerToolbarRight) {
        [self sendConfirmAction];
    } else if (itemType == DorisPickerToolbarLeft) {
        [self openEditerPage];
    }
}

- (void)openEditerPage
{
    GDorisPhotoPickerBean * bean = [self.photoDatas g_objectAtIndexSafely:self.currentIndex];
    GAsset * asset = bean.asset;
    GDorisPhotoEditerController  * controller = [GDorisPhotoEditerController photoEditerWithImage:[asset previewImage]];
    controller.userInfo = asset;
    controller.delegate = self;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:NO completion:nil];
}

- (void)sendConfirmAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didFinishPickerPhotos:)]) {
        NSArray * array = [self fetchSelectedPhotos];
        [self.delegate dorisPhotoBrowser:self didFinishPickerPhotos:array];
    }
}

- (void)selectAsset
{
    GDorisPhotoPickerBean * bean = [self.photoDatas g_objectAtIndexSafely:self.currentIndex];
    if (bean.isSelected) {
        [self didDeSelectPhotoBean:bean];
    } else {
        BOOL temp = [self canSelectPhoto:bean];
        if (!temp) {
            return;
        }
        [self didSelectPhotoBean:bean];
    }
    [self processThumbnailView];
    [self processSelectCount:bean];
    [self.browserNaviBar popAnimated];
}

- (void)processSelectCount:(GDorisPhotoPickerBean *)bean
{
    self.browserNaviBar.selected = bean.isSelected;
    self.browserNaviBar.selectIndex = bean.selectIndex;
    [self.thumbnailView scrollToIndex:bean.isSelected ? bean.selectIndex : -1];
}

- (void)processThumbnailView
{
    NSArray * selects = [self fetchSelectedPhotos];
    self.thumbnailView.hidden = !(selects.count > 0);
    [self.thumbnailView configDorisAssetItems:selects];
    self.toolBarView.enabled = (selects.count > 0);
    if (selects.count > 0) {
        NSString * msg = [NSString stringWithFormat:@"确定(%ld)",selects.count];
        [self.toolBarView.rightButton setTitle:msg forState:UIControlStateNormal];
    } else {
        [self.toolBarView.rightButton setTitle:@"确定" forState:UIControlStateNormal];
    }
}

- (NSArray *)fetchSelectedPhotos
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowserSelectedPhotos:)]) {
       return [self.delegate dorisPhotoBrowserSelectedPhotos:self];
    }
    return nil;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    dispatch_block_t block = ^{
        self.browserNaviBar.hidden = hidden;
        self.bottomView.hidden = hidden;
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            block();
        } completion:^(BOOL finished) {
        }];
    } else {
        block();
    }
}

#pragma mark - private method

- (BOOL)canSelectPhoto:(GDorisPhotoPickerBean *)bean
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:shouldSelectPhoto:)]) {
        BOOL can = [self.delegate dorisPhotoBrowser:self shouldSelectPhoto:bean];
        return can;
    }
    return YES;
}

- (void)didSelectPhotoBean:(GDorisPhotoPickerBean *)bean
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didSelectPhoto:)]) {
        [self.delegate dorisPhotoBrowser:self didSelectPhoto:bean];
    }
}

- (void)didDeSelectPhotoBean:(GDorisPhotoPickerBean *)bean
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didDeselectPhoto:)]) {
        [self.delegate dorisPhotoBrowser:self didDeselectPhoto:bean];
    }
}

#pragma mark - UICollection Delegate/Datasource

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    GDorisPhotoPickerBean * bean = [self.photoDatas objectAtIndex:indexPath.item];
    if (bean.isCamera) {
        NSInteger index = indexPath.item;
        if (indexPath.item == 0) {
            index ++;
        } else {
            index --;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:indexPath.section] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        return;
    }
    [self processSelectCount:bean];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)showPlay:(NSURL *)URL
{
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [super scrollViewDidEndDecelerating:scrollView];
    GDorisPhotoPickerBean * bean = [self.photoDatas g_objectAtIndexSafely:self.currentIndex];
    [self processSelectCount:bean];
}

#pragma mark - GDorisBrowserBaseCell delegate

- (void)dorisBrowserCell:(GDorisBrowserBaseCell *)cell didTapPhoto:(GDorisPhotoPickerBean *)object
{
    GDorisPhotoPickerBean * bean = object;
    GAsset * asset = bean.asset;
    if (asset.assetType == GAssetTypeVideo) {
        __weak typeof(self) weakSelf = self;
        [asset exportVideoOutputPathSuccess:^(NSURL * _Nonnull fileUrl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showPlay:fileUrl];
            });
        } failure:^(NSString * _Nonnull errorMessage, NSError * _Nonnull error) {
            
        }];
    }

}

#pragma mark - GDorisZoomGestureHandlerProtocol

- (void)beginGestureHandler:(CGFloat)progress
{
    [self setToolbarHidden:YES animated:NO];
}

- (void)endGestureHandler:(BOOL)isCanceled
{
    if (isCanceled) {
        [self setToolbarHidden:NO animated:NO];
    }
}

- (CGRect)gestureEffectiveFrame
{
    if (self.browserNaviBar.hidden) {
        return self.view.bounds;
    } else {
        return CGRectMake(0, self.browserNaviBar.g_bottom, self.view.g_width,self.view.g_height - self.browserNaviBar.g_bottom - self.thumbnailView.g_height-self.toolBarView.g_height);
    }
}
@end
