//
// GDorisEditerCropToolbar.h
//  GDoris
//
//  Created by GIKI on 2018/10/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DorisEditerCropToolbarType) {
    DorisEditerCropToolbarRotate = 1001,
    DorisEditerCropToolbarClose,
    DorisEditerCropToolbarReset,
    DorisEditerCropToolbarDone
};
@interface GDorisEditerCropToolbar : UIView

@property(nonatomic, copy) void (^dorisCropToolbarActionBlock)(DorisEditerCropToolbarType itemType);
@end

NS_ASSUME_NONNULL_END
