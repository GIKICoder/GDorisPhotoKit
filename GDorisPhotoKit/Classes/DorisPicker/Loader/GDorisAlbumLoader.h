//
//  GDorisAlbumLoader.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/25.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGDorisPhotoPicker.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisAlbumLoader : NSObject<IGDorisAlbumLoader>
@property (nonatomic, strong, readwrite) NSArray * albumDatas;
@property (nonatomic, strong, readwrite) NSArray * photoDatas;
@end

NS_ASSUME_NONNULL_END
