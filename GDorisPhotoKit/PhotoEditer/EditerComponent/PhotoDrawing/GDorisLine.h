//
//  GDorisLine.h
//  GDoris
//
//  Created by GIKI on 2018/9/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisVertex.h"

NS_ASSUME_NONNULL_BEGIN
/// 直线
@interface GDorisLine : GDorisVertex

@end
/// 曲线
@interface GDorisCurve : GDorisVertex

@end
/// 椭圆
@interface GDorisOval : GDorisVertex

@end
/// 矩形
@interface GDorisRect : GDorisVertex

@end
/// 箭头
@interface GDorisLineArrow : GDorisVertex

@end

/// 马赛克画笔
@interface GDorisMosaic : GDorisVertex

@end

NS_ASSUME_NONNULL_END
