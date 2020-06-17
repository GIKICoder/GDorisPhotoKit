//
//  GDorisLoaderController.m
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/16.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisLoaderController.h"

@implementation GDorisLoaderController


+ (instancetype)sharedInstance
{
    static GDorisLoaderController * inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [GDorisLoaderController new];
    });
    return inst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)addQueue:(GDorisLoaderQueue *)queue
{
    @synchronized (self.queues) {
        if (!queue) {
            NSAssert(nil, @"Cannot add a nil queue");
            return NO;
        }
        if (!queue.name) {
            NSAssert(nil, @"Cannot add a queue without name");
            return NO;
        }
        if ([self fetchQueueWithNamed:queue.name]) {
            /// already has queue named
            return NO;
        }
        [self.queues setObject:queue forKey:queue.name];
        return YES;
    }
}

- (GDorisLoaderQueue *)fetchQueueWithNamed:(NSString *)queueName
{
    GDorisLoaderQueue * queue = [self.queues objectForKey:queueName];
    return queue;
}

- (void)addOperation:(GDorisLoaderOperation *)operation
          queueNamed:(NSString *)queueName
{
    GDorisLoaderQueue * queue = [self fetchQueueWithNamed:queueName];
    NSAssert(queue, @"a queue that doesnt exist");
    
    [queue addOperation:operation];
}

- (BOOL)reviseOperationPriority:(NSOperationQueuePriority)priority
                 withIdentifier:(NSString *)identifier
                     queueNamed:(NSString *)queueName
{
    GDorisLoaderQueue * queue = [self fetchQueueWithNamed:queueName];
    return [queue reviseOperationPriority:priority withIdentifier:identifier];
}

- (__kindof GDorisLoaderOperation *)fetchOperationWithIdentifier:(NSString *)identifier
                                                      queueNamed:(NSString *)queueName
{
    GDorisLoaderQueue * queue = [self fetchQueueWithNamed:queueName];
    return [queue fetchOperationWithIdentifier:identifier];
}

- (BOOL)containOperationWithIdentifier:(NSString *)identifier
                            queueNamed:(NSString *)queueName
{
    return ([self fetchOperationWithIdentifier:identifier queueNamed:queueName] != nil);
}

- (void)addProgressObserver:(GDorisProgressObserver *)observer queueNamed:(NSString *)queueName
{
    GDorisLoaderQueue * queue = [self fetchQueueWithNamed:queueName];
    [queue addProgressObserver:observer];
}

- (void)removeProgressObserver:(GDorisProgressObserver *)observer queueNamed:(NSString *)queueName
{
    GDorisLoaderQueue * queue = [self fetchQueueWithNamed:queueName];
    [queue removeProgressObserver:observer];
}

- (NSArray *)allQueueNames
{
    return self.queues.allKeys;
}

- (NSInteger)numberOfOperationsInQueueNamed:(NSString *)queueName
{
    GDorisLoaderQueue * queue = [self fetchQueueWithNamed:queueName];
    if (!queue) {
        return 0;
    }
    return [queue operationCount];
}

- (BOOL)hasQueues
{
    return self.queues.count > 0;
}
@end
