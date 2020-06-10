//
//  GDorisVertex.m
//  GDoris
//
//  Created by GIKI on 2018/9/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisVertex.h"
#import <CommonCrypto/CommonDigest.h>
@interface GDorisVertex()
@property (nonatomic,assign) CGPoint startLocation;
@property (nonatomic,strong) UIBezierPath * bezierPath;
@property (nonatomic,strong) CAShapeLayer * shapeLayer;
@property (nonatomic,strong) NSString * MarkID;
@end

@implementation GDorisVertex

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.strokeColor = [UIColor blackColor];
        self.lineWidth = 2;
        NSString * markId = [NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]];
        self.MarkID = [self md5:markId];
    }
    return self;
}

- (void)buildBezierPathWithLocation:(CGPoint)location
{
    if (!self.bezierPath) {
        self.startLocation = location;
        self.bezierPath = [UIBezierPath new];
        [self.bezierPath moveToPoint:location];
    }
}

- (void)drawShapeLayer
{
    if (!self.shapeLayer) {
        self.shapeLayer = [[CAShapeLayer alloc] init];
        self.shapeLayer.lineJoin = kCALineJoinRound;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.strokeColor =   self.strokeColor.CGColor;
        if (self.fillColor) {
            self.shapeLayer.fillColor = self.fillColor.CGColor;
        } else {
            self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        }
        
        self.shapeLayer.lineWidth = self.lineWidth;
        self.shapeLayer.frame = [UIScreen mainScreen].bounds;
        self.shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    self.shapeLayer.path = self.bezierPath.CGPath;
}

- (NSString *)md5:(NSString*)string
{
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
#pragma clang diagnostic pop
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
