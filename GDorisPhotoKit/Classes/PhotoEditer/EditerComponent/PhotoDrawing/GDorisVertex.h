//
//  GDorisVertex.h
//  GDoris
//
//  Created by GIKI on 2018/9/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisMark.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisVertex : NSObject <GDorisMark>

@property (nonatomic,strong) UIColor *fillColor;
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) CGPoint lastLocation;

@property (nonatomic,strong,readonly) NSString * MarkID;
@property (nonatomic,assign,readonly) CGPoint startLocation;
@property (nonatomic,strong,readonly) UIBezierPath * bezierPath;
@property (nonatomic,strong,readonly) CAShapeLayer * shapeLayer;

@end


NS_ASSUME_NONNULL_END
