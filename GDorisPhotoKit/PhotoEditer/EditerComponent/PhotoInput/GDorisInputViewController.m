//
//  GDorisInputViewController.m
//  GDoris
//
//  Created by GIKI on 2018/9/15.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisInputViewController.h"
#import "GDorisPhotoHelper.h"
#import "UIView+GDoris.h"
#import "XCNavigationBar.h"
#import "YYText.h"
#import "GDorisInputTextParse.h"
#import "GDorisInputColorToolbar.h"
#import "XCGrowingTextView.h"
#import "GDorisInputStylePanel.h"
#import "GDorisTextStyleItem.h"
@interface GDorisInputViewController ()<YYTextViewDelegate,XCGrowingTextViewDelegate>
@property (nonatomic, strong) XCNavigationBar * navigationBar;
@property (nonatomic, strong) YYLabel * textLabel;
@property (nonatomic, strong) UIView * toolbarView;
@property (nonatomic, strong) GDorisInputColorToolbar * colorToolbar;
@property (nonatomic, strong) UIView * inputBar;
@property (nonatomic, strong) XCGrowingTextView * inputTextView;
@property (nonatomic, strong) UIButton * moreButton;
@property (nonatomic, strong) UIColor * currentColor;
@property (nonatomic, strong) UIView * keyboardPanel;
@property (nonatomic, assign) BOOL isShowPanel;
@property (nonatomic, strong) GDorisInputStylePanel * stylePanel;
@property (nonatomic, strong) GDorisTextStyleItem * textStyleItem;
@end

@implementation GDorisInputViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.currentColor = UIColor.whiteColor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textStyleItem = [GDorisTextStyleItem new];
    [self setupUI];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.inputTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserver];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithRed:(0)/255.0 green:(0)/255.0 blue:(0)/255.0 alpha:0.6];
    [self setupNavigationbar];
    [self setupTextLabel];
    [self setupToolbar];
    [self setupKeybaordPanel];
}

- (void)setupTextLabel
{
    self.textLabel = [YYLabel new];
    self.textLabel.text = @"输入文字";
    self.textLabel.textColor = self.textStyleItem.textColor;
    self.textLabel.font = self.textStyleItem.font;
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.textLabel];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 60;
    CGFloat height = 200;
    self.textLabel.frame = CGRectMake( 30, 100, width, height);
}

- (void)setupTextView
{
    UIView * container = [[UIView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 50)];
    container.backgroundColor = UIColor.whiteColor;
    self.inputBar = container;
    [self.toolbarView addSubview:container];
    
    self.inputTextView = [[XCGrowingTextView alloc] initWithFrame:CGRectMake(15,6, [UIScreen mainScreen].bounds.size.width-15-48, 36)];
    self.inputTextView.returnKeyType = UIReturnKeyDefault;
    self.inputTextView.minHeight = 36;
    self.inputTextView.maxNumberOfLines = 4;
    self.inputTextView.delegate = self;
    self.inputTextView.placeholderColor = GDorisColorCreate(@"C9C7C7");
    self.inputTextView.font = [UIFont systemFontOfSize:14];
    self.inputTextView.placeholder = @"输入文字";
    self.inputTextView.layer.cornerRadius = 19;
    self.inputTextView.layer.masksToBounds = YES;
    self.inputTextView.layer.borderColor = GDorisColorCreate(@"E1E1E1").CGColor;
    self.inputTextView.layer.borderWidth = 1;
    [self.inputTextView setContentInset:UIEdgeInsetsMake(0, 13, 0, 13)];
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    if (@available(iOS 11.0, *)) {
        self.inputTextView.internalTextView.textDragInteraction.enabled = NO;
    }
    [container addSubview:self.inputTextView];
    
    [container addSubview:({
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setImage:[UIImage imageNamed:@"Fire_btn_emoji_black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"Fire_comment_btn_jp"] forState:UIControlStateSelected];
        [_moreButton addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _moreButton;
    })];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(28);
        make.bottom.mas_equalTo(self.inputTextView.mas_bottom).mas_offset(-5);
        make.right.mas_equalTo(container.mas_right).mas_offset(-10);
    }];
}

