//
//  GDorisInputTextParse.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/12/25.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisInputTextParse.h"

@implementation GDorisInputTextParse

- (BOOL)parseText:(nullable NSMutableAttributedString *)text selectedRange:(nullable NSRangePointer)selectedRange
{
    if (self.textBackgroundColor) {
        YYTextBorder * border = [YYTextBorder borderWithFillColor:self.textBackgroundColor cornerRadius:3];
        text.yy_textBackgroundBorder = border;
        text.yy_color = UIColor.whiteColor;
        return YES;
    }
    return NO;
}
@end
