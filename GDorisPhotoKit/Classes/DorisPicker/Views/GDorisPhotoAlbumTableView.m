//
//  GDorisPhotoAlbumTableView.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/8/14.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisPhotoAlbumTableView.h"
#import "GDorisPhotoAlbumCell.h"
#import "GDorisPhotoHelper.h"
#import "NSArray+GDoris.h"
#define kPhotoAlbumCellHeight 80
@interface GDorisPhotoAlbumTableView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIControl * maskControl;
@property (nonatomic, strong) UIView * cornerView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray * photoAlbums;
@property (nonatomic, assign) CGFloat  tableHeight;
@property (nonatomic, assign) NSInteger  selectIndex;
@end
@implementation GDorisPhotoAlbumTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.maxHeight = 4*kPhotoAlbumCellHeight+20;
        self.tableHeight = self.maxHeight;
        self.maskControl = [[UIControl alloc] init];
        self.maskControl.backgroundColor = [UIColor clearColor];
        [self.maskControl addTarget:self action:@selector(maskControlAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.maskControl];
        
        self.cornerView = [UIView new];
        self.cornerView.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.cornerView];
        [self.cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.left.right.equalTo(self);
           make.height.mas_equalTo(10);
        }];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.layer.cornerRadius = 10;
        self.tableView.layer.masksToBounds = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(0);
        }];
        [self.maskControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.hidden = YES;
    }
    return self;
}

#pragma mark - Public Method

- (void)fulFill:(NSArray *)albums selectIndex:(NSInteger)index
{
    self.photoAlbums = albums;
    self.selectIndex = index;
    CGFloat totalheight = albums.count * kPhotoAlbumCellHeight;
    self.tableHeight = MIN(totalheight, self.maxHeight);
}

- (void)show
{
    self.hidden = NO;
    [self.tableView reloadData];
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.45 animations:^{
        self.maskControl.backgroundColor = [GDorisPhotoHelper colorWithHex:@"000000" alpha:0.2];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.tableHeight);
        }];
        [self.tableView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [self __dismissReal];
}

- (void)__dismiss
{
    [self __dismissReal];
    if (self.photoAlbumDismiss) {
        self.photoAlbumDismiss();
    }
}

- (void)__dismissReal
{
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.45 animations:^{
        self.maskControl.backgroundColor = [GDorisPhotoHelper colorWithHex:@"000000" alpha:0.0];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.tableView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - Action Method

- (void)maskControlAction
{
    [self __dismiss];
}

#pragma mark -- TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoAlbums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisPhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GDorisPhotoAlbumCell"];
    if (!cell) {
        cell = [[GDorisPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GDorisPhotoAlbumCell"];
        
    }
    GAssetsGroup * group = [self.photoAlbums g_objectAtIndexSafely:indexPath.row];
    [cell configCollectionModel:group];
    
    if (indexPath.item == self.selectIndex) {
        [cell selectIndex:YES];
    } else {
        [cell selectIndex:NO];
    }
    return cell;
}

#pragma mark -- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndex = indexPath.row;
    [self.tableView reloadData];
    GAssetsGroup * group = [self.photoAlbums g_objectAtIndexSafely:indexPath.row];
    if (self.selectPhotoAlbum) {
        self.selectPhotoAlbum(group);
    }
     [self __dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPhotoAlbumCellHeight;
}


@end
