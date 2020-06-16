//
//  CDOperation.m
//  Conductor
//
//  Created by Andrew Smith on 10/21/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "CDOperation.h"
#import "ConductorInner.h"
#import <UIKit/UIApplication.h>
#import <mach/mach_time.h>

@interface CDOperation ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;
@end

@implementation CDOperation

- (void)dealloc
{
    _delegate = nil;
    
    if (self.backgroundTaskID) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
        self.backgroundTaskID = UIBackgroundTaskInvalid;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        //
        // This is simply a unique string added to the operation. Defaults to this in case none is
        // provided by the user.
        //
        uint64_t absolute_time = mach_absolute_time();
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        uint64_t nanoseconds = (double)absolute_time * (double)timebase.numer / (double)timebase.denom;
                
        self.identifier = [NSString stringWithFormat:@"%@_%llu", NSStringFromClass([self class]), nanoseconds];
    }
    return self;
}

- (id)initWithIdentifier:(id)identifier
{
    self = [self init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}

+ (id)operationWithIdentifier:(id)identifier
{
    return [[self alloc] initWithIdentifier:identifier];
}

#pragma mark - API

- (void)work
{
    // Subclass does stuff here
}

- (void)cleanup
{
    // Subclass does stuff here
}

#pragma mark - 

- (void)main
{
    @autoreleasepool {
        //
        // Respect the cancel
        //
        if (self.isCancelled) {
            [self finish];
            return;
        }
        
        //
        // Do your work here
        //
        [self work];
        
        //
        // Cleanup
        //
        [self finish];
    }
}

- (void)cancel
{
    [super cancel];
    
    /**
     Respond to a cancel command by finishing up the operation
     */
    [self finish];
}

- (void)finish
{
    [self cleanup];
    [self.delegate operationDidFinish:self];
}

#pragma mark - Background Tasks

- (void)beginBackgroundTask
{
    UIApplication *application = [UIApplication sharedApplication];
    
    /**
     This handler will be called before the allowed background task time runs out.
     */
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
