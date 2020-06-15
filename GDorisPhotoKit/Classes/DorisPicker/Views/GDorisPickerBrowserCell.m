//
//  GDorisPickerBrowserCell.m
//  GDoris
//
//  Created by GIKI on 2020/3/26.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPickerBrowserCell.h"
#import "YYImage.h"
#import "GDorisPhotoBrowserBaseController.h"
@interface GDorisPickerBrowserCell ()
@property (nonatomic, strong) YYAnimatedImageView * containerView;
@end

@implementation GDorisPickerBrowserCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.containerView = [[YYAnimatedImageView alloc] init];
        self.containerView.userInteractionEnabled = YES;
        [self.scrollView addSubview:self.containerView];
    }
    return self;
}

- (UIView *)doris_containerView
{
    return self.containerView;
}

#pragma mark - public method

- (void)configurePhotoController:(GDorisPhotoBrowserBaseController *)controller
{
    [super configurePhotoController:controller];
    self.controller = controller;
}

- (void)configureWithObject:(id)object withIndex:(NSInteger)index
{
    [super configureWithObject:object withIndex:index];
    id<IGDorisBrowerLoader> loader = self.controller.browerLoader;
    [loader loadPhotoData:object cell:self imageView:self.containerView completion:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
        
    }];
}

@end
