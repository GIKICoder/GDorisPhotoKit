//
//  GDorisDrawing.h
//  XCChat
//
//  Created by GIKI on 2020/1/19.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "GDorisCanvasView.h"

#import "GDorisSticker.h"
#import "GDorisLine.h"


#define GDorisRadiansToDegrees(x) (180.0 * x / M_PI)
OBJC_EXTERN bool GDorisPointIsNull(CGPoint point);
OBJC_EXTERN CGPoint GDorisMidPoint(CGPoint first, CGPoint second);
OBJC_EXTERN CGFloat GDorisBetweenPointsAngle(CGPoint first, CGPoint second);
OBJC_EXTERN CGFloat GDorisBetweenPointsDistance(CGPoint first, CGPoint second);

@interface GDorisDrawing : NSObject

@end

