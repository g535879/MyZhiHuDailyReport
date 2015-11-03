//
//  JsonHelper.m
//  ZhihuDailyReport
//
//  Created by 古玉彬 on 15/11/2.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "JsonHelper.h"

@implementation JsonHelper

- (void)jsonHelperWithUrlStr:(NSString *)urlStr WithBlock:(CallBack)callback {
    NSString *path = urlStr;
    //转化成url并编码
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3.0f];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            //解析json
             id Objdata = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                callback(Objdata); //回调
            
        }else{
            callback(nil);
        }
    }];
    
    [task resume];
}
@end
