//
//  UIControl+GDoris.m
//  XCChat
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "UIControl+GDoris.h"
#import <objc/runtime.h>

static char KDorisHitEdgeIntsets;

@implementation UIControl (GDoris)

- (void)g_enlargeHitWithEdges:(UIEdgeInsets)edgeIntsets
{
    objc_setAssociatedObject(self, &KDorisHitEdgeIntsets, [NSValue valueWithUIEdgeInsets:edgeIntsets], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)g_newHitRect
{
    NSValue* edgeValue = objc_getAssociatedObject(self, &KDorisHitEdgeIntsets);
    
    if (edgeValue) {
        UIEdgeInsets edgeIntset = [edgeValue UIEdgeInsetsValue];
        return CGRectMake(self.bounds.origin.x - edgeIntset.left,
                          self.bounds.origin.y - edgeIntset.top,
                          self.bounds.size.width + edgeIntset.left + edgeIntset.right,
                          self.bounds.size.height + edgeIntset.top + edgeIntset.bottom);
    } else {
        return self.bounds;
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self g_newHitRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}
@end
