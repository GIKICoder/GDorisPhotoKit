//
//  GDorisLoaderOperation.m
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/16.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisLoaderOperation.h"
#import <UIKit/UIApplication.h>
#import <mach/mach_time.h>

@interface GDorisLoaderOperation ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier  backgroundTaskID;
@end

@implementation GDorisLoaderOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithIdentifier:(id)identifier
{
    self = [self init];
    if (self) {
        if (identifier) {
            self.identifier = identifier;
        } else {
            [self defaultInit];
        }
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    if (self.backgroundTaskID) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
        self.backgroundTaskID = UIBackgroundTaskInvalid;
    }
}

- (void)defaultInit
{
    uint64_t absolute_time = mach_absolute_time();
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    uint64_t nanoseconds = (double)absolute_time * (double)timebase.numer / (double)timebase.denom;
    self.identifier = [NSString stringWithFormat:@"%@_%llu", NSStringFromClass([self class]), nanoseconds];
}

- (void)main
{
    @autoreleasepool {
        if (self.isCancelled) {
            [self finish];
            return;
        }
        [self work];
        
        [self finish];
    }
}

- (void)cancel
{
    [super cancel];
    [self finish];
}


#pragma mark - public Override

- (void)work
{}

- (void)cleanup
{}

- (void)finish
{
    [self cleanup];
    [self.delegate dorisOperationDidFinish:self];
}

- (void)beginBackgroundTask
{
    UIApplication *application = [UIApplication sharedApplication];

    self.backgroundTaskID = [application beginBackgroundTaskWithExpirationHandler:^{
        [self backgroundTaskExpirationCleanup];
        
        [self cancel];
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
        self.backgroundTaskID = UIBackgroundTaskInvalid;
    }];
}

- (void)backgroundTaskExpirationCleanup
{
    
}

@end
