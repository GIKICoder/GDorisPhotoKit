//
//  GDorisLoaderOperation.h
//  GDorisLoaderController
//
//  Created by GIKI on 2020/6/16.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GDorisLoaderOperation;
@protocol GDorisLoaderOperationDelegate <NSObject>

@optional
- (void)dorisOperationDidFinish:(GDorisLoaderOperation *)operation;
- (void)dorisOperationHasCanceled:(GDorisLoaderOperation *)operation;

@end

@interface GDorisLoaderOperation : NSOperation

@property (nonatomic, weak  ) id<GDorisLoaderOperationDelegate>   delegate;
@property (nonatomic, strong) id identifier;

- (instancetype)initWithIdentifier:(id)identifier;

- (void)work;
- (void)cleanup;
- (void)finish;
- (void)beginBackgroundTask;
- (void)backgroundTaskExpirationCleanup;

@end

NS_ASSUME_NONNULL_END
