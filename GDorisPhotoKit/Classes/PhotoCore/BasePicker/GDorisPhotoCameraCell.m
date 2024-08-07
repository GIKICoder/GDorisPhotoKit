//
//  GDorisPhotoCameraCell.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/3/29.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPhotoCameraCell.h"
#import "UIImage+GDoris.h"
@interface GDorisPhotoCameraCell ()
@property (nonatomic, strong) UIImageView * cameraView;
@end

@implementation GDorisPhotoCameraCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _cameraView = [UIImageView new];
            _cameraView.image = [UIImage g_imageNamed:@"GDoris_photo_picker_cell_camera_ic"];
            _cameraView;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.cameraView.frame = self.contentView.bounds;
}

@end
