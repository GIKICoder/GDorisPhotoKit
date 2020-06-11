//
//  GDorisPhotoEditerController.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/12/23.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GDorisPhotoEditerController;
@protocol GDorisPhotoEditerControllerDelegate <NSObject>
@optional
- (void)photoEditer:(GDorisPhotoEditerController *)editer editerImage:(nullable UIImage *)editerImage originImage:(nullable UIImage *)originImage;
@end

@interface GDorisPhotoEditerController : UIViewController

+ (instancetype)photoEditerWithImage:(UIImage *)image;

@property (nonatomic, weak  ) id<GDorisPhotoEditerControllerDelegate>   delegate;
@property (nonatomic, weak  ) id   userInfo;
@end

NS_ASSUME_NONNULL_END
