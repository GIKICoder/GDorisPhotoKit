//
//  GDorisProgressObserver.h
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/17.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GDorisProgressObserverProgressBlock)(CGFloat progress);
typedef void (^GDorisProgressObserverCompletionBlock)(void);

@interface GDorisProgressObserver : NSObject
@property (nonatomic, assign) NSInteger startingOperationCount;

@property (nonatomic, copy) GDorisProgressObserverProgressBlock progressBlock;

@property (nonatomic, copy) GDorisProgressObserverCompletionBlock completionBlock;

+ (GDorisProgressObserver *)progressObserverWithStartingOperationCount:(NSInteger)operationCount
                                                     progressBlock:(GDorisProgressObserverProgressBlock)progressBlock
                                                andCompletionBlock:(GDorisProgressObserverCompletionBlock)completionBlock;

/**
 Runs the observers progress block
 */
- (void)runProgressBlockWithCurrentOperationCount:(NSNumber *)operationCount;

/**
 Runs the observers completion block
 */
- (void)runCompletionBlock;

/**
 Adds to the starting operation count.  Say you start with 10 operations,
 then add 5 more, use this to add to the count so that progress can be properly
 adjusted and calculated.
 */
- (void)addToStartingOperationCount:(NSNumber *)numberToAdd;
@end

NS_ASSUME_NONNULL_END
