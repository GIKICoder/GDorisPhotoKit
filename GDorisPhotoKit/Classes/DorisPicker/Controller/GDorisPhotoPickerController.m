//
//  GDorisPhotoPickerController.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerController.h"
#import "GDorisPhotoPickerBaseInternal.h"
#import "GDorisPickerNavigationBar.h"
#import "GDorisPhotoHelper.h"
#import "GDorisPickerToolView.h"
#import <Photos/PHPhotoLibrary.h>
#import "GDorisPhotoAlbumTableView.h"
#import "GDorisPhotoPickerBrowserController.h"

#define GDorisPhotoPickerToolbarHeight (40+GDoris_TabBarMargin)

@interface GDorisPhotoPickerController ()<PHPhotoLibraryChangeObserver,UICollectionViewDelegateFlowLayout,GDorisZoomPresentingAdapter,GDorisPhotoPickerBrowserDelegate>
@property (nonatomic, strong) GDorisPickerNavigationBar * pickerNavBar;
@property (nonatomic, strong) GDorisPickerToolView * toolBarView;
@property (nonatomic, strong) UIView * notAuthorizedView;
@property (nonatomic, strong) GDorisPhotoAlbumTableView * albumListView;
@property (nonatomic, strong) UIActivityIndicatorView * indicatorView;
@end

@implementation GDorisPhotoPickerController

- (instancetype)initWithConfiguration:(GDorisPhotoConfiguration *)configuration
{
    self = [super initWithConfiguration:configuration];
    if (self) {
        configuration.appearance.edgeInset = UIEdgeInsetsMake(GDorisNavBarContentHeight, 4, GDorisPhotoPickerToolbarHeight, 4);
        BOOL author = [self.albumLoader photoAuthorizationStatusAuthorized];
        if (author) {
            [self loadAlbums];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadPhotoChangeObserver];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.toolBarView.frame = CGRectMake(0, self.view.g_height-GDorisPhotoPickerToolbarHeight, [UIScreen mainScreen].bounds.size.width, GDorisPhotoPickerToolbarHeight);
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - load Datas

- (void)loadPhotoChangeObserver
{
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)requestAuthorized
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus phStatus) {
        if (phStatus == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.notAuthorizedView.hidden = YES;
                [self loadAlbums];
            });
        }
    }];
}

- (void)loadAlbums
{
    __weak typeof(self) weakSelf = self;
    [self.albumLoader loadAlbumDatas:self.configuration quick:^BOOL(NSArray * _Nonnull collections) {
        [weakSelf loadPhotoDatasWithCollection:collections.firstObject];
        return YES;
    } completion:^(NSArray * _Nonnull collections) {
        [weakSelf.albumListView fulFill:collections selectIndex:0];
    }];
}

- (void)loadPhotoDatasWithCollection:(id)collection
{
    __weak typeof(self) weakSelf = self;
    [self updateAlbumTitleWithCollection:collection];
    [self.albumLoader loadPhotos:self.configuration collection:collection quick:^BOOL(NSArray * _Nonnull assets) {
        [weakSelf reloadPhotoUI];
        if (weakSelf.indicatorView && [weakSelf isViewLoaded]) {
            [weakSelf.indicatorView stopAnimating];
        }
        return YES;
    } completion:^(NSArray * _Nonnull assets) {
        if (weakSelf.indicatorView && [weakSelf isViewLoaded]) {
            [weakSelf.indicatorView stopAnimating];
        }
        [weakSelf reloadPhotoUI];
    }];
}