- (void)setupToolbar
{
    self.toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-100, [UIScreen mainScreen].bounds.size.width, 100)];
    [self.view addSubview:self.toolbarView];
    
    self.colorToolbar = [[GDorisInputColorToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self.colorToolbar configColors:[self colorToolbarColors]];
    [self.toolbarView addSubview:self.colorToolbar];
    __weak typeof(self) weakSelf = self;
    self.colorToolbar.colorDidSelectBlock = ^(UIColor * _Nonnull color) {
        weakSelf.currentColor = color;
    };
    self.colorToolbar.fillBtnActionBlock = ^(BOOL isFill) {
        [weakSelf borderActionState:isFill];
    };
    
    [self setupTextView];
    
}

- (void)setupNavigationbar
{
    self.navigationBar = [XCNavigationBar navigationBar];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.backgroundImageView.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    XCNavigationItem *cancel = [XCNavItemFactory createTitleButton:@"取消" titleColor:[UIColor whiteColor] highlightColor:[UIColor lightGrayColor] target:self selctor:@selector(cancel)];
    self.navigationBar.leftNavigationItem = cancel;
    XCNavigationItem *done = [XCNavItemFactory createTitleButton:@"完成" titleColor:GDorisColorCreate(@"29CE85") highlightColor:GDorisColorCreate(@"154212") target:self selctor:@selector(done)];
    self.navigationBar.rightNavigationItem = done;
}

- (void)setupKeybaordPanel
{
    self.keyboardPanel = [UIView new];
    self.keyboardPanel.hidden = YES;
    [self.view addSubview:self.keyboardPanel];
    self.keyboardPanel.backgroundColor = UIColor.whiteColor;
    self.keyboardPanel.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width, 266+GDoris_TabBarMargin);
    self.stylePanel.hidden = NO;
}

- (void)setCurrentColor:(UIColor *)currentColor
{
    _currentColor = currentColor;
    if (self.textStyleItem.background) {
        self.textStyleItem.backgroundColor = currentColor;
        self.textStyleItem.textColor = UIColor.whiteColor;
    } else {
        self.textStyleItem.backgroundColor = UIColor.clearColor;
        self.textStyleItem.textColor = self.currentColor;
    }
    [self processTextLayout];
}


- (void)processTextLayout
{
    NSString * text = self.inputTextView.text;
    if (!text || text.length<=0) {
        text = @"";
    }
    NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString:text];
    attributed.yy_font = self.textStyleItem.font;
    attributed.yy_color = self.textStyleItem.textColor;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 1;
    style.lineBreakMode = kCTLineBreakByCharWrapping;
    style.alignment = kCTTextAlignmentJustified;
    attributed.yy_paragraphStyle = style;
    if (self.textStyleItem.verticalForm) {
        self.textLabel.textVerticalAlignment = self.textStyleItem.verticalAlignment;
    } else {
        self.textLabel.textAlignment = self.textStyleItem.textAlignment;
    }
    if (self.textStyleItem.background) {
         YYTextBorder * border = [YYTextBorder borderWithFillColor:self.textStyleItem.backgroundColor cornerRadius:0];
         border.lineJoin = kCGLineJoinBevel;
         attributed.yy_textBackgroundBorder = border;
    }
    YYTextContainer *container = [YYTextContainer new];
    container.verticalForm = self.textStyleItem.verticalForm;
    if (self.textStyleItem.verticalForm) {
        container.size = CGSizeMake(HUGE, 200);
    } else {
        container.size = CGSizeMake([UIScreen mainScreen].bounds.size.width-60, HUGE);
    }
    
    YYTextLayout * textLayout = [YYTextLayout layoutWithContainer:container text:attributed];
    self.textLabel.textLayout = textLayout;

}

#pragma mark - Lazy load Method

- (GDorisInputStylePanel *)stylePanel
{
    if (!_stylePanel) {
        _stylePanel = [[GDorisInputStylePanel alloc] init];
        _stylePanel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.keyboardPanel.g_height);
        [self.keyboardPanel addSubview:_stylePanel];
    }
    return _stylePanel;
}

#pragma mark - action Method

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done
{
    if (self.generateTextLayoutAction) {
        self.generateTextLayoutAction(self.textLabel.textLayout);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)moreBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self showKeyboardPanel];
    } else {
        [self __becomeFirstResponder];
    }
}

