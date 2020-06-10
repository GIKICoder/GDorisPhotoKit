//
//  NSArray+GDoris.m
//  XCChat
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "NSArray+GDoris.h"

@implementation NSArray (GDoris)

- (id)g_objectAtIndexSafely:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end


@implementation NSMutableArray (GDoris)

- (void)g_addObjectSafely:(id)anObject {
    if (anObject != nil) {
        [self addObject:anObject];
    }
}

- (void)g_insertObjectSafely:(id)anObject atIndex:(NSUInteger)index {
    if (anObject != nil && index < [self count]) {
        [self insertObject:anObject atIndex:index];
    } else {
        [self g_addObjectSafely:anObject];
    }
}

- (void)g_removeObjectAtIndexSafely:(NSUInteger)index {
    if (index < [self count]) {
        [self removeObjectAtIndex:index];
    }
}

- (void)g_replaceObjectAtIndexSafely:(NSUInteger)index withObject:(id)anObject {
    if (anObject != nil && index < [self count]) {
        [self replaceObjectAtIndex:index withObject:anObject];
    }
}

@end
