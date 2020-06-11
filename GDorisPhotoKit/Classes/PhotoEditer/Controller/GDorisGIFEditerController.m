//
//  GDorisGIFEditerController.m
//  XCChat
//
//  Created by GIKI on 2020/1/20.
//  Copyright © 2020 xiaochuankeji. All rights reserved.
//

#import "GDorisGIFEditerController.h"
#import "GDorisPhotoHelper.h"
#import "FLAnimatedImage.h"
#import "GDorisEditerHitTestView.h"
#import "XCNavigationBar.h"
#import "GDorisEditerToolbar.h"
#import "GDorisGIFCutView.h"
#import "GDorisGIFMetalData.h"
@interface GDorisGIFEditerController ()<UIScrollViewDelegate>
@property (nonatomic, strong) FLAnimatedImageView * imageView;
@property (nonatomic, strong) FLAnimatedImage * gifImage;
@property (nonatomic, strong) UIScrollView * scrollerContainer;
@property (nonatomic, strong) GDorisEditerHitTestView * operationArea;
@property (nonatomic, strong) XCNavigationBar * navigationBar;
@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;
@property (nonatomic, strong) GDorisEditerToolbar * toolBar;
@property (nonatomic, strong) GDorisGIFCutView * gifCutView;
@property (nonatomic, strong) GDorisGIFMetalData * metalData;
@end

@implementation GDorisGIFEditerController

- (instancetype)initWithImageData:(nullable NSData *)imageData
{
    self = [super init];
    if (self) {
        self.gifImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:imageData optimalFrameCacheSize:150 predrawingEnabled:YES];
        self.metalData = [[GDorisGIFMetalData alloc] initWithGifData:imageData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

- (void)setupUI
{
    [self.view addSubview:({
          _scrollerContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
          _scrollerContainer.delegate = self;
          _scrollerContainer.minimumZoomScale = 1;
          _scrollerContainer.maximumZoomScale = 2;
          _scrollerContainer;
      })];
      if (@available(iOS 11.0, *)) {
          _scrollerContainer.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
      } else {
          self.automaticallyAdjustsScrollViewInsets = NO;
      }
      [self.scrollerContainer addSubview:({
          _imageView = [FLAnimatedImageView new];
          _imageView.backgroundColor = [UIColor clearColor];
          _imageView.clipsToBounds = YES;
          _imageView.userInteractionEnabled = YES;
          _imageView;
      })];
      self.imageView.animatedImage = self.gifImage;
      [GDorisPhotoHelper fitImageSize:self.gifImage.size containerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
          self.scrollerContainer.contentSize = scrollContentSize;
          self.imageView.frame = containerFrame;
      }];
      [self.view addSubview:({
          _operationArea = [GDorisEditerHitTestView new];
          _operationArea.frame = self.view.bounds;
          _operationArea.userInteractionEnabled = NO;
          _operationArea.backgroundColor = [UIColor clearColor];
          _operationArea;
      })];
       [self loadMaskView];
        [self loadNavigationbar];
        [self loadToolbar];
        [self loadPanGesture];
    [self setupGIFCutView];
}

- (void)setupGIFCutView
{
    self.gifCutView = [[GDorisGIFCutView alloc] initWithGIFMetalData:self.metalData];
    self.gifCutView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 40);
    [self.operationArea addSubview:self.gifCutView];
}

- (void)loadPanGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapGesture.delegate = self;
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)loadMaskView
{
    [self.operationArea addSubview:({
        UIView * view = [UIView new];
        view.userInteractionEnabled = NO;
        view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = view.bounds;
        gradientLayer.colors = @[(__bridge id)GDorisColorA(4,0,18,0.26).CGColor,(__bridge id)GDorisColorA(4,0,18,0.01).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        [view.layer addSublayer:gradientLayer];
        view;
    })];
    [self.operationArea addSubview:({
        UIView * view = [UIView new];
        view.userInteractionEnabled = NO;
        view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-130, [UIScreen mainScreen].bounds.size.width, 130);
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = view.bounds;
        gradientLayer.colors = @[(__bridge id)GDorisColorA(4,0,18,0.26).CGColor,(__bridge id)GDorisColorA(4,0,18,0.01).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0);
        [view.layer addSublayer:gradientLayer];
        view;
    })];
}

- (void)loadNavigationbar
{
    self.navigationBar = [XCNavigationBar navigationBar];
    [self.operationArea addSubview:self.navigationBar];
    self.navigationBar.backgroundImageView.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    XCNavigationItem *cancel = [XCNavItemFactory createTitleButton:@"取消" titleColor:[UIColor whiteColor] highlightColor:[UIColor lightGrayColor] target:self selctor:@selector(cancel)];
    self.navigationBar.leftNavigationItem = cancel;
    XCNavigationItem *done = [XCNavItemFactory createTitleButton:@"完成" titleColor:GDorisColorCreate(@"29CE85") highlightColor:GDorisColorCreate(@"154212") target:self selctor:@selector(done)];
    self.navigationBar.rightNavigationItem = done;
}

- (void)loadToolbar
{
    self.toolBar = [[GDorisEditerToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-50, [UIScreen mainScreen].bounds.size.width, 37)];
    
    self.toolBar.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    __weak typeof(self) weakSelf = self;
    self.toolBar.editToolbarClickBlock = ^(DorisEditerToolbarItemType itemType,UIButton * sender) {
    };
    [self.operationArea addSubview:self.toolBar];
}

#pragma mark - action Method

- (void)cancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    
}
@end
