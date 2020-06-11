//
//  GDorisPhotoAppearance.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/22.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoAppearance.h"
#import "GDorisPhotoHelper.h"
@implementation GDorisPhotoAppearance


+ (GDorisPhotoAppearance *)defaultAppearance
{
    static GDorisPhotoAppearance * appearance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appearance = [GDorisPhotoAppearance new];
    });
    return appearance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.emptyAlbumEnabled = NO;
        self.samrtAlbumEnabled = YES;
        self.isReveres = YES;
        self.selectAnimated = YES;
        self.selectCountEnabled = YES;
        self.pickerPadding = 4;
        self.pickerColumns = 4;
        self.edgeInset = UIEdgeInsetsMake(4, 4, 4, 4);
        self.selectAnimated = YES;
        self.selectCountEnabled = YES;
        self.showCamera = NO;
        self.gestureSelectEnabled = NO;
        self.can3DTouchPreview = YES;
        self.tintColor = GDorisColorCreate(@"FF5758");
    }
    return self;
}


@end
