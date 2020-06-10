//
//  GDorisMark.h
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol GDorisMark <NSObject>

@property (nonatomic,strong) UIColor *fillColor;
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) CGPoint lastLocation;

@property (nonatomic,assign,readonly) CGPoint startLocation;
@property (nonatomic,strong,readonly) UIBezierPath * bezierPath;
@property (nonatomic,strong,readonly) NSString * MarkID;
@property (nonatomic,strong,readonly) CAShapeLayer * shapeLayer;

- (void)buildBezierPathWithLocation:(CGPoint)location;
- (void)drawShapeLayer;

@end


