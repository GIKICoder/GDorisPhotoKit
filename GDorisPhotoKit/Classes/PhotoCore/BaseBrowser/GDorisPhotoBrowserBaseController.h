//
//  GDorisPhotoBrowserBaseController.h
//  GDoris
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGDorisPhotoBrower.h"
#import "GDorisPhotoZoomAnimatedTransition.h"
NS_ASSUME_NONNULL_BEGIN
@class GDorisBrowserBaseCell;
@interface GDorisPhotoBrowserBaseController : UIViewController<UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
GDorisZoomPresentedAdapter,
GDorisBrowserBaseCellDelegate>

- (instancetype)initWithPhotoItems:(NSArray *)photos beginIndex:(NSUInteger)index;

@property (nonatomic, strong) id<IGDorisBrowerLoader>  browerLoader;
@property (nonatomic, assign) CGFloat  lineSpace;

#pragma mark - readOnly

@property (nonatomic, strong, readonly) NSArray * photoDatas;
@property (nonatomic, strong, readonly) UICollectionView * collectionView;
@property (nonatomic, assign, readonly) NSInteger  beginIndex;
@property (nonatomic, assign) NSUInteger currentIndex;


@end

NS_ASSUME_NONNULL_END
