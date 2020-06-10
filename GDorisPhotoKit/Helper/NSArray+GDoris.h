//
//  NSArray+GDoris.h
//  XCChat
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (GDoris)

- (id)g_objectAtIndexSafely:(NSUInteger)index;

@end

@interface NSMutableArray (GDoris)

- (void)g_addObjectSafely:(id)anObject;
- (void)g_insertObjectSafely:(id)anObject atIndex:(NSUInteger)index;
- (void)g_removeObjectAtIndexSafely:(NSUInteger)index;
- (void)g_replaceObjectAtIndexSafely:(NSUInteger)index withObject:(id)anObject;

@end

NS_ASSUME_NONNULL_END
