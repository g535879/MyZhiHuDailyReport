//
//  NewsContentViewController.m
//  ZhihuDailyReport
//
//  Created by 古玉彬 on 15/11/2.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "NewsContentViewController.h"
#import "JsonHelper.h"
#import "DesignDisplayView.h"

#define MAX_WIDTH [UIScreen mainScreen].bounds.size.width
#define MAX_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface NewsContentViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UIWebView *_webView;
    NSCondition *_condition;
    UITableView *_tableview;
}

@end

@implementation NewsContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData]; //加载数据
    [self setLayout]; //布局相关
}

//加载数据
- (void)loadData {
    _condition = [[NSCondition alloc] init];
    //获取数据
    [self performSelectorInBackground:@selector(setRequest) withObject:nil];
    
    
}

//布局
- (void)setLayout {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT)];
//    _webView.scrollView.scrollEnabled = NO;
    
    //tableview
    _tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
   // _tableview.delegate = self;
   // _tableview.dataSource = self;
    [self.view addSubview:_webView];
    [_condition signal]; //唤醒该线程
    
    //上方视图
//    DesignDisplayView *displayView = [[DesignDisplayView alloc] initWithFrame:CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT/3)];
//    displayView.bgImage = [UIImage imageWithData:self.newsModel.imageData];
//    displayView.picDesription = self.newsModel.title;
//    _tableview.tableHeaderView = displayView;
    
    
        
}

#pragma mark -tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellIdnetifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    [cell.contentView addSubview:_webView];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MAX_HEIGHT;
}
//异步获取数据
- (void)setRequest {
    id __block JsonObj;
//    [_condition lock];
    [[[JsonHelper alloc] init] jsonHelperWithUrlStr:[NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/news/%lu",self.newsModel.uId] WithBlock:^(id obj) {
        JsonObj = obj;
        if (JsonObj[@"body"]) {
            NSString *str = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"%@\"><head><body>%@</body></html>",[JsonObj[@"css"] firstObject],JsonObj[@"body"]];
            if (!_webView) {
                [_condition wait];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_webView loadHTMLString:str baseURL:nil];
            });
//            [_condition unlock];
        }
    }];
    
    
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
