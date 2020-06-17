//
//  GDorisLoaderQueue.m
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/16.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisLoaderQueue.h"

@interface GDorisLoaderQueue ()<GDorisLoaderOperationDelegate>

@end

@implementation GDorisLoaderQueue

+ (instancetype)queueWithName:(NSString *)queueName
{
    GDorisLoaderQueue * queue  = [GDorisLoaderQueue new];
    queue.queue.name = queueName;
    return queue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _operations = [[NSMutableDictionary alloc] init];
        _progressObservers = [[NSMutableSet alloc] init];
        _maxQueuedOperationsCount = INT_MAX;
    }
    return self;
}

- (void)dealloc
{
    _operationsObserver = nil;
}

#pragma mark - Public Method

- (void)addOperation:(GDorisLoaderOperation *)operation
{
    if (!operation || ![operation isKindOfClass:GDorisLoaderOperation.class]) {
        NSAssert(nil, @"operation is must GDorisLoaderOperation subclass");
        return;
    }
    if ([self fetchOperationWithIdentifier:operation.identifier] != nil) {
        operation.identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    
    @synchronized (self.operations) {
        [self.operations setObject:operation forKey:operation.identifier];
        operation.delegate = self;
    }
    [self.queue addOperation:operation];
    
    if (self.maxQueueOperationCountReached) {
        if ([self.operationsObserver respondsToSelector:@selector(maxQueuedOperationsReachedForQueue:)])
        {
            [self.operationsObserver maxQueuedOperationsReachedForQueue:self];
        }
    } else {
        if ([self.operationsObserver respondsToSelector:@selector(canBeginSubmittingOperationsForQueue:)])
        {
            [self.operationsObserver canBeginSubmittingOperationsForQueue:self];
        }
    }
}

- (void)removeOperation:(GDorisLoaderOperation *)operation
{
    @synchronized (self.operations) {
        if (![self.operations objectForKey:operation.identifier]) {
            return;
        }
        [self.operations removeObjectForKey:operation.identifier];
        [self.progressObservers makeObjectsPerformSelector:@selector(runProgressBlockWithCurrentOperationCount:)
                                                       withObject:@(self.operationCount)];
    }
}

- (void)cancelAllOperations
{
    [self.queue cancelAllOperations];
    [self setSuspended:NO];
}

- (void)cancelOperationWithIdentifier:(id)identifier
{
    GDorisLoaderOperation * op = [self fetchOperationWithIdentifier:identifier];
    [op cancel];
}

#pragma mark - revise Priority

- (BOOL)reviseOperationPriority:(NSOperationQueuePriority)priority
                 withIdentifier:(NSString *)identifier
{
    GDorisLoaderOperation * op = [self fetchOperationWithIdentifier:identifier];
    if (!op) {
        return NO;
    }
    [op setQueuePriority:priority];
    return YES;
}

#pragma mark - ProgressObserver

- (void)addProgressObserver:(GDorisProgressObserver *)observer
{
    @synchronized (self.progressObservers) {
        observer.startingOperationCount = self.operationCount;
        [self.progressObservers addObject:observer];
    }
}

- (void)removeProgressObserver:(GDorisProgressObserver *)observer
{
    @synchronized (self.progressObservers) {
        [self.progressObservers removeAllObjects];
    }
}

- (void)removeAllProgressObservers
{
    @synchronized (self.progressObservers)
    {
        [self.progressObservers removeAllObjects];
    }
}
#pragma mark - State Method

- (BOOL)isExecuting
{
    return (self.operationCount > 0);
}

- (BOOL)isFinished
{
    return (self.operationCount == 0);
}

- (BOOL)isSuspended
{
    return self.queue.isSuspended;
}

- (void)setSuspended:(BOOL)suspend
{
    [self.queue setSuspended:suspend];
}

- (BOOL)maxQueueOperationCountReached
{
    return (self.operationCount >= self.maxQueuedOperationsCount);
}

- (void)setMaxConcurrentOperationCount:(NSUInteger)count
{
    [self.queue setMaxConcurrentOperationCount:count];
}

#pragma mark - Accessors

- (NSString *)name
{
    return self.queue ? self.queue.name : nil;
}

- (NSUInteger)operationCount
{
    return self.operations.count;
}

- (GDorisLoaderOperation *)fetchOperationWithIdentifier:(NSString *)identifier
{
    if (!identifier) {
        return nil;
    }
    GDorisLoaderOperation * op = [self.operations objectForKey:identifier];
    return op;
}
#pragma mark - Private Method

- (void)queueDidFinish
{
    [self.progressObservers makeObjectsPerformSelector:@selector(runCompletionBlock)];
    [self removeAllProgressObservers];
}

#pragma mark - GDorisLoaderOperationDelegate

- (void)dorisOperationDidFinish:(GDorisLoaderOperation *)operation
{
    [self removeOperation:operation];
    
    if (!self.maxQueueOperationCountReached) {
        if ([self.operationsObserver respondsToSelector:@selector(canBeginSubmittingOperationsForQueue:)])
               {
                   [self.operationsObserver canBeginSubmittingOperationsForQueue:self];
               }
    }
    if (self.operationCount == 0) {
        [self queueDidFinish];
    }
}

- (void)dorisOperationHasCanceled:(GDorisLoaderOperation *)operation
{
    
}
@end
