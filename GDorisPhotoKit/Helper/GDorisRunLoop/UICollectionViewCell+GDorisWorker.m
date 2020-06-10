//
//  UICollectionViewCell+GDorisWorker.m
//  XCChat
//
//  Created by GIKI on 2019/8/26.
//  Copyright © 2019 xiaochuankeji. All rights reserved.
//

#import "UICollectionViewCell+GDorisWorker.h"
#import <objc/runtime.h>
@implementation UICollectionViewCell (GDorisWorker)
@dynamic currentIndexPath;

- (NSIndexPath *)currentIndexPath {
    NSIndexPath *indexPath = objc_getAssociatedObject(self, @selector(currentIndexPath));
    return indexPath;
}

- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath {
    objc_setAssociatedObject(self, @selector(currentIndexPath), currentIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UITableViewCell (GDorisWorker)
@dynamic currentIndexPath;

- (NSIndexPath *)currentIndexPath {
    NSIndexPath *indexPath = objc_getAssociatedObject(self, @selector(currentIndexPath));
    return indexPath;
}

- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath {
    objc_setAssociatedObject(self, @selector(currentIndexPath), currentIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
