//
//  GDorisScrollerPanGesutreRecognizer.h
//  GDoris
//
//  Created by GIKI on 2018/9/16.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisScrollerPanGesutreRecognizer : UIPanGestureRecognizer
@property (nonatomic, weak) UIScrollView *scrollview;
@end

NS_ASSUME_NONNULL_END
