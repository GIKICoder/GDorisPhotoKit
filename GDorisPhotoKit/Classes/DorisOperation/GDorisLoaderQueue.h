//
//  GDorisLoaderQueue.h
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/16.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisLoaderOperation.h"
#import "GDorisProgressObserver.h"
NS_ASSUME_NONNULL_BEGIN

@protocol GDorisQueueOperationsObserver;

@interface GDorisLoaderQueue : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue * queue;

@property (nonatomic, strong, readonly) NSMutableDictionary * operations;

@property (nonatomic, copy,   readonly) NSString * name;

@property (nonatomic, assign, readonly) NSUInteger operationCount;

@property (nonatomic, strong, readonly) NSMutableSet *progressObservers;

@property (nonatomic, assign) NSUInteger maxQueuedOperationsCount;

@property (nonatomic, readonly) BOOL maxQueueOperationCountReached;

@property (nonatomic, weak) id <GDorisQueueOperationsObserver> operationsObserver;

+ (instancetype)queueWithName:(NSString *)queueName;

- (void)addOperation:(GDorisLoaderOperation *)operation;

- (void)removeOperation:(GDorisLoaderOperation *)operation;

- (BOOL)reviseOperationPriority:(NSOperationQueuePriority)priority
                 withIdentifier:(NSString *)identifier;

- (void)cancelAllOperations;

- (void)cancelOperationWithIdentifier:(id)identifier;

- (void)setSuspended:(BOOL)suspend;

- (BOOL)isExecuting;

- (BOOL)isFinished;

- (BOOL)isSuspended;

- (void)setMaxConcurrentOperationCount:(NSUInteger)count;

- (__kindof GDorisLoaderOperation *)fetchOperationWithIdentifier:(NSString *)identifier;

- (void)addProgressObserver:(GDorisProgressObserver *)observer;

- (void)removeProgressObserver:(GDorisProgressObserver *)observer;

- (void)removeAllProgressObservers;
@end

@protocol GDorisQueueOperationsObserver <NSObject>
- (void)maxQueuedOperationsReachedForQueue:(GDorisLoaderQueue *)queue;
- (void)canBeginSubmittingOperationsForQueue:(GDorisLoaderQueue *)queue;
@end

NS_ASSUME_NONNULL_END
