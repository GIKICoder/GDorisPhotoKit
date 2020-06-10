//
//  GDorisCanvasView.m
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisCanvasView.h"
#import "GDorisCanvasLayerView.h"
#import "GDorisMark.h"
#import "GDorisLine.h"
#import "UIImage+GDorisDraw.h"
@interface GDorisCanvasView ()
@property (nonatomic, strong) GDorisCanvasLayerView * layerView;
@property (nonatomic, strong) NSMutableArray<id<GDorisMark>> * drawMarks;
@property (nonatomic, strong) NSMutableArray<id<GDorisMark>> * drawUndoMarks;
@property (nonatomic, assign) NSTimeInterval  timeInterval;
@property (nonatomic, assign) BOOL  hasDraw;
@property (nonatomic, strong) Class  clazz;
@property (nonatomic, strong) UIImage * originImage;
@end

@implementation GDorisCanvasView

#pragma mark - init Method

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithImage:(UIImage*)image
{
    if (self = [super initWithFrame:CGRectZero]) {
        self.originImage = image;
        [self addSubview:({
            _layerView = [[GDorisCanvasLayerView alloc] init];
            _layerView;
        })];
        self.drawMarks = [NSMutableArray array];
        self.maskType = DorisCanvasMaskMosaic;
        self.paintColor = UIColor.whiteColor;
        self.lineWidth = 16;
        UIImage * image = [self.originImage mosaicLevel:5 size:CGSizeMake(200, 200)];
        self.paintColor = [UIColor colorWithPatternImage:image];
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:({
            _layerView = [[GDorisCanvasLayerView alloc] init];
            _layerView;
        })];
        self.drawMarks = [NSMutableArray array];
        self.maskType = DorisCanvasMaskCurve;
        self.paintColor = UIColor.whiteColor;
        self.lineWidth = 6;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layerView.frame = self.bounds;
}

- (id<GDorisMark>)generateCanvasMark
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(generateCanvasMark:)]) {
        id<GDorisMark> Mark = [self.dataSource generateCanvasMark:self];
        return Mark;
    }
    return [self generateDefaultCanvasMark];
}

- (id<GDorisMark>)generateDefaultCanvasMark
{
    id<GDorisMark> mark = (id)[self.clazz new];
    mark.fillColor = self.paintColor;
    mark.strokeColor = self.paintColor;
    mark.lineWidth = self.lineWidth;
    return mark;
}

- (void)invokeDelegateWithState:(DorisCanvasDrawState)state
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisCanvasView:drawActionState:)]) {
        [self.delegate dorisCanvasView:self drawActionState:state];
    }
}

#pragma mark - Touches Method

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self invokeDelegateWithState:DorisCanvasDrawStateBegin];
    self.hasDraw = NO;
    self.timeInterval = [[NSDate date] timeIntervalSince1970];
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    id<GDorisMark> mark = [self generateCanvasMark];
    [mark buildBezierPathWithLocation:currentPoint];
    [self.layerView drawLayerWithMark:mark];
    [self.drawMarks addObject:mark];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    id<GDorisMark> mark = (id)[self.drawMarks lastObject];
    [mark buildBezierPathWithLocation:currentPoint];
    [self.layerView drawLayerWithMark:mark];
    self.hasDraw = YES;
    [self invokeDelegateWithState:DorisCanvasDrawStateMove];
    /*
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    if (interval - self.timeInterval > 0.0) {
        [self.layerView drawLayerWithMark:mark];
        self.hasDraw = YES;
        [self invokeDelegateWithState:DorisCanvasDrawStateMove];
    }
     */
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.hasDraw) {
        //        [self.drawMarks removeLastObject];
    } else {
        id<GDorisMark> mark = (id)[self.drawMarks lastObject];
        [self.layerView drawEndWithMark:mark];
        [self invokeDelegateWithState:DorisCanvasDrawStateEnd];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.hasDraw) {
        //        [self.drawMarks removeLastObject];
    } else {
        [self invokeDelegateWithState:DorisCanvasDrawStateCancel];
    }
}

- (void)revokeLastMask
{
    id<GDorisMark> mark  = [self.drawMarks lastObject];
    [self.layerView revokeMask:mark];
    [self.drawMarks removeLastObject];
}

- (void)resetAllMask
{
    [self.drawMarks enumerateObjectsUsingBlock:^(id<GDorisMark>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.shapeLayer) {
            [obj.shapeLayer removeFromSuperlayer];
        }
    }];
    [self.drawMarks removeLastObject];
}

- (BOOL)canRevoke
{
    return self.drawMarks.count > 0;
}

- (void)setPaintColor:(UIColor *)paintColor
{
    _paintColor = paintColor;
}

- (void)setMaskType:(DorisCanvasMaskType)maskType
{
    _maskType = maskType;
    switch (maskType) {
        case DorisCanvasMaskLine:
            self.clazz = [GDorisLine class];
            break;
        case DorisCanvasMaskCurve:
            self.clazz = [GDorisCurve class];
            break;
        case DorisCanvasMaskRect:
            self.clazz = [GDorisRect class];
            break;
        case DorisCanvasMaskOval:
            self.clazz = [GDorisOval class];
            break;
        case DorisCanvasMaskArrow:
            self.clazz = [GDorisLineArrow class];
            break;
            
        case DorisCanvasMaskMosaic:
        {
            self.clazz = [GDorisMosaic class];
        }
            break;
        default:
            break;
    }
}

@end