- (void)borderActionState:(BOOL)isFill
{
    self.textStyleItem.background = isFill;
    if (isFill) {
        self.textStyleItem.textColor = UIColor.whiteColor;
        self.textStyleItem.backgroundColor = self.currentColor;
    } else {
        self.textStyleItem.textColor = self.currentColor;
        self.textStyleItem.backgroundColor = UIColor.clearColor;
    }
    [self processTextLayout];
}

- (void)alignmentAction:(UIButton *)alignment
{
    alignment.selected = !alignment.selected;
}

- (NSArray *)colorToolbarColors
{
    return @[GDorisColor(250, 250, 250),
             GDorisColor(43, 43, 43),
             GDorisColor(255, 29, 19),
             GDorisColor(251, 245, 7),
             GDorisColor(21, 225, 19),
             GDorisColor(251, 55, 254),
             GDorisColor(140, 6, 255)];
}

#pragma mark - Keyboard Method

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        self.toolbarView.g_bottom = CGRectGetMinY(keyboardFrame);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.isShowPanel) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.toolbarView.g_bottom = [UIScreen mainScreen].bounds.size.height;
    }];
}

- (void)showKeyboardPanel
{
    BOOL isFirstResponder = NO;
    if ([self.inputTextView isFirstResponder]) {
        isFirstResponder = YES;
        self.isShowPanel = isFirstResponder;
        [self __resignFirstResponder];
    }
    
    self.keyboardPanel.hidden = NO;
    if (isFirstResponder) {
        self.keyboardPanel.g_bottom = [UIScreen mainScreen].bounds.size.height;
        self.toolbarView.g_bottom = self.keyboardPanel.g_top;
        self.isShowPanel = NO;
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.keyboardPanel.g_bottom =  [UIScreen mainScreen].bounds.size.height;
            self.toolbarView.g_bottom = self.keyboardPanel.g_top;
        }];
    }
}

- (void)hiddenKeyboardPanel
{
    [UIView animateWithDuration:0.25 animations:^{
        self.keyboardPanel.g_top = [UIScreen mainScreen].bounds.size.height;
        self.toolbarView.g_bottom = [UIScreen mainScreen].bounds.size.height;
    } completion:^(BOOL finished) {
        self.keyboardPanel.hidden = YES;
    }];
}

- (void)__resignFirstResponder
{
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }
}

- (void)__becomeFirstResponder
{
    [self.inputTextView becomeFirstResponder];
}

#pragma mark - YYTextViewDelegate

- (void)textViewDidChange:(YYTextView *)textView
{
    
}

#pragma mark - XCGrowingTextViewDelegate

- (BOOL)growingTextViewShouldBeginEditing:(XCGrowingTextView *)growingTextView
{
    return YES;
}

- (void)growingTextViewDidEndEditing:(XCGrowingTextView *)growingTextView
{
}

- (void)growingTextView:(XCGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat oriHeight = growingTextView.g_height;
    if (height > oriHeight) {
        self.toolbarView.g_top -= (height-oriHeight);
        self.toolbarView.g_height += (height-oriHeight);
        self.inputBar.g_height  += (height-oriHeight);
        self.inputTextView.g_top = 6;
    } else {
        self.toolbarView.g_top += (oriHeight-height);
        self.toolbarView.g_height -= (oriHeight-height);
        self.inputBar.g_height  -= (oriHeight-height);
        self.inputTextView.g_top = 6;
    }
}

- (void)growingTextView:(XCGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    
}

- (BOOL)growingTextViewShouldReturn:(XCGrowingTextView *)growingTextView
{
    return YES;
}

- (void)growingTextViewDidChange:(XCGrowingTextView *)growingTextView
{
    NSInteger maxCount = 140;
    if (growingTextView.text.length > maxCount) {
        if (!growingTextView.internalTextView.markedTextRange && growingTextView.internalTextView.text.length > maxCount) {
            // Interception of maximum number of characters.
            growingTextView.text = [growingTextView.text substringToIndex:maxCount];
            // remove undoaction, 以免 undo 操作造成crash.
            [self.undoManager removeAllActions];
            return;
        }
    }
    [self processTextLayout];
}
@end
