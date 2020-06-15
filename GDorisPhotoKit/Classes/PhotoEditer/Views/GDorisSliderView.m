//
//  GDorisSliderView.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/4/13.
//  Copyright © 2019年 GIKI. All rights reserved.
//

#import "GDorisSliderView.h"

@interface XCCVideoSliderThumbView : UIImageView

@end
@implementation XCCVideoSliderThumbView

- (CGRect)newHitRect
{
    UIEdgeInsets edgeIntset = UIEdgeInsetsMake(15,15, 15, 15);
    return CGRectMake(self.bounds.origin.x - edgeIntset.left,
                      self.bounds.origin.y - edgeIntset.top,
                      self.bounds.size.width + edgeIntset.left + edgeIntset.right,
                      self.bounds.size.height + edgeIntset.top + edgeIntset.bottom);
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self newHitRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}

@end

@interface GDorisSliderView ()
@property (nonatomic, assign) BOOL  isPan;
@property (nonatomic, strong) UIView *minTrackView;
@property (nonatomic, strong) UIView *maxTrackView;
@property (nonatomic, strong) UIView *bufferTrackView;
@property (nonatomic, strong) XCCVideoSliderThumbView *currentThumbView;
@property (nonatomic, strong) NSMutableDictionary * events;

@end
@implementation GDorisSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self initDetault];
    [self addSubview:self.maxTrackView];
    [self addSubview:self.bufferTrackView];
    [self addSubview:self.minTrackView];
    [self addSubview:self.currentThumbView];
}

- (void)initDetault
{
    self.clipsToBounds = YES;
    _value = 0.0;
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _limitMinimumValue = 0.0;
    _limitMaximumValue = 1.0;
    _minimumTrackTintColor = [UIColor colorWithRed:47/255.0 green:122/255.0 blue:246/255.0 alpha:1];
    _maximumTrackTintColor = [UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1];
    _bufferTrackView.backgroundColor = [UIColor clearColor];
    _thumbTintColor = [UIColor whiteColor];
    _isTruckCornerRidus = YES;
    _isThumbCornerRidus = YES;
    _trackHeight = 3;
    _thumbTintSize = CGSizeMake(self.frame.size.height, self.frame.size.height);
}

- (void)setValue:(float)value
{
    _value = value;
    [self setNeedsLayout];
}

