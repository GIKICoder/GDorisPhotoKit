//
//  GDorisCanvasView.h
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisMark.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DorisCanvasMaskType) {
    DorisCanvasMaskLine,
    DorisCanvasMaskCurve,
    DorisCanvasMaskOval,
    DorisCanvasMaskRect,
    DorisCanvasMaskArrow,
    DorisCanvasMaskMosaic,
};

typedef NS_ENUM(NSUInteger, DorisCanvasDrawState) {
    DorisCanvasDrawStateBegin,
    DorisCanvasDrawStateEnd,
    DorisCanvasDrawStateMove,
    DorisCanvasDrawStateCancel,
    DorisCanvasDrawStateClick,
};

@class GDorisCanvasView;
@protocol GDorisCanvasViewDatasource <NSObject>
@optional
- (id<GDorisMark>)generateCanvasMark:(GDorisCanvasView *)canvasView;
@end

@protocol GDorisCanvasViewDelegate <NSObject>
@optional
- (void)dorisCanvasView:(GDorisCanvasView *)canvasView drawActionState:(DorisCanvasDrawState)state;
@end

@interface GDorisCanvasView : UIView

@property (nonatomic, strong) UIColor * paintColor;
@property (nonatomic, assign) CGFloat  lineWidth;
@property (nonatomic, weak, nullable) id <GDorisCanvasViewDatasource> dataSource;
@property (nonatomic, weak, nullable) id <GDorisCanvasViewDelegate>   delegate;
@property (nonatomic, assign) DorisCanvasMaskType  maskType;

- (instancetype)initWithImage:(UIImage*)image;

- (void)revokeLastMask;
- (void)resetAllMask;
- (BOOL)canRevoke;

@end

NS_ASSUME_NONNULL_END
