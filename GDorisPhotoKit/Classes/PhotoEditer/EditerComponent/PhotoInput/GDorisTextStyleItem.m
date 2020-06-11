//
//  GDorisTextStyleItem.m
//  XCChat
//
//  Created by GIKI on 2020/1/16.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisTextStyleItem.h"

@implementation GDorisTextStyleItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.font = [UIFont systemFontOfSize:26];
        self.textColor = UIColor.whiteColor;
        self.backgroundColor = UIColor.clearColor;
        self.verticalForm = NO;
        self.textAlignment = NSTextAlignmentLeft;
        self.verticalAlignment = YYTextVerticalAlignmentTop;
    }
    return self;
}


@end
