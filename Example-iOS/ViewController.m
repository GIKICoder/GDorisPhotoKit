//
//  ViewController.m
//  Example-iOS
//
//  Created by GIKI on 2020/6/10.
//  Copyright © 2020 GIKI. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "GDorisPhotoPickerController.h"
#import "GDorisSwipeGestureTransition.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        _tableView = tableView;
        tableView;
    })];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


#pragma mark -- TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewCell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    cell.textLabel.textColor = UIColor.blackColor;
    return cell;
}

#pragma mark -- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openPhotoPicker];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)openPhotoPicker
{
    /*
    GDorisPhotoPickerController * picker = [[GDorisPhotoPickerController alloc] init];
    UINavigationController *  nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.modalPresentationStyle = UIModalPresentationCustom;
    GDorisSwipeGestureTransition * swipeTransition = [GDorisSwipeGestureTransition swipeGestureTransitionWithTarget:picker];
    swipeTransition.needsTopMask = YES;
    swipeTransition.containerOffset = 44;
    nav.transitioningDelegate = swipeTransition;
    nav.modalPresentationStyle = UIModalPresentationCustom;
    nav.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:nav animated:YES completion:nil];
     */
}
@end
