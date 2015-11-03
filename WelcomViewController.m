//
//  WelcomViewController.m
//  ZhiHu
//
//  Created by 古玉彬 on 15/10/31.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "WelcomViewController.h"
#import "DailyNewsViewController.h"
#import "JsonHelper.h"

#define MAX_WIDTH [UIScreen mainScreen].bounds.size.width
#define MAX_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface WelcomViewController (){
    UIImageView *_logoImageView;
}

@end

@implementation WelcomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    //logo图
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, MAX_HEIGHT - 164, MAX_WIDTH-100, 64)];
    _logoImageView.image = [UIImage imageNamed:@"zhihu_logo"];
    [self.view addSubview:_logoImageView];
    
    //异步获取数据
    [self performSelectorInBackground:@selector(requestPic) withObject:nil];
//    [self requestPic];
    
}

//跳到主界面
- (void)goHomePage {
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[DailyNewsViewController alloc] init]]];
}
//请求图片
- (void)requestPic {
    NSString *path = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/start-image/%g*%g",MAX_WIDTH,MAX_HEIGHT];
    //NSString *path = @"http://localhost:8080/IOS/download/file.do?filename=weibo.json";
    JsonHelper *jsonHelper = [[JsonHelper alloc] init];
    id __block jsonData;
    [jsonHelper jsonHelperWithUrlStr:path WithBlock:^(id obj) {
        jsonData = obj;
        if ([jsonData isKindOfClass:[NSDictionary class]]) {
            if ([jsonData objectForKey:@"img"]) { //解析到图片
                
                UIImage *bgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:jsonData[@"img"]]]];
                //        UIImage *bgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //主线程刷新UI
                    [self updateUIWithBgImage:bgImage];
                });
            }
        }else{
            [self performSelectorOnMainThread:@selector(goHomePage) withObject:nil waitUntilDone:NO];
        }

    }];
    }

//更新UI
- (void)updateUIWithBgImage:(UIImage *)image {
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = image;
    //设置背景图
    [self.view addSubview:bgImageView];
    //logo图层到最上层
    [self.view bringSubviewToFront:_logoImageView];
    //动画
    [UIView animateWithDuration:2.0 animations:^{
        bgImageView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1);
    } completion:^(BOOL finished) {
                [self goHomePage];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
