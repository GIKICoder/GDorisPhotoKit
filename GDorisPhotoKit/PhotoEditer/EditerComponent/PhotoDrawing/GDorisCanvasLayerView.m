//
//  GDorisCanvasLayerView.m
//  GDoris
//
//  Created by GIKI on 2018/9/7.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisCanvasLayerView.h"
#import "UIImage+GDorisDraw.h"
#import "GDorisCanvasView.h"
#import "GDorisLine.h"
@interface GDorisCanvasLayerView ()

@end

@implementation GDorisCanvasLayerView

- (void)layoutSubviews
{
    [super layoutSubviews];

}

- (void)drawLayerWithMark:(id<GDorisMark>)mark
{
    if (mark.shapeLayer) {
        [mark drawShapeLayer];
        mark.shapeLayer.frame = self.bounds;
    } else {
        [mark drawShapeLayer];
        mark.shapeLayer.frame = self.bounds;
        [self.layer addSublayer:mark.shapeLayer];
    }
}

- (void)drawEndWithMark:(id<GDorisMark>)mark
{
    
}

- (void)revokeMask:(id<GDorisMark>)mark
{
    if (mark.shapeLayer) {
        [mark.shapeLayer removeFromSuperlayer];
    }
}
@end
