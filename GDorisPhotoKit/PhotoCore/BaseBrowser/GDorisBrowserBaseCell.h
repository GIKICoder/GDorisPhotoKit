//
//  GDorisBrowserBaseCell.h
//  GDoris
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGDorisPhotoBrower.h"
NS_ASSUME_NONNULL_BEGIN

/// ScrollView 滚动监听
FOUNDATION_EXPORT NSString *const GDORIS_BROWSER_SCROLLER_DID_NOTIFICATION;

@interface GDorisBrowserBaseCell : UICollectionViewCell<IGDorisBrowerCellProtocol>

@property (nonatomic, weak  ) id<GDorisBrowserBaseCellDelegate>   delegate;
@property (nonatomic, strong, readonly) UIScrollView  *scrollView;
@property (nonatomic, strong, readonly) __kindof id browserObject;
@property (nonatomic, assign) BOOL  zoomEnabled;
@property (nonatomic, assign) CGSize  scrollSize;


- (void)resetScrollViewZoom;
- (void)fitImageSize:(CGSize)imageSize
containerSize:(CGSize)containerSize
    completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed;

@end

NS_ASSUME_NONNULL_END
