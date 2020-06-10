//
//  IGDorisPhotoBrower.h
//  XCChat
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@class GDorisPhotoBrowserBaseController;


@protocol IGDorisBrowerCellProtocol <NSObject>

@required
- (void)configurePhotoController:(GDorisPhotoBrowserBaseController *)controller;
- (void)configureWithObject:(id)object withIndex:(NSInteger)index;

@optional
- (void)configureDidEndDisplayWithObject:(id)object withIndex:(NSInteger)index;

- (void)fitImageSize:(CGSize)imageSize
       containerSize:(CGSize)containerSize
           completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed;

- (UIView *)doris_containerView;
@end


@class GDorisBrowserBaseCell;
@protocol GDorisBrowserBaseCellDelegate <NSObject>

@optional
- (void)dorisBrowserCell:(GDorisBrowserBaseCell *)cell didTapPhoto:(id)object;

@end



@protocol IGDorisBrowerLoader <NSObject>

@required

- (NSArray<NSString *> *)registerBrowserCellClass;
- (NSString *)generateBrowerCellClassIdentify:(id)object;

- (void)loadPhotoData:(id)object
                 cell:(UICollectionViewCell<IGDorisBrowerCellProtocol> *)cell
            imageView:(__kindof UIImageView *)imageView
           completion:(void (^)(UIImage * image, NSError * error))completion;

@optional

- (void)loadVideoItem:(id)object completion:(void (^)(AVPlayerItem * item, NSError * error))completion;

@end

NS_ASSUME_NONNULL_END
