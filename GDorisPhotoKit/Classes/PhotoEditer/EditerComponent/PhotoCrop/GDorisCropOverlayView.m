//
//  GDorisCropOverlayView.m
//  GDoris
//
//  Created by GIKI on 2018/9/5.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisCropOverlayView.h"

static const CGFloat kCropOverLayerCornerWidth = 20.0f;

@interface GDorisCropOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;
@property (nonatomic, strong) NSArray *outerLineViews;   //top, right, bottom, left
@property (nonatomic, strong) NSArray *topLeftLineViews; //vertical, horizontal
@property (nonatomic, strong) NSArray *bottomLeftLineViews;
@property (nonatomic, strong) NSArray *bottomRightLineViews;
@property (nonatomic, strong) NSArray *topRightLineViews;

@end

@implementation GDorisCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        self.displayHorizontalGridLines = YES;
        self.displayVerticalGridLines = YES;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.outerLineViews) {
        [self layoutLines];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.outerLineViews) {
        [self layoutLines];
    }
}

- (void)layoutLines
{
    CGSize boundsSize = self.bounds.size;
    
    //border lines
    for (NSInteger i = 0; i < 4; i++) {
        UIView *lineView = self.outerLineViews[i];
        
        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = (CGRect){0,-1.0f,boundsSize.width+2.0f, 1.0f}; break; //top
            case 1: frame = (CGRect){boundsSize.width,0.0f,1.0f,boundsSize.height}; break; //right
            case 2: frame = (CGRect){-1.0f,boundsSize.height,boundsSize.width+2.0f,1.0f}; break; //bottom
            case 3: frame = (CGRect){-1.0f,0,1.0f,boundsSize.height+1.0f}; break; //left
        }
        
        lineView.frame = frame;
    }
    
    //corner liness
    NSArray *cornerLines = @[self.topLeftLineViews, self.topRightLineViews, self.bottomRightLineViews, self.bottomLeftLineViews];
    for (NSInteger i = 0; i < 4; i++) {
        NSArray *cornerLine = cornerLines[i];
        
        CGRect verticalFrame = CGRectZero, horizontalFrame = CGRectZero;
        switch (i) {
            case 0: //top left
                verticalFrame = (CGRect){-3.0f,-3.0f,3.0f,kCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){0,-3.0f,kCropOverLayerCornerWidth,3.0f};
                break;
            case 1: //top right
                verticalFrame = (CGRect){boundsSize.width,-3.0f,3.0f,kCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-kCropOverLayerCornerWidth,-3.0f,kCropOverLayerCornerWidth,3.0f};
                break;
            case 2: //bottom right
                verticalFrame = (CGRect){boundsSize.width,boundsSize.height-kCropOverLayerCornerWidth,3.0f,kCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-kCropOverLayerCornerWidth,boundsSize.height,kCropOverLayerCornerWidth,3.0f};
                break;
            case 3: //bottom left
                verticalFrame = (CGRect){-3.0f,boundsSize.height-kCropOverLayerCornerWidth,3.0f,kCropOverLayerCornerWidth};
                horizontalFrame = (CGRect){-3.0f,boundsSize.height,kCropOverLayerCornerWidth+3.0f,3.0f};
                break;
        }
        
        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }
    
    //grid lines - horizontal
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    //grid lines - vertical
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated
{
    _gridHidden = hidden;
    
    if (animated == NO) {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        return;
    }
    [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
        for (UIView *lineView in self.horizontalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
        
        for (UIView *lineView in self.verticalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
    }];
}

#pragma mark - Property methods

- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines {
    _displayHorizontalGridLines = displayHorizontalGridLines;
    
    [self.horizontalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayHorizontalGridLines) {
        self.horizontalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.horizontalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines {
    _displayVerticalGridLines = displayVerticalGridLines;
    
    [self.verticalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayVerticalGridLines) {
        self.verticalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.verticalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [self setGridHidden:gridHidden animated:NO];
}

#pragma mark - lazy Load Method

- (NSArray *)outerLineViews
{
    if (!_outerLineViews) {
        _outerLineViews = @[
                            [self createNewLineView],
                            [self createNewLineView],
                            [self createNewLineView],
                            [self createNewLineView]
                            ];
    }
    return _outerLineViews;
}

- (NSArray *)topLeftLineViews
{
    if (!_topLeftLineViews) {
        _topLeftLineViews = @[
                              [self createNewLineView],
                              [self createNewLineView]
                              ];
    }
    return _topLeftLineViews;
}

- (NSArray *)bottomLeftLineViews
{
    if (!_bottomLeftLineViews) {
        _bottomLeftLineViews = @[
                                 [self createNewLineView],
                                 [self createNewLineView]
                                 ];
    }
    return _bottomLeftLineViews;
}

- (NSArray *)topRightLineViews
{
    if (!_topRightLineViews) {
        _topRightLineViews = @[
                               [self createNewLineView],
                               [self createNewLineView]
                               ];
    }
    return _topRightLineViews;
}

- (NSArray *)bottomRightLineViews
{
    if (!_bottomRightLineViews) {
        _bottomRightLineViews = @[
                                  [self createNewLineView],
                                  [self createNewLineView]
                                  ];
    }
    return _bottomRightLineViews;
}

#pragma mark - Private methods

- (nonnull UIView *)createNewLineView {
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    newLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:newLine];
    return newLine;
}


@end
