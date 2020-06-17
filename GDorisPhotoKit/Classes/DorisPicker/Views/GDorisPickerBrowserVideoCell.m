//
//  GDorisPickerBrowserVideoCell.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/4/8.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "GDorisPickerBrowserVideoCell.h"
#import <AVFoundation/AVFoundation.h>
#import "GDorisPhotoBrowserBaseController.h"
#import "UIImage+GDoris.h"
@interface GDorisPickerBrowserVideoCell ()
@property (nonatomic, strong) UIImageView * playView;
@property (nonatomic, assign) CGSize  ic_size;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak  ) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL waitForReadyToPlay;
@end

@implementation GDorisPickerBrowserVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.zoomEnabled = NO;
    }
    return self;
}

- (UIImageView *)playView
{
    if (!_playView) {
        _playView = [[UIImageView alloc] init];
        UIImage * image = [UIImage g_imageNamed:@"GDoris_photo_browser_video_play"];
        _playView.image = image;
        self.ic_size = image.size;
        [self.containerView addSubview:_playView];
    }
    {
        CGFloat left = (self.containerView.frame.size.width-self.ic_size.width)*0.5;
        CGFloat top = (self.containerView.frame.size.height-self.ic_size.height)*0.5;
        CGFloat width = self.ic_size.width;
        CGFloat height = self.ic_size.height;
        _playView.frame = CGRectMake(left, top, width, height);
    }
    return _playView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_playView && _playView.superview) {
        CGFloat left = (self.containerView.frame.size.width-self.ic_size.width)*0.5;
        CGFloat top = (self.containerView.frame.size.height-self.ic_size.height)*0.5;
        CGFloat width = self.ic_size.width;
        CGFloat height = self.ic_size.height;
        _playView.frame = CGRectMake(left, top, width, height);
    }
}

- (void)dealloc
{
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureWithObject:(id)object withIndex:(NSInteger)index
{
    [super configureWithObject:object withIndex:index];
    
    [self resetPlayerStatus];
    
    [self loadPlayerItemWithObject:object];
}

- (void)configureDidEndDisplayWithObject:(id)object withIndex:(NSInteger)index
{
    [self resetPlayerStatus];
}

- (void)loadPlayerItemWithObject:(id)object
{
    [self showPlayView];
    id<IGDorisBrowerLoader> loader = self.controller.browerLoader;
    if ([loader respondsToSelector:@selector(loadVideoItem:completion:)]) {
        [loader loadVideoItem:object completion:^(AVPlayerItem * _Nonnull item, NSError * _Nonnull error) {
            [self configureWithAvplayerItem:item];
        }];
    }
}

- (void)configureWithAvplayerItem:(AVPlayerItem *)playerItem
{
    if (_player) {
        [_player pause];
        [_player.currentItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:NULL];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = self.containerView.bounds;
    [self.containerView.layer addSublayer:playerLayer];
    [_playerLayer removeFromSuperlayer];
    _playerLayer = playerLayer;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self showPlayView];
}

- (void)resetPlayerStatus
{
    _waitForReadyToPlay = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    if (_playerLayer.superlayer)  [_playerLayer removeFromSuperlayer];
    _playerLayer.player = nil;
    _playerLayer = nil;
    _player = nil;
}

- (void)__didPlayToEndTimeNotification:(NSNotification *)notification
{
    [self pausePlayer];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    
    if (_player.rate == 0.0) {
        [self play];
    } else {
        [self pausePlayer];
    }
}

- (void)pausePlayer
{
    [self pause];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    switch (status)
    {
        case AVPlayerItemStatusReadyToPlay:
        {
            if (_waitForReadyToPlay) {
                [self play];
            }
        }
            break;
        case AVPlayerItemStatusFailed:
            NSLog(@"error play video");
            break;
        default:
            break;
    }
}

- (void)play
{
    if (_player.rate == 0.0f) { /** 暂停状态 */
        if (_player.currentItem.status == AVPlayerStatusReadyToPlay) {
            CMTime currentTime = _player.currentItem.currentTime;
            CMTime durationTime = _player.currentItem.duration;
            if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
            [_player play];
        } else {
            _waitForReadyToPlay = YES;
        }
    }
    [self hiddenPlayView];
}

- (void)pause
{
    [_player pause];
    [self showPlayView];
}

- (void)showPlayView
{
    if (_playView && _playView.superview) {
        [self.playView removeFromSuperview];
        _playView = nil;
    }
    self.playView.hidden = NO;
}

- (void)hiddenPlayView
{
    if (_playView && _playView.superview) {
        [self.playView removeFromSuperview];
        _playView = nil;
    }
}
@end