- (void)updateAlbumTitleWithCollection:(id)collection
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.albumLoader respondsToSelector:@selector(fetchAlbumTitleString:)]) {
            weakSelf.pickerNavBar.titleLabel.text = [self.albumLoader fetchAlbumTitleString:collection];
        }
    });
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.pickerNavBar = [[GDorisPickerNavigationBar alloc] initWithCustomBar:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GDorisNavBarContentHeight)];
    [self.view addSubview:self.pickerNavBar];
    self.pickerNavBar.titleLabel.text = @"相机胶卷";
    __weak typeof(self) weakSelf = self;
    self.pickerNavBar.closeAction = ^{
        [weakSelf cancelVC];
    };
    self.pickerNavBar.tapAlbumAction = ^(BOOL selected) {
        if (selected) {
            [weakSelf.albumListView show];
        } else {
            [weakSelf.albumListView dismiss];
        }
    };
    
    self.toolBarView = [[GDorisPickerToolView alloc] initWithFrame:CGRectMake(0, self.view.g_height-GDorisPhotoPickerToolbarHeight, [UIScreen mainScreen].bounds.size.width, GDorisPhotoPickerToolbarHeight)];
    [self.toolBarView.rightButton setTitle:self.configuration.functionTitle forState:UIControlStateNormal];
    [self.view addSubview:self.toolBarView];
    
    BOOL author = [self.albumLoader photoAuthorizationStatusAuthorized];
    if (!author) {
        self.notAuthorizedView.hidden = NO;
        [self.view bringSubviewToFront:self.notAuthorizedView];
        [self.view bringSubviewToFront:self.pickerNavBar];
        [self requestAuthorized];
    } else if(!self.albumLoader.photoDatas) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
        self.indicatorView.center = CGPointMake(self.view.g_centerX, 200);
    }
    [self setupAlbumListView];
}

- (void)setupAlbumListView
{
    self.albumListView = [[GDorisPhotoAlbumTableView alloc] init];
    [self.view addSubview:self.albumListView];
    [self.albumListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(self.pickerNavBar.mas_bottom);
    }];
    __weak typeof(self) weakSelf = self;
    self.albumListView.selectPhotoAlbum = ^(id _Nonnull assetsGroup) {
        [weakSelf loadPhotoDatasWithCollection:assetsGroup];
    };
    self.albumListView.photoAlbumDismiss = ^{
        [weakSelf.pickerNavBar configureSelected:NO];
    };
}


- (UIView *)notAuthorizedView
{
    if (!_notAuthorizedView) {
        _notAuthorizedView = [[UIView alloc] init];
        [self.view addSubview:_notAuthorizedView];
        _notAuthorizedView.backgroundColor = UIColor.whiteColor;
        _notAuthorizedView.frame = self.view.bounds;
        UILabel * label = [UILabel new];
        label.text = @"开启相册权限,分享更好的自己";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [GDorisPhotoHelper colorWithHex:@"262626"];
        [_notAuthorizedView addSubview:label];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[GDorisPhotoHelper colorWithHex:@"FFFFFF"] forState:UIControlStateNormal];
        button.backgroundColor = [GDorisPhotoHelper colorWithHex:@"F65758"];
        button.layer.cornerRadius = 20;
        button.layer.masksToBounds = YES;
        [button setTitle:@"去开启" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(authorizationStatusAction) forControlEvents:UIControlEventTouchUpInside];
        [_notAuthorizedView addSubview:button];
        [_notAuthorizedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(120);
        }];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120, 40));
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(label.mas_bottom).mas_offset(25);
        }];
    }
    return _notAuthorizedView;
}

#pragma mark - override

- (BOOL)doris_canSelectAsset:(GDorisPhotoPickerBean *)object
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:shouldSelectAsset:)]) {
        return [self.delegate dorisPhotoPicker:self shouldSelectAsset:object.asset];
    }
    return [super doris_canSelectAsset:object];
}

- (void)doris_didDeselectAsset:(GDorisPhotoPickerBean *)object
{
    [super doris_didDeselectAsset:object];
    [self configureSelectCount];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didDeselectAsset:)]) {
        [self.delegate dorisPhotoPicker:self didDeselectAsset:object.asset];
    }
    [self photoSelectedChanged];
}

- (void)doris_didSelectAsset:(GDorisPhotoPickerBean *)object
{
    [super doris_didSelectAsset:object];
    [self configureSelectCount];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didSelectAsset:)]) {
        [self.delegate dorisPhotoPicker:self didSelectAsset:object.asset];
    }
    [self photoSelectedChanged];
}