- (void)setBufferValue:(float)bufferValue
{
    _bufferValue = bufferValue;
    [self setNeedsLayout];
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor
{
    _minimumTrackTintColor = minimumTrackTintColor;
    self.minTrackView.backgroundColor = minimumTrackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor
{
    _maximumTrackTintColor = maximumTrackTintColor;
    self.maxTrackView.backgroundColor = maximumTrackTintColor;
}

- (void)setTrackBufferTintColor:(UIColor *)trackBufferTintColor
{
    _trackBufferTintColor = trackBufferTintColor;
    self.bufferTrackView.backgroundColor = trackBufferTintColor;
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor
{
    _thumbTintColor = thumbTintColor;
    self.currentThumbView.backgroundColor = thumbTintColor;
}

- (void)setThumbTintSize:(CGSize)thumbTintSize
{
    _thumbTintSize = thumbTintSize;
    [self setNeedsLayout];
}

- (UIView *)maxTrackView
{
    if (!_maxTrackView) {
        _maxTrackView = [[UIView alloc] initWithFrame:CGRectZero];
        _maxTrackView.backgroundColor = self.maximumTrackTintColor;
        _maxTrackView.userInteractionEnabled = NO;
    }
    return _maxTrackView;
}

- (UIView *)bufferTrackView
{
    if (!_bufferTrackView) {
        _bufferTrackView = [[UIView alloc] init];
        _bufferTrackView.backgroundColor = self.trackBufferTintColor;
        _bufferTrackView.userInteractionEnabled = NO;
    }
    return _bufferTrackView;
}

- (UIView *)minTrackView
{
    if (!_minTrackView) {
        _minTrackView = [[UIView alloc] initWithFrame:CGRectZero];
        _minTrackView.backgroundColor = self.minimumTrackTintColor;
        _minTrackView.userInteractionEnabled = NO;
    }
    return _minTrackView;
}

- (UIImageView *)currentThumbView
{
    if (!_currentThumbView) {
        _currentThumbView = [[XCCVideoSliderThumbView alloc] initWithFrame:CGRectZero];
        _currentThumbView.backgroundColor = self.thumbTintColor;
        _currentThumbView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(currentThumbViewPanAction:)];
        [_currentThumbView addGestureRecognizer:pan];
    }
    return _currentThumbView;
}

- (void)currentThumbViewPanAction:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(slider:forSliderEvents:)]) {
                [self.delegate slider:self forSliderEvents:XCCVideoSliderEventDidBegin];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            _isPan = YES;
            
            CGPoint a = [pan translationInView:self];
            pan.view.center = CGPointMake(pan.view.center.x+a.x, pan.view.center.y);
            [pan setTranslation:CGPointZero inView:self];
            
            if (self.limitMaximumValue == 0.0) {
                if (pan.view.center.x<=self.currentThumbView.frame.size.width/2) {
                    pan.view.center = CGPointMake(pan.view.frame.size.width/2, pan.view.center.y);
                } else if (pan.view.center.x >= self.frame.size.width-pan.view.frame.size.width/2) {
                    pan.view.center = CGPointMake(self.frame.size.width-pan.view.frame.size.width/2, pan.view.center.y);
                }
            }else{
                if (pan.view.center.x<=self.limitMinimumValue/self.maximumValue*(self.frame.size.width-pan.view.frame.size.width)+pan.view.frame.size.width/2) {
                    pan.view.center = CGPointMake(self.limitMinimumValue/self.maximumValue*(self.frame.size.width-pan.view.frame.size.width)+pan.view.frame.size.width/2, pan.view.center.y);
                } else if (pan.view.center.x >= self.limitMaximumValue/self.maximumValue*(self.frame.size.width-pan.view.frame.size.width)+pan.view.frame.size.width/2) {
                    pan.view.center = CGPointMake(self.limitMaximumValue/self.maximumValue*(self.frame.size.width-pan.view.frame.size.width)+pan.view.frame.size.width/2, pan.view.center.y);
                }
            }
            
            _value = (pan.view.center.x-pan.view.frame.size.width/2)/(self.frame.size.width-pan.view.frame.size.width)*self.maximumValue;
            
            CGRect rect = self.minTrackView.frame;
            rect.origin.x = 0;
            rect.size.width = pan.view.center.x;
            self.minTrackView.frame = rect;
            if (self.delegate && [self.delegate respondsToSelector:@selector(slider:forSliderEvents:)]) {
                [self.delegate slider:self forSliderEvents:XCCVideoSliderEventValueChanged];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _isPan = NO;
            _value = (pan.view.center.x-pan.view.frame.size.width/2)/(self.frame.size.width-pan.view.frame.size.width)*self.maximumValue;
            if (self.delegate && [self.delegate respondsToSelector:@selector(slider:forSliderEvents:)]) {
                [self.delegate slider:self forSliderEvents:XCCVideoSliderEventDidEnd];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isPan) return;
    
    if (self.limitMaximumValue != 0.0) {
        if (self.value == self.limitMinimumValue && self.value == self.limitMaximumValue) {
            NSLog(@"当前滑块无法滑动");
        } else if (!(self.minimumValue <= self.limitMinimumValue && self.limitMinimumValue <= self.value && self.value <= self.limitMaximumValue && self.limitMaximumValue <= self.maximumValue && self.limitMinimumValue != self.limitMaximumValue)) {
            NSLog(@"限制条件错误");
        }
    }
    
    self.maxTrackView.frame = CGRectMake(0, self.frame.size.height/2-self.trackHeight/2, self.frame.size.width, self.trackHeight);
    
    self.currentThumbView.frame = CGRectMake(0, 0, self.thumbTintSize.width, self.thumbTintSize.height);
    self.currentThumbView.center = CGPointMake(self.value/self.maximumValue*(self.frame.size.width-self.thumbTintSize.width)+self.thumbTintSize.width/2, self.frame.size.height/2);
    if (self.isThumbCornerRidus) {
        _currentThumbView.layer.cornerRadius = self.currentThumbView.frame.size.height/2;
    } else {
        _currentThumbView.layer.cornerRadius = 0;
    }
    
    self.minTrackView.frame = CGRectMake(0, self.maxTrackView.frame.origin.y, self.currentThumbView.center.x, self.maxTrackView.frame.size.height);
    
    self.bufferTrackView.frame = CGRectMake(0, self.maxTrackView.frame.origin.y, self.bufferValue/self.maximumValue*(self.frame.size.width-0)+0, self.maxTrackView.frame.size.height);
    
    if (self.isTruckCornerRidus) {
        self.minTrackView.layer.cornerRadius = self.minTrackView.frame.size.height/2;
        self.maxTrackView.layer.cornerRadius = self.maxTrackView.frame.size.height/2;
        self.bufferTrackView.layer.cornerRadius = self.maxTrackView.frame.size.height/2;
    }else{
        self.minTrackView.layer.cornerRadius = 0;
        self.maxTrackView.layer.cornerRadius = 0;
    }
}

@end
