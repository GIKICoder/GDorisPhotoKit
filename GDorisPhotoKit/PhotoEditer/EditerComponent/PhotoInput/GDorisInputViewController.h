//
//  GDorisInputViewController.h
//  GDoris
//
//  Created by GIKI on 2018/9/15.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYText.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisInputViewController : UIViewController

@property(nonatomic, copy) void (^generateTextLabelAction)(YYLabel * label);
@property(nonatomic, copy) void (^generateTextLayoutAction)(YYTextLayout * textLayout);

@end

NS_ASSUME_NONNULL_END