- (void)configureSelectCount
{
    self.toolBarView.enabled = (self.selectDatas.count > 0);
    NSString * title = self.configuration.functionTitle;
    if (self.selectDatas.count > 0) {
        NSString * msg = [NSString stringWithFormat:@"%@(%ld)",title,self.selectDatas.count];
        [self.toolBarView.rightButton setTitle:msg forState:UIControlStateNormal];
    } else {
        [self.toolBarView.rightButton setTitle:title forState:UIControlStateNormal];
    }
}

- (void)photoSelectedChanged
{
    NSArray * array = [self fetchSelectAssets];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:selectItemsChanged:)]) {
        [self.delegate dorisPhotoPicker:self selectItemsChanged:array];
    }
}

- (NSArray *)fetchSelectAssets
{
    NSArray * objects = [self.albumLoader fetchSelectObjects];
    __block NSMutableArray * arrayM = [NSMutableArray array];
    [objects enumerateObjectsUsingBlock:^(GDorisPhotoPickerBean *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.asset) {
            [arrayM addObject:obj.asset];
        }
    }];
    return arrayM.copy;
}
#pragma mark - UICollection Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    self.clickIndexPath = indexPath;
    GDorisPhotoPickerBrowserController * controller = [[GDorisPhotoPickerBrowserController alloc] initWithPhotoItems:self.photoDatas beginIndex:indexPath.item];
    controller.functionTitle = self.configuration.functionTitle;
    controller.delegate = self;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];
    self.transition = [GDorisPhotoZoomAnimatedTransition zoomAnimatedWithPresenting:self presented:controller];
    nav.transitioningDelegate = self.transition;
    nav.modalPresentationStyle = UIModalPresentationCustom;
    nav.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}
#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    [self loadAlbums];
}

#pragma mark - GDorisPhotoPickerBrowserDelegate

- (BOOL)dorisPhotoBrowser:(GDorisPhotoBrowserBaseController *)browser shouldSelectPhoto:(GDorisPhotoPickerBean *)bean
{
    return [self doris_canSelectAsset:bean];
}

- (void)dorisPhotoBrowser:(GDorisPhotoBrowserBaseController *)browser didSelectPhoto:(GDorisPhotoPickerBean *)bean
{
    [self doris_didSelectAsset:bean];
}

- (void)dorisPhotoBrowser:(GDorisPhotoBrowserBaseController *)browser didDeselectPhoto:(GDorisPhotoPickerBean *)bean
{
    [self doris_didDeselectAsset:bean];
}


/**
 获取已经选中的相册资源
 
 @param browser GDorisPhotoPickerBrowserController
 @return selectItems
 */
- (NSArray<GDorisPhotoPickerBean *> *)dorisPhotoBrowserSelectedPhotos:(GDorisPhotoPickerBrowserController *)browser
{
    if ([self.albumLoader respondsToSelector:@selector(fetchSelectObjects)]) {
        return [self.albumLoader fetchSelectObjects];
    }
    return nil;
}

/**
 选择相册资源完成后回调
 
 @param browser GDorisPhotoPickerBrowserController
 @param photos NSArray<GDorisPhotoPickerBean *>
 */
- (void)dorisPhotoBrowser:(GDorisPhotoPickerBrowserController *)browser didFinishPickerPhotos:(NSArray *)photos
{
    [browser dismissViewControllerAnimated:NO completion:nil];
    [self complection];
}

/**
 取消图片预览控制器
 
 @param browser GDorisPhotoPickerBrowserController
 */
- (void)dorisPhotoBrowserDidCancel:(GDorisPhotoPickerBrowserController *)browser
{
    
}

#pragma mark - Action Method

- (void)authorizationStatusAction
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)cancelVC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPickerDidCancel:)]) {
        [self.delegate dorisPhotoPickerDidCancel:self];
    }
    [self __cancel];
}

- (void)complection
{
    NSArray * array = [self fetchSelectAssets];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didFinishPickingAssets:)]) {
        [self.delegate dorisPhotoPicker:self didFinishPickingAssets:array];
    }
    [self __cancel];
}

- (void)__cancel
{
    if ([self.navigationController.viewControllers count] > 1){
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
@end
