//
//  GDorisEditerHitTestView.m
//  GDoris
//
//  Created by GIKI on 2018/10/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisEditerHitTestView.h"

@implementation GDorisEditerHitTestView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event] == NO) return nil;
    
    NSInteger count = self.subviews.count;
    UIView *fitView = nil;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView *childView = self.subviews[i];
        CGPoint childP = [self convertPoint:point toView:childView];
        fitView = [childView hitTest:childP withEvent:event];
        if (fitView) {
            break;
        }
    }
    if (fitView) {
        return fitView;
    }
    return nil;
}
@end
