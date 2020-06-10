//
//  GDorisSticker.m
//  XCChat
//
//  Created by GIKI on 2020/1/19.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisSticker.h"
#import "GDorisDrawing.h"

@interface GDorisSticker ()
@property (nonatomic, assign) NSInteger  currentIndex;
@property (nonatomic, assign) CGFloat  itemSpace;
@property (nonatomic, assign) BOOL  beginDraw;
@property (nonatomic, strong) NSMutableArray * itemRects;
@end

@implementation GDorisSticker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemRects = [NSMutableArray array];
        self.strokeColor = [UIColor clearColor];
        self.lineWidth = 20;
        self.itemSpace = 0;
        self.beginDraw = YES;
    }
    return self;
}

- (void)buildBezierPathWithLocation:(CGPoint)location
{
    CGPoint lastLocation = self.lastLocation;
    CGFloat distance = GDorisBetweenPointsDistance(lastLocation, location);
    CGFloat width = self.lineWidth;
    
    /// Critical condition
    if (self.beginDraw || distance>=(width+self.itemSpace)) {
        CGRect rect = CGRectMake(location.x-width*0.5, location.y-width*0.5, width, width);
        self.lastLocation = location;
        @synchronized (self.itemRects) {
            [self.itemRects addObject:NSStringFromCGRect(rect)];
        }
        self.beginDraw = NO;
    }
}


- (void)drawShapeLayer
{
    [super drawShapeLayer];
    @synchronized (self.itemRects) {
        NSArray * itemRects = self.itemRects.copy;
        [self.itemRects removeAllObjects];
        [itemRects enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = CGRectFromString(obj);
            [self drawStickerWithRect:rect];
        }];
    }
}

- (void)drawStickerWithRect:(CGRect)rect
{
    
    UIImage * image = [self fetchStickerImage];
    if (!image) return;
    CALayer *stickerLayer = [CALayer layer];
    stickerLayer.frame = rect;
    stickerLayer.contentsScale = [UIScreen mainScreen].scale;
    stickerLayer.contentsGravity = kCAGravityResizeAspect;
    stickerLayer.contents = (__bridge id _Nullable)(image.CGImage);
    [self.shapeLayer addSublayer:stickerLayer];
}

- (CGSize)fetchStickerSize:(UIImage *)image
{
    return image.size;
}

- (UIImage *)fetchStickerImage
{
    if (self.stickers.count == 1) {
        return self.stickers.firstObject;
    } else {
        if (self.currentIndex >= self.stickers.count) {
            self.currentIndex = 0;
        }
        return [self.stickers objectAtIndex:self.currentIndex];
    }
}
@end
