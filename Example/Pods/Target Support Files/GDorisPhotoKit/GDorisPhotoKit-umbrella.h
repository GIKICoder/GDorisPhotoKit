#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GDorisLoaderController.h"
#import "GDorisLoaderOperation.h"
#import "GDorisLoaderQueue.h"
#import "GDorisProgressObserver.h"
#import "GDorisPhotoPickerBrowserController.h"
#import "GDorisPhotoPickerController.h"
#import "IGDorisPhotoPickerDelegate.h"
#import "GDorisAlbumLoader.h"
#import "GDorisPhotoLoader.h"
#import "GDorisPhotoLoaderOperation.h"
#import "GDorisPickerBrowserLoader.h"
#import "UIImageView+GDorisLoader.h"
#import "GDorisPhotoAlbumCell.h"
#import "GDorisPhotoAlbumTableView.h"
#import "GDorisPickerBrowserCell.h"
#import "GDorisPickerBrowserNavigationBar.h"
#import "GDorisPickerBrowserThumbnailView.h"
#import "GDorisPickerBrowserVideoCell.h"
#import "GDorisPickerNavigationBar.h"
#import "GDorisPickerToolView.h"
#import "GDorisPhotoHelper.h"
#import "NSArray+GDoris.h"
#import "UIControl+GDoris.h"
#import "UIImage+GDoris.h"
#import "UIView+GDoris.h"
#import "GAsset.h"
#import "GAssetsGroup.h"
#import "GAssetsManager.h"
#import "GDorisBrowserBaseCell.h"
#import "GDorisPhotoBrowserBaseController.h"
#import "IGDorisPhotoBrower.h"
#import "GDorisAnimatedButton.h"
#import "GDorisPhotoAppearance.h"
#import "GDorisPhotoCameraCell.h"
#import "GDorisPhotoConfiguration.h"
#import "GDorisPhotoPickerBaseController.h"
#import "GDorisPhotoPickerBaseInternal.h"
#import "GDorisPhotoPickerBean.h"
#import "GDorisPhotoPickerCell.h"
#import "IGDorisPhotoPicker.h"
#import "GDorisGIFEditerController.h"
#import "GDorisPhotoEditerController.h"
#import "GDorisGIFCreator.h"
#import "GDorisGIFCutControlView.h"
#import "GDorisGIFCutView.h"
#import "GDorisGIFMetalData.h"
#import "GDorisCropOverlayView.h"
#import "GDorisCropScrollView.h"
#import "GDorisCropView.h"
#import "GDorisEditerCropController.h"
#import "UIImage+GDorisCropRotate.h"
#import "GDorisCanvasLayerView.h"
#import "GDorisCanvasView.h"
#import "GDorisDaub.h"
#import "GDorisDrawing.h"
#import "GDorisLine.h"
#import "GDorisMark.h"
#import "GDorisSticker.h"
#import "GDorisVertex.h"
#import "UIImage+GDorisDraw.h"
#import "GDorisDragDropView.h"
#import "CIFilter+GDoris.h"
#import "GDorisInputColorToolbar.h"
#import "GDorisInputStylePanel.h"
#import "GDorisInputTextParse.h"
#import "GDorisInputToolbar.h"
#import "GDorisInputViewController.h"
#import "GDorisTextStyleItem.h"
#import "GDorisEditerColorPanel.h"
#import "GDorisEditerCropToolbar.h"
#import "GDorisEditerHitTestView.h"
#import "GDorisEditerNavigationBar.h"
#import "GDorisEditerToolbar.h"
#import "GDorisFilterToolbar.h"
#import "GDorisSliderView.h"
#import "NSURL+SDPhotoPlugin.h"
#import "PHImageRequestOptions+SDPhotoPlugin.h"
#import "SDPhotosDefine.h"
#import "SDPhotosError.h"
#import "SDPhotosLoader.h"
#import "SDPhotosPlugin.h"
#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisScrollerPanGesutreRecognizer.h"
#import "GDorisSwipeGestureTransition.h"

FOUNDATION_EXPORT double GDorisPhotoKitVersionNumber;
FOUNDATION_EXPORT const unsigned char GDorisPhotoKitVersionString[];

