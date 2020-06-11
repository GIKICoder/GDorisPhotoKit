//
//  GDorisPhotoPickerBaseController.h
//  GDoris
//
//  Created by GIKI on 2020/3/22.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoConfiguration.h"
#import "GDorisSwipeGestureTransition.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoPickerBaseController : UIViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,GDorisSwipeGestureTargetAdpter>

- (instancetype)initWithConfiguration:(GDorisPhotoConfiguration *)configuration;

@property (nonatomic, strong) GDorisPhotoConfiguration * configuration;

@end

NS_ASSUME_NONNULL_END
