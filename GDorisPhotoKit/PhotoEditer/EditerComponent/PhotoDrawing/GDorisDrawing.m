//
//  GDorisDrawing.m
//  XCChat
//
//  Created by GIKI on 2020/1/19.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisDrawing.h"


bool GDorisPointIsNull(CGPoint point)
{
    return isinf(point.x) || isinf(point.y);
}

CGPoint GDorisMidPoint(CGPoint first, CGPoint second) {
    if (GDorisPointIsNull(first) || GDorisPointIsNull(second)) {
        return CGPointZero;
    }
    return (CGPoint) {
        (first.x + second.x) / 2.0,
        (first.y + second.y) / 2.0
    };
}


CGFloat GDorisBetweenPointsAngle(CGPoint first, CGPoint second)
{
    if (GDorisPointIsNull(first) || GDorisPointIsNull(second)) {
        return 0;
    }
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    return GDorisRadiansToDegrees(rads);
}

CGFloat GDorisBetweenPointsDistance(CGPoint first, CGPoint second) {
    if (GDorisPointIsNull(first) || GDorisPointIsNull(second)) {
          return 0;
    }
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
};


@implementation GDorisDrawing

@end
