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
#import "MBProgressHUD.h"



#define MAX_WIDTH [UIScreen mainScreen].bounds.size.width
#define MAX_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SCROVIEW_HEIGHT MAX_HEIGHT/3
typedef void (^GetImageData)(NSData *imageData);

@interface DailyNewsViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *_dataArray; //数据源
    NSMutableArray *_topNewsArray; //头条新闻数组
    DesignPicScrollView *_scrollview; //滚动视图
    UITableView *_tableView; //表格视图
    DesignDisplayView *_currentImageView; //当前显示的滚动图
    MBProgressHUD *_progressView; //加载框
    UIView *_titleView;//遮罩view
    
    
}

@end
@implementation DailyNewsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setData]; //加载数据
    [self setNavigationRefer]; //导航栏相关
    [self setLayout]; //布局
    

    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)setNavigationRefer {
//    self.navigationItem.title = @"今日热文";
    UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [tLabel setTextColor:[UIColor whiteColor]];
    tLabel.text = @"今日头条";
    self.navigationItem.titleView = tLabel;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bigShadow.png"] forBarMetrics:UIBarMetricsCompactPrompt];
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX_WIDTH, 64)];
    [_titleView setBackgroundColor:[UIColor colorWithRed:0.41f green:0.79f blue:0.97f alpha:1.00f]];
    [self.navigationController.view insertSubview:_titleView belowSubview:self.navigationController.navigationBar];
    self.navigationController.navigationBar.layer.masksToBounds = YES;
    [_titleView setAlpha:0];
}

//加载数据
- (void)setData {
    if (!_dataArray) {
        _dataArray = [@[] mutableCopy];
    }
    if (!_topNewsArray) {
        _topNewsArray = [@[] mutableCopy];
    }
    //异步加载新闻数据
    [self performSelectorInBackground:@selector(asyncDownloadPic) withObject:nil];
}

//布局
- (void)setLayout {
    

    //上方背景图
    _currentImageView = [[DesignDisplayView alloc] initWithFrame:CGRectMake(0, -30, MAX_WIDTH, MAX_HEIGHT/3+70)];
    _currentImageView.hidden = YES;
    [self.view addSubview:_currentImageView];
    
    //滚动视图
    _scrollview = [[DesignPicScrollView alloc] initWithFrame:CGRectMake(0,-30, MAX_WIDTH, MAX_HEIGHT/3)];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -30, MAX_WIDTH, MAX_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    _tableView.tableHeaderView = _scrollview;
    
    
    //加载框
    _progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_progressView setDimBackground:YES];
    [_progressView setHidden:NO];


}

#pragma mark - 异步下载图片
- (void)asyncDownloadPic {
    id __block Jsonobj;
    [[[JsonHelper alloc] init] jsonHelperWithUrlStr:@"http://news-at.zhihu.com/api/4/news/latest" WithBlock:^(id obj) {
        Jsonobj = obj;
        if ([Jsonobj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)Jsonobj;
            NSArray *dataArray = dic[@"stories"];
            NSArray *topStories = dic[@"top_stories"];
            if (dataArray.count) {
                for (NSDictionary *dic in dataArray) {
                    NewsModel *model = [[NewsModel alloc] init]; //下方新闻建立数据模型
                    model.images = [dic[@"images"] firstObject];
                    model.title = dic[@"title"];
                    model.uId = [dic[@"id"] integerValue];
                    //存入数组中
                    [_dataArray addObject:model];
                }
                //头条
                for (NSDictionary *dic in topStories) {
                    NewsModel *model = [[NewsModel alloc] init]; //头条建立数据模型
                    model.images = dic[@"image"];
                    model.title = dic[@"title"];
                    model.uId = [dic[@"id"] integerValue];
                    //存入数组中
                    [_topNewsArray addObject:model];
                }
                _scrollview.imageModelArray = _topNewsArray;
                //放入到scrollvew中,取前5个数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    //刷新tableview
                    [_tableView reloadData];
                    //关闭小菊花
                    [_progressView setHidden:YES];
                    
                    //显示分割线
                    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    CGFloat x = scrollView.contentOffset.x;
    NSLog(@"%f",y);
    if (y < 0) {
        if (y <= -60) {  //最大偏移量
            scrollView.contentOffset = CGPointMake(x, -60);
            return;
        }
       //调整图片大小和位置
        if (_scrollview.hidden) { //滚动视图隐藏状态
            UILabel *label = (UILabel *)_currentImageView.subviews[1]; //图片描述
            
            static CGFloat originalY;  //描述原始中点y
            static CGFloat bgOriginalH; //图片原始高度
            static CGFloat bgOriginalCenterY; //图片中心点原始位置
           static dispatch_once_t once;
            dispatch_once(&once, ^{
                originalY = label.center.y;
                bgOriginalCenterY = _currentImageView.center.y;
                bgOriginalH = _currentImageView.frame.size.height;
            });
            //描述
            CGPoint labelCenter = [label center];
            labelCenter.y = originalY +fabs(y);
            label.center = labelCenter;
            
            //图片
            CGPoint imageViewCenter = _currentImageView.center;
            imageViewCenter.y = bgOriginalCenterY + fabs(y);
            CGRect frame = _currentImageView.frame;
            frame.size.height = bgOriginalH + fabs(y);
            _currentImageView.frame = frame;
            _currentImageView.center = imageViewCenter;
        }
        
    }else if (y >=0 && y <= 127){ //用户往上推。调整字体的位置
        UILabel *label = (UILabel *)_currentImageView.subviews[1]; //图片描述
        static CGFloat originalY;  //描述原始中点y
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            originalY = label.center.y;
        });
        
        //描述
        CGPoint labelCenter = [label center];
        labelCenter.y = originalY - fabs(y);
        label.center = labelCenter;
        [_titleView setAlpha:y/127.0];

    }
}

////开始滚动,调整图片显示方式
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y == 0){
        if(!_scrollview.hidden){ //没有隐藏
            _scrollview.hidden = YES;
            _currentImageView.hidden = NO;
            _currentImageView.bgImage = [UIImage imageWithData:[_topNewsArray[_scrollview.picIndex] imageData]]; //图片
            _currentImageView.picDesription = [_topNewsArray[_scrollview.picIndex] title]; //文字
        }else{
            [_scrollview setHidden:NO];
            _currentImageView.hidden = YES;
        }
    }
    NSLog(@"开始");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y == 0) { //回到顶部
        if (_scrollview.hidden) {
            _currentImageView.hidden = YES;
            _scrollview.hidden = NO;
        }
        
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
