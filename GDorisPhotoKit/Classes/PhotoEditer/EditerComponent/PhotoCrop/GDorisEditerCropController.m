//
//  GDorisEditerCropController.m
//  XCChat
//
//  Created by GIKI on 2019/12/24.
//  Copyright © 2019 xiaochuankeji. All rights reserved.
//

#import "GDorisEditerCropController.h"
#import "GDorisPhotoHelper.h"
#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisCropView.h"
#import "GDorisEditerCropToolbar.h"
#import "UIView+GDoris.h"
#import "UIImage+GDorisCropRotate.h"
@interface GDorisEditerCropController ()
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) GDorisCropView * cropView;
@property (nonatomic, strong) GDorisEditerCropToolbar * toolbar;
@end

@implementation GDorisEditerCropController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:({
        _cropView = [[GDorisCropView alloc] initWithImage:self.image];
        _cropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cropView.backgroundColor = UIColor.blackColor;
        _cropView.foregroundContainerView.backgroundColor = UIColor.blackColor;
        _cropView.aspectRatioLockEnabled = NO;
        _cropView.aspectRatioLockDimensionSwapEnabled = NO;
        _cropView.gridOverlayHidden = NO;
        _cropView.cropBoxResizeEnabled = YES;
        _cropView.simpleRenderMode = NO;
        _cropView.cropViewPadding = 0;
        _cropView.cropRegionInsets = UIEdgeInsetsMake(88, 10, 114, 10);
        _cropView;
    })];
    [self.view addSubview:({
        _toolbar = [[GDorisEditerCropToolbar alloc] initWithFrame:CGRectMake(0,self.view.g_height-113, self.view.g_width, 113)];
        __weak typeof(self) weakSelf = self;
        _toolbar.dorisCropToolbarActionBlock = ^(DorisEditerCropToolbarType itemType) {
            [weakSelf cropToolbarAction:itemType];
        };
        _toolbar;
    })];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    {
        CGFloat left = 0;
        CGFloat top = 0;//64;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height; //self.translucencyView.frame = self.bounds;
        self.cropView.frame = CGRectMake(left, top, width, height);
        [self.cropView moveCroppedContentToCenterAnimated:YES];
        [self.cropView performInitialSetup];
    }
}

- (void)cropToolbarAction:(DorisEditerCropToolbarType)itemType
{
    switch (itemType) {
        case DorisEditerCropToolbarClose:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case DorisEditerCropToolbarReset:
        {
            [self.cropView resetLayoutToDefaultAnimated:YES];
        }
            break;
        case DorisEditerCropToolbarRotate:
        {
            [self.cropView rotateImageNinetyDegreesAnimated:YES];
        }
            break;
        case DorisEditerCropToolbarDone:
        {
            if ([self.cropView canBeReset]) {
                UIImage * image =  [self.image croppedImageWithFrame:self.cropView.imageCropFrame angle:self.cropView.angle circularClip:NO];
                if (self.doirsEditerCropImageAction) {
                    self.doirsEditerCropImageAction(image);
                }
            }
            [self dismissViewControllerAnimated:NO completion:nil];
        }
            break;
        default:
            break;
    }
}
@end
