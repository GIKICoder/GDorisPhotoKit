//
//  GDorisTextStyleItem.h
//  XCChat
//
//  Created by GIKI on 2020/1/16.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYText.h"
NS_ASSUME_NONNULL_BEGIN
//@[@"横向",@"竖向",@"居左",@"居中",@"居右",@"拼音",@"粗体",@"阴影",@"描边"];
@interface GDorisTextStyleItem : NSObject
/// font default: 16
@property (nonatomic, strong) UIFont * font;
/// textColor default: whiteColor
@property (nonatomic, strong) UIColor * textColor;
/// backcolor defalut: clearColor
@property (nonatomic, strong) UIColor * backgroundColor;
/// 竖向排版 default: NO
@property (nonatomic, assign) BOOL verticalForm;
///  default: NSTextAlignmentLeft
@property (nonatomic, assign) NSTextAlignment  textAlignment;
/// 紧在verticalFrom==Yes情况下生效
@property (nonatomic, assign) YYTextVerticalAlignment verticalAlignment;

@property (nonatomic, assign) BOOL  pinyin;

@property (nonatomic, assign) BOOL  blodFont;

@property (nonatomic, assign) BOOL  textShadow;

@property (nonatomic, assign) BOOL  background;

@end

NS_ASSUME_NONNULL_END
