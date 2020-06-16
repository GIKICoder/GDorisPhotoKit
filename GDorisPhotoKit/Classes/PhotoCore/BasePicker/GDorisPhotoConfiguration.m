//
//  GDorisPhotoConfiguration.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/22.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoConfiguration.h"
#import "GDorisPhotoLoader.h"
#import "GDorisAlbumLoader.h"

@implementation GDorisPhotoConfiguration

+ (instancetype)defaultConfiguration
{
    GDorisPhotoConfiguration * config = [GDorisPhotoConfiguration new];
    return config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appearance = [GDorisPhotoAppearance defaultAppearance];
        self.albumLoader = [GDorisAlbumLoader new];
        self.photoLoader = [GDorisPhotoLoader new];
        self.albumType = DorisAlbumContentTypeAll;
        self.firstNeedsLoadCount = 40;
        self.fetchPhotoMaxCount = 0;
        self.selectMaxCount = 8;
        self.onlySelectOneMediaType = YES;
        self.selectCountRegular = @{
            @(DorisPhotoRegularTypeAll) : @(8),
            @(DorisPhotoRegularTypePhoto) :@(8),
            @(DorisPhotoRegularTypeVideo) :@(1),
        };
        self.functionTitle = @"发送";
    }
    return self;
}

- (void)setSelectMaxCount:(NSInteger)selectMaxCount
{
    _selectMaxCount = selectMaxCount;
    self.selectCountRegular = @{
         @(DorisPhotoRegularTypeAll) : @(selectMaxCount),
    };
}
@end
