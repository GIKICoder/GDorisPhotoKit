//
//  GDorisPhotoPickerController.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/2.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerBaseController.h"
#import "IGDorisPhotoPickerDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoPickerController : GDorisPhotoPickerBaseController

@property (nonatomic, weak  ) id<IGDorisPhotoPickerDelegate>   delegate;

@end

NS_ASSUME_NONNULL_END
