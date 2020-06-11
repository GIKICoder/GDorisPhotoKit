//
//  GDorisScrollerPanGesutreRecognizer.m
//  GDoris
//
//  Created by GIKI on 2018/9/16.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisScrollerPanGesutreRecognizer.h"

@interface GDorisScrollerPanGesutreRecognizer ()
@property (nonatomic, strong) NSNumber *isFail;
@end

@implementation GDorisScrollerPanGesutreRecognizer

- (void)reset
{
    [super reset];
    self.isFail = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (!self.scrollview) {
        return;
    }
    if (self.scrollview.contentSize.height == self.scrollview.bounds.size.height) {
        return;
    }
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint velocity = [self velocityInView:self.view];
    CGPoint translationPoint = [self translationInView:self.view];
    if (self.isFail) {
        if (self.isFail.boolValue) {
            self.state = UIGestureRecognizerStateFailed;
        }
        return;
    }
    
    CGFloat topVerticalOffset = -self.scrollview.contentInset.top;///alawys value 0
    CGFloat height = self.scrollview.frame.size.height;  /// scrollviewHeight
    CGFloat contentYoffset = self.scrollview.contentOffset.y;
    /// If the long picture scrolls to the bottom,This value will be equal to the screen height
    CGFloat distanceFromBottom = self.scrollview.contentSize.height - contentYoffset;

    ///是否是竖直滚动
    BOOL isVerticalPosition = (fabs(velocity.x) <= fabs(velocity.y));
    ///是否向上滚动
    BOOL isUpScroller = (translationPoint.y <= 0);
    /// 在顶部 向下滚动
    if (isVerticalPosition && !isUpScroller && (self.scrollview.contentOffset.y <= topVerticalOffset)  ) {
         self.isFail = @NO;
    } else if (isVerticalPosition && isUpScroller && (fabs(distanceFromBottom-height) < 1 || distanceFromBottom < height)) { ///在底部向上滚动
         self.isFail = @NO;
    } else {
        self.state = UIGestureRecognizerStateFailed;
        self.isFail = @YES;
    }
}

//|| ((self.scrollview.contentSize.height <= self.scrollview.bounds.size.height) && (distanceFromBottom <= height))  else if (((self.scrollview.contentSize.height <= self.scrollview.bounds.size.height) && (distanceFromBottom <= height) && translationPoint.y < 0)) {
//self.isFail = @NO;
//}

/***
 CGPoint nowPoint = [touches.anyObject locationInView:self.view];
 CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];
 CGFloat contentsizeheight = self.scrollview.contentSize.height;
 NSLog(@"topVerticalOffset--%f",topVerticalOffset);
 NSLog(@"scrollviewheight--%f",height);
 NSLog(@"contentYoffset--%f",contentYoffset);
 NSLog(@"distanceFromBottom--%f",distanceFromBottom);
 NSLog(@"contentsizeheight--%f",contentsizeheight);
 */


@end
