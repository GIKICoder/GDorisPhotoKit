//
//  GDorisEditerCropController.h
//  XCChat
//
//  Created by GIKI on 2019/12/24.
//  Copyright © 2019 xiaochuankeji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisEditerCropController : UIViewController

- (instancetype)initWithImage:(UIImage *)image;

@property(nonatomic, copy) void (^doirsEditerCropImageAction)(UIImage * cropImage);
@end

NS_ASSUME_NONNULL_END
