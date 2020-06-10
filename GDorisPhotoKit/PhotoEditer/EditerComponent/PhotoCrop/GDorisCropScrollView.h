//
//  GDorisCropScrollView.h
//  GDoris
//
//  Created by GIKI on 2018/9/6.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisCropScrollView : UIScrollView
@property (nullable, nonatomic, copy) void (^touchesBegan)(void);
@property (nullable, nonatomic, copy) void (^touchesCancelled)(void);
@property (nullable, nonatomic, copy) void (^touchesEnded)(void);
@end

NS_ASSUME_NONNULL_END
