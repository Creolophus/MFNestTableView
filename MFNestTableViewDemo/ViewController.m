//
//  ViewController.m
//  MFNestTableViewDemo
//
//  Created by Lyman Li on 2018/4/6.
//  Copyright © 2018年 Lyman Li. All rights reserved.
//

#import "MFNestTableView.h"
#import "MFPageView.h"
#import "MFSegmentView.h"
#import "MFTransparentNavigationBar.h"

#import "ViewController.h"

@interface ViewController () <MFNestTableViewDelegate, MFNestTableViewDataSource, MFPageViewDataSource, MFPageViewDelegate, MFSegmentViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MFNestTableView *nestTableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) MFSegmentView *segmentView;
@property (nonatomic, strong) MFPageView *contentView;

@property (nonatomic, strong) NSMutableArray <NSArray *> *dataSource;
@property (nonatomic, strong) NSMutableArray <UIView *> *viewList;

@property (nonatomic, assign) BOOL canContentScroll;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self initDataSource];
    [self initLayout];
}

- (void)initDataSource {
    
    NSArray *pageDataCount = @[@2, @10, @30];
    
    _dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < pageDataCount.count; ++i) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int j = 0; j < [pageDataCount[i] integerValue]; ++j) {
            [array addObject:[NSString stringWithFormat:@"page - %d - row - %d", i, j]];
        }
        [_dataSource addObject:array];
    }
    
    _viewList = [[NSMutableArray alloc] init];
    
    // 添加3个tableview
    for (int i = 0; i < pageDataCount.count; ++i) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.tag = i;
        [_viewList addObject:tableView];
    }
    
    // 添加ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    UIImage *image = [UIImage imageNamed:@"img1.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * image.size.height / image.size.width);
    scrollView.contentSize = imageView.frame.size;
    scrollView.alwaysBounceVertical = YES;
    [scrollView addSubview:imageView];
    scrollView.delegate = self;
    [_viewList addObject:scrollView];
    
    // 添加webview
    UIWebView *webview = [[UIWebView alloc] init];
    webview.backgroundColor = [UIColor whiteColor];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.lymanli.com/"]]];
    webview.scrollView.delegate = self;
    [_viewList addObject:webview];
}

- (void)initLayout {

    [self initHeaderView];
    [self initSegmentView];
    [self initContentView];
    
    _nestTableView = [[MFNestTableView alloc] initWithFrame:self.view.bounds];
    _nestTableView.headerView = _headerView;
    _nestTableView.segmentView = _segmentView;
    _nestTableView.contentView = _contentView;
    _nestTableView.allowGestureEventPassViews = _viewList;
    _nestTableView.delegate = self;
    _nestTableView.dataSource = self;
    
    [self.view addSubview:_nestTableView];
}

- (void)initHeaderView {
    
    // 因为将navigationBar设置了透明，所以这里设置将header的高度减少navigationBar的高度，
    // 并将header的subview向上偏移，遮挡navigationBar透明后的空白
    CGFloat offsetTop = [self nestTableViewContentInsetTop:_nestTableView];
    
    UIImage *image = [UIImage imageNamed:@"img2.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, -offsetTop, CGRectGetWidth(self.view.frame), self.view.frame.size.width * image.size.height / image.size.width);
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame) - offsetTop)];
    [header addSubview:imageView];
    
    _headerView = header;
}

- (void)initSegmentView {
    
    _segmentView = [[MFSegmentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40)];
    _segmentView.delegate = self;
    _segmentView.itemWidth = 80;
    _segmentView.itemFont = [UIFont systemFontOfSize:15];
    _segmentView.itemNormalColor = [UIColor colorWithRed:155.0 / 255 green:155.0 / 255 blue:155.0 / 255 alpha:1];
    _segmentView.itemSelectColor = [UIColor colorWithRed:244.0 / 255 green:67.0 / 255 blue:54.0 / 255 alpha:1];
    _segmentView.bottomLineWidth = 60;
    _segmentView.bottomLineHeight = 2;
    _segmentView.itemList = @[@"列表1", @"列表2", @"列表3", @"图片", @"网页"];
}

- (void)initContentView {
    
    _contentView = [[MFPageView alloc] initWithFrame:self.view.bounds];
    _contentView.delegate = self;
    _contentView.dataSource = self;
}

#pragma mark - MFSegmentViewDelegate

- (void)segmentView:(MFSegmentView *)segmentView didScrollToIndex:(NSUInteger)index {
    
    [_contentView scrollToIndex:index];
}

#pragma mark - MFPageViewDataSource & MFPageViewDelegate

- (NSUInteger)numberOfPagesInPageView:(MFPageView *)pageView {
    
    return [_viewList count];
}

- (UIView *)pageView:(MFPageView *)pageView pageAtIndex:(NSUInteger)index {
    
    return _viewList[index];
}

- (void)pageView:(MFPageView *)pageView didScrollToIndex:(NSUInteger)index {
    
    [_segmentView scrollToIndex:index];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSUInteger pageIndex = tableView.tag;
    return [_dataSource[pageIndex] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSUInteger pageIndex = tableView.tag;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataSource[pageIndex][indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!_canContentScroll) {
        scrollView.contentOffset = CGPointZero;
    } else if (scrollView.contentOffset.y <= 0) {
        _nestTableView.canScroll = YES;
        _canContentScroll = NO;
    }
    scrollView.showsVerticalScrollIndicator = _canContentScroll;
}

#pragma mark - MFNestTableViewDelegate & MFNestTableViewDataSource

- (void)nestTableViewContentCanScroll:(MFNestTableView *)nestTableView {
    
    self.canContentScroll = YES;
}

- (void)nestTableViewContainerCanScroll:(MFNestTableView *)nestTableView {
 
    for (id view in self.viewList) {
        UIScrollView *scrollView;
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = view;
        } else if ([view isKindOfClass:[UIWebView class]]) {
            scrollView = ((UIWebView *)view).scrollView;
        }
        if (scrollView) {
            scrollView.contentOffset = CGPointZero;
        }
    }
}

- (void)nestTableViewDidScroll:(UIScrollView *)scrollView {
        
    if (_headerView) {
        CGFloat offset = scrollView.contentOffset.y;
        CGFloat canScrollHeight = [_nestTableView heightForContainerCanScroll];
        MFTransparentNavigationBar *bar = (MFTransparentNavigationBar *)self.navigationController.navigationBar;
        if ([bar isKindOfClass:[MFTransparentNavigationBar class]]) {
            [bar setBackgroundAlpha:offset / canScrollHeight];
        }
    }
}

- (CGFloat)nestTableViewContentInsetTop:(MFNestTableView *)nestTableView {
    
    if (IS_IPHONE_X) {
        return 88;
    } else {
        return 64;
    }
}

@end
