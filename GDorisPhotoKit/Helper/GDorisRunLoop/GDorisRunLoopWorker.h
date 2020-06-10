//
//  GDorisRunLoopWorker.h
//  XCChat
//
//  Created by GIKI on 2019/8/26.
//  Copyright © 2019 xiaochuankeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICollectionViewCell+GDorisWorker.h"
typedef BOOL (^GDorisRunLoopWorkerBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface GDorisRunLoopWorker : NSObject

@property (nonatomic, assign) NSUInteger  maxQueueLength;

+ (instancetype)sharedInstance;

- (void)postTask:(GDorisRunLoopWorkerBlock)block withKey:(id)key;

- (void)removeAllTasks;

@end


NS_ASSUME_NONNULL_END
