//
//  GDorisLoaderController.h
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/16.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisLoaderQueue.h"
#import "GDorisLoaderOperation.h"
#import "GDorisProgressObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisLoaderController : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary * queues;

+ (instancetype)sharedInstance;

- (BOOL)addQueue:(GDorisLoaderQueue *)queue;
- (GDorisLoaderQueue *)fetchQueueWithNamed:(NSString *)queueName;

- (void)addOperation:(GDorisLoaderOperation *)operation
          queueNamed:(NSString *)queueName;

- (BOOL)reviseOperationPriority:(NSOperationQueuePriority)priority
                 withIdentifier:(NSString *)identifier
                     queueNamed:(NSString *)queueName;

- (__kindof GDorisLoaderOperation *)fetchOperationWithIdentifier:(NSString *)identifier
                                                      queueNamed:(NSString *)queueName;

- (BOOL)containOperationWithIdentifier:(NSString *)identifier
                            queueNamed:(NSString *)queueName;

- (void)addProgressObserver:(GDorisProgressObserver *)observer queueNamed:(NSString *)queueName;

- (void)removeProgressObserver:(GDorisProgressObserver *)observer queueNamed:(NSString *)queueName;

- (NSArray *)allQueueNames;

- (NSInteger)numberOfOperationsInQueueNamed:(NSString *)queueName;

- (BOOL)hasQueues;
@end

NS_ASSUME_NONNULL_END
