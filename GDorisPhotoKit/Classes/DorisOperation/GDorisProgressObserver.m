//
//  GDorisProgressObserver.m
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/17.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisProgressObserver.h"

@implementation GDorisProgressObserver

+ (GDorisProgressObserver *)progressObserverWithStartingOperationCount:(NSInteger)operationCount
                                                     progressBlock:(GDorisProgressObserverProgressBlock)progressBlock
                                                andCompletionBlock:(GDorisProgressObserverCompletionBlock)completionBlock
{
    GDorisProgressObserver *observer    = [self new];
    observer.startingOperationCount = operationCount;
    observer.progressBlock          = progressBlock;
    observer.completionBlock        = completionBlock;
    return observer;
}

- (void)runProgressBlockWithCurrentOperationCount:(NSNumber *)operationCount
{
    if (!self.progressBlock) return;
    
    NSAssert(!(self.startingOperationCount <= 0), @"Starting operation count was 0 or less than 0! Initialize the watcher with a operation count of larger than 0.");
    
    // Defensive
    if (self.startingOperationCount <= 0) return;
        
    // Calculate percentage progress
    CGFloat progress = (CGFloat)(self.startingOperationCount - [operationCount intValue]) / self.startingOperationCount;
    
    // If operation count is larger than starting operation count, mark progress
    // as 0.  This shouldn't happen, the starting operation count should be updated
    // as operations are added.
    if (progress < 0) progress = 0.0;
    
    self.progressBlock(progress);
}

- (void)runCompletionBlock
{
    if (self.completionBlock) self.completionBlock();
}

- (void)addToStartingOperationCount:(NSNumber *)numberToAdd
{
    self.startingOperationCount += [numberToAdd intValue];
}
@end
