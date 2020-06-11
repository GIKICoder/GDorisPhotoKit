//
//  GDorisPhotoAppearance.m
//  XCChat
//
//  Created by GIKI on 2020/3/22.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoAppearance.h"

@implementation GDorisPhotoAppearance


+ (GDorisPhotoAppearance *)defaultAppearance
{
    GDorisPhotoAppearance * appearance = [GDorisPhotoAppearance new];
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
        self.showCamera = YES;
        self.gestureSelectEnabled = NO;
        self.can3DTouchPreview = YES;
    }
    return self;
}


@end
