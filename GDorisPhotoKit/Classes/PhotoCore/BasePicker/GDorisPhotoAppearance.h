//
//  GDorisPhotoAppearance.h
//  XCChat
//
//  Created by GIKI on 2020/3/22.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerBean.h"

NS_ASSUME_NONNULL_BEGIN

/// 相册展示内容的类型
typedef NS_ENUM(NSUInteger,  DorisAlbumContentType) {
     DorisAlbumContentTypeAll,                                  // 展示所有资源
     DorisAlbumContentTypeOnlyPhoto,                            // 只展示照片
     DorisAlbumContentTypeOnlyVideo,                            // 只展示视频
     DorisAlbumContentTypeOnlyAudio                             // 只展示音频
};

/// 相册展示内容的类型
typedef NS_ENUM(NSUInteger,  DorisPhotoRegularType) {
     DorisPhotoRegularTypeAll,                              // ALL
     DorisPhotoRegularTypePhoto,                            // 照片最大数量
     DorisPhotoRegularTypeVideo,                            // 视频最大数量
};

@interface GDorisPhotoAppearance : NSObject

/// 是否展示空相册 default：NO
@property (nonatomic, assign) BOOL  emptyAlbumEnabled;
 
/// 是否展示智能相册 default：YES
@property (nonatomic, assign) BOOL  samrtAlbumEnabled;

///  是否倒叙输出相册图片 default：NO
@property (nonatomic, assign) BOOL  isReveres;

///  是否支持手势选择
@property (nonatomic, assign) BOOL  gestureSelectEnabled;

///  是否在相册选择展示相机图标
@property (nonatomic, assign) BOOL  showCamera;

/// 是否支持3Dtouch预览 default：NO @available: iOS 9.0
@property (nonatomic, assign) BOOL  can3DTouchPreview;

///  是否开启图片选择框动画
@property (nonatomic, assign) BOOL  selectAnimated;

/// 是否开启图片选择框显示选择数字
@property (nonatomic, assign) BOOL  selectCountEnabled;

/// pickerphoto 间距
@property (nonatomic, assign) CGFloat  pickerPadding;

/// pickerphoto 边距
@property (nonatomic, assign) UIEdgeInsets edgeInset;

/// 列数 default: 4
@property (nonatomic, assign) NSInteger  pickerColumns;


+ (GDorisPhotoAppearance *)defaultAppearance;

@end


NS_ASSUME_NONNULL_END
