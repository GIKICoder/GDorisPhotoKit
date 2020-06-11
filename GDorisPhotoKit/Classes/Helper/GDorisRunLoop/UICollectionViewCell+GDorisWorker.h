//
//  UICollectionViewCell+GDorisWorker.h
//  XCChat
//
//  Created by GIKI on 2019/8/26.
//  Copyright © 2019 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (GDorisWorker)
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@end

@interface UITableViewCell (GDorisWorker)
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@end

NS_ASSUME_NONNULL_END
