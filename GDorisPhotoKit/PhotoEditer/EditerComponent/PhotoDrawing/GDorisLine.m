//
//  GDorisLine.m
//  GDoris
//
//  Created by GIKI on 2018/9/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisLine.h"
#import "GDorisDrawing.h"

@interface GDorisVertex ()
@property (nonatomic,assign) CGPoint startLocation;
@property (nonatomic,strong) UIBezierPath * bezierPath;
@end

@implementation GDorisLine

- (void)drawShapeLayer
{
    [super drawShapeLayer];
    self.shapeLayer.contentsScale = [UIScreen mainScreen].scale;
}

- (void)buildBezierPathWithLocation:(CGPoint)location
{
    [super buildBezierPathWithLocation:location];
    [self.bezierPath removeAllPoints];
    [self.bezierPath moveToPoint:self.startLocation];
    [self.bezierPath addLineToPoint:location];
}

@end

@interface GDorisCurve ()

@end

@implementation GDorisCurve

- (void)buildBezierPathWithLocation:(CGPoint)location
{
    BOOL firstLoad = self.bezierPath ? NO : YES;
    [super buildBezierPathWithLocation:location];
    if (!firstLoad) {
        CGPoint midPoint = GDorisMidPoint(self.lastLocation, location);
        // 使用二次曲线方程式
        [self.bezierPath addQuadCurveToPoint:midPoint controlPoint:self.lastLocation];
    }
    self.lastLocation = location;
}

@end

@implementation GDorisOval


- (void)buildBezierPathWithLocation:(CGPoint)location
{
    [super buildBezierPathWithLocation:location];
    self.bezierPath = [UIBezierPath bezierPathWithOvalInRect:[self ovalRectWithLocation:location]];
}

- (CGRect)ovalRectWithLocation:(CGPoint)location
{
    CGPoint begin = self.startLocation;
    CGPoint end = location;
    CGFloat x = begin.x <= end.x ? begin.x: end.x;
    CGFloat y = begin.y <= end.y ? begin.y : end.y;
    CGFloat width = fabs(begin.x - end.x);
    CGFloat height = fabs(begin.y - end.y);
    return CGRectMake(x , y , width, height);
}

- (void)drawShapeLayer
{
    [super drawShapeLayer];
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
}

@end

@implementation GDorisRect

- (void)buildBezierPathWithLocation:(CGPoint)location
{
    [super buildBezierPathWithLocation:location];
    self.bezierPath = [UIBezierPath bezierPathWithRect:[self rectWithLocation:location]];
}

- (CGRect)rectWithLocation:(CGPoint)location
{
    CGPoint begin = self.startLocation;
    CGPoint end = location;
    CGFloat x = begin.x <= end.x ? begin.x: end.x;
    CGFloat y = begin.y <= end.y ? begin.y : end.y;
    CGFloat width = fabs(begin.x - end.x);
    CGFloat height = fabs(begin.y - end.y);
    return CGRectMake(x , y , width, height);
}

- (void)drawShapeLayer
{
    [super drawShapeLayer];
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
}
@end

@implementation GDorisLineArrow

- (void)buildBezierPathWithLocation:(CGPoint)location
{
    [super buildBezierPathWithLocation:location];
    [self.bezierPath removeAllPoints];
    [self.bezierPath moveToPoint:self.startLocation];
    [self.bezierPath addLineToPoint:location];
    [self.bezierPath appendPath:[self createArrowWithStartPoint:self.startLocation endPoint:location]];
}

- (UIBezierPath *)createArrowWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    CGPoint controllPoint = CGPointZero;
    CGPoint pointUp = CGPointZero;
    CGPoint pointDown = CGPointZero;
    CGFloat distance = [self distanceBetweenStartPoint:startPoint endPoint:endPoint];
    CGFloat distanceX = 8.0 * (ABS(endPoint.x - startPoint.x) / distance);
    CGFloat distanceY = 8.0 * (ABS(endPoint.y - startPoint.y) / distance);
    CGFloat distX = 4.0 * (ABS(endPoint.y - startPoint.y) / distance);
    CGFloat distY = 4.0 * (ABS(endPoint.x - startPoint.x) / distance);
    if (endPoint.x >= startPoint.x){
        if (endPoint.y >= startPoint.y) {
            controllPoint = CGPointMake(endPoint.x - distanceX, endPoint.y - distanceY);
            pointUp = CGPointMake(controllPoint.x + distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x - distX, controllPoint.y + distY);
        }else{
            controllPoint = CGPointMake(endPoint.x - distanceX, endPoint.y + distanceY);
            pointUp = CGPointMake(controllPoint.x - distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x + distX, controllPoint.y + distY);
        }
    }else{
        if (endPoint.y >= startPoint.y){
            controllPoint = CGPointMake(endPoint.x + distanceX, endPoint.y - distanceY);
            pointUp = CGPointMake(controllPoint.x - distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x + distX, controllPoint.y + distY);
        }else{
            controllPoint = CGPointMake(endPoint.x + distanceX, endPoint.y + distanceY);
            pointUp = CGPointMake(controllPoint.x + distX, controllPoint.y - distY);
            pointDown = CGPointMake(controllPoint.x - distX, controllPoint.y + distY);
        }
    }
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:endPoint];
    [arrowPath addLineToPoint:pointDown];
    [arrowPath addLineToPoint:pointUp];
    [arrowPath addLineToPoint:endPoint];
    return arrowPath;
}
- (CGFloat)distanceBetweenStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat xDist = (endPoint.x - startPoint.x);
    CGFloat yDist = (endPoint.y - startPoint.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}
@end

@implementation GDorisMosaic

- (void)buildBezierPathWithLocation:(CGPoint)location
{
    [super buildBezierPathWithLocation:location];
    
    [self.bezierPath addLineToPoint:location];
    [self.bezierPath moveToPoint:location];
}
@end
