//
//  DailyNewsViewController.m
//  ZhihuDailyReport
//
//  Created by 古玉彬 on 15/11/2.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "DailyNewsViewController.h"
#import "DesignPicScrollView.h"
#import "NewsModel.h"
#import "JsonHelper.h"
#import "NewsTableViewCell.h"
#import "NewsContentViewController.h"
#import "DesignDisplayView.h"

#define MAX_WIDTH [UIScreen mainScreen].bounds.size.width
#define MAX_HEIGHT [UIScreen mainScreen].bounds.size.height
typedef void (^GetImageData)(NSData *imageData);

@interface DailyNewsViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *_dataArray; //数据源
    DesignPicScrollView *_scrollview; //滚动视图
    UITableView *_tableView; //表格视图
    
}

@end
@implementation DailyNewsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setData]; //加载数据
    [self setLayout]; //布局
    
}

//在这里隐藏导航栏
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = YES;
//    [self.navigationController.navigationBar setAlpha:0.5];[
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:255 green:255 blue:255 alpha:1.0]] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar.layer setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:0.4 green:1 blue:1 alpha:0.2]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
//加载数据
- (void)setData {
    if (!_dataArray) {
        _dataArray = [@[] mutableCopy];
    }
    //异步加载新闻数据
    [self performSelectorInBackground:@selector(asyncDownloadPic) withObject:nil];
}

//布局
- (void)setLayout {
    
    self.navigationItem.title = @"今日热文";
    
    //滚动视图
    _scrollview = [[DesignPicScrollView alloc] initWithFrame:CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT/3+20)];
//    [self.view addSubview:_scrollview];
    
    //tablevie
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.contentOffset = CGPointMake(0, -64);
    [self.view addSubview:_tableView];
    
//    //空白图层
////    D *_clearView = [[UIView alloc] ];
//    DesignDisplayView *_clearView = [[DesignDisplayView alloc] initWithFrame:CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT/3)];
//    _clearView.picDesription = @"带婴儿坐飞机，需要做什么准sdsd备？";
//    [_clearView setBackgroundColor:[UIColor clearColor]];
    _tableView.tableHeaderView = _scrollview;
}

#pragma mark - 异步下载图片
- (void)asyncDownloadPic {
    id __block Jsonobj;
    [[[JsonHelper alloc] init] jsonHelperWithUrlStr:@"http://news-at.zhihu.com/api/4/news/latest" WithBlock:^(id obj) {
        Jsonobj = obj;
        if ([Jsonobj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)Jsonobj;
            NSArray *dataArray = dic[@"stories"];
            if (dataArray.count) {
                for (NSDictionary *dic in dataArray) {
                    NewsModel *model = [[NewsModel alloc] init]; //建立数据模型
                    model.images = [dic[@"images"] firstObject];
                    model.title = dic[@"title"];
                    model.uId = [dic[@"id"] integerValue];
                    //存入数组中
                    [_dataArray addObject:model];
                }
                //放入到scrollvew中,取前5个数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    _scrollview.imageModelArray = [_dataArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];
                    //刷新tableview
                    [_tableView reloadData];
                });
                
            }
        }
    }];
 
}

#pragma mark - tableview delegate
//section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//number or row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

//cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NewsTableViewCell" owner:self options:nil] lastObject];
    }
    //清空数据
    cell.newsImageView.image = nil;
    cell.newsConent.text = nil;
    //获取数据模型
    NewsModel *model = _dataArray[indexPath.row];
    //重新赋值
    cell.newsConent.text = model.title;
    //图片
    if (model.imageData.length) { //有图片
        cell.newsImageView.image = [UIImage imageWithData:model.imageData];
    }else{ //异步获取图片
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self downloadImageWithUrl:model.images withBlock:^(NSData *imageData) {
                //主线程刷新UI
                dispatch_sync(dispatch_get_main_queue(), ^{
                    cell.newsImageView.image = [UIImage imageWithData:imageData];
                });
                model.imageData = imageData;
                
            }];
        });
    }
    return cell;
}
//分组高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

//选中事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsContentViewController *nvc = [[NewsContentViewController alloc] init];
    nvc.newsModel = _dataArray[indexPath.row];
//    [self presentViewController:nvc animated:YES completion:nil];
    [self.navigationController pushViewController:nvc animated:YES];
}

#pragma mark - scorolview delegate
//拖动偏移量限制在-155
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    CGFloat x = scrollView.contentOffset.x;
    NSLog(@"%f",y);
    if (y < 0) {
        if (y <= -95) {
            scrollView.contentOffset = CGPointMake(x, -95);
            return;
        }
        UIImageView *centerImageView = [_scrollview subviews][1];
//        CGRect rect = centerImageView.frame;
//        rect.size.height+=10;
//        centerImageView.frame = rect;
        
    }
    

}

//加载图片
- (void)downloadImageWithUrl:(NSString *)url withBlock:(GetImageData)imageData{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if ([data length]) {
        imageData(data); // 回调
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
