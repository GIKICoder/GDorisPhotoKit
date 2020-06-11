//
//  GDorisPhotoPickerBean.h
//  XCChat
//
//  Created by GIKI on 2020/3/25.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoPickerBean : NSObject
@property (nonatomic, strong) id asset;
@property (nonatomic, assign) BOOL  isCamera;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL  isSelected;
@property (nonatomic, assign) BOOL  selectDisabled;
@property (nonatomic, assign) NSInteger  selectIndex;
@property (nonatomic, assign) BOOL  animated;
@end

NS_ASSUME_NONNULL_END
