//
//  GDorisRunLoopWorker.m
//  XCChat
//
//  Created by GIKI on 2019/8/26.
//  Copyright © 2019 xiaochuankeji. All rights reserved.
//

#import "GDorisRunLoopWorker.h"
#import <objc/runtime.h>

@interface GDorisRunLoopWorker ()

@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) NSMutableArray *tasksKeys;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation GDorisRunLoopWorker

+ (instancetype)sharedInstance
{
    static GDorisRunLoopWorker * instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GDorisRunLoopWorker alloc] init];
        [[self class] registerRunLoopWorkAsMainRunLoopObserver:instance];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxQueueLength = 40;
        _tasks = [NSMutableArray array];
        _tasksKeys = [NSMutableArray array];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFiredMethod:) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - public Method

- (void)postTask:(GDorisRunLoopWorkerBlock)block withKey:(id)key
{
    if (block && key) {
        [self.tasks addObject:block];
        [self.tasksKeys addObject:key];
        if (self.tasks.count > self.maxQueueLength) {
            [self.tasks removeObjectAtIndex:0];
            [self.tasksKeys removeObjectAtIndex:0];
        }
    }
 
}

- (void)removeAllTasks
{
    [self.tasksKeys removeAllObjects];
    [self.tasks removeAllObjects];
}

#pragma mark - private Method

- (void)timerFiredMethod:(NSTimer *)timer
{
    
}

+ (void)registerRunLoopWorkAsMainRunLoopObserver:(GDorisRunLoopWorker*)loopWorker
{
    static CFRunLoopObserverRef defaultModeObserver;
    registerObserver(kCFRunLoopBeforeWaiting, defaultModeObserver, NSIntegerMax - 999, kCFRunLoopDefaultMode, (__bridge void *)loopWorker, &defaultModeRunLoopWorkDistributionCallback);
    
}

#pragma mark - runloop Register

static void registerObserver(CFOptionFlags activities, CFRunLoopObserverRef observer, CFIndex order, CFStringRef mode, void *info, CFRunLoopObserverCallBack callback) {
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,
        info,
        &CFRetain,
        &CFRelease,
        NULL
    };
    observer = CFRunLoopObserverCreate(NULL, activities, YES, order, callback, &context);
    
    CFRunLoopAddObserver(runLoop, observer, mode);
    CFRelease(observer);
    
}

static void runLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    GDorisRunLoopWorker *runLoopWorker = (__bridge GDorisRunLoopWorker *)info;
    if (runLoopWorker.tasks.count == 0) {
        return;
    }
    BOOL result = NO;
    while (result == NO && runLoopWorker.tasks.count) {
        GDorisRunLoopWorkerBlock Block  = runLoopWorker.tasks.firstObject;
        result = Block();
        [runLoopWorker.tasks removeObjectAtIndex:0];
        [runLoopWorker.tasksKeys removeObjectAtIndex:0];
    }
}

static void defaultModeRunLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    
    runLoopWorkDistributionCallback(observer, activity, info);
}

@end
