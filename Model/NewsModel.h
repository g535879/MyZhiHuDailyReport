//
//  NewsModel.h
//  ZhihuDailyReport
//
//  Created by 古玉彬 on 15/11/2.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject
@property (copy, nonatomic) NSString *title;  //新闻标题
@property (copy, nonatomic) NSString *images; //新闻图片
@property (assign,nonatomic) NSInteger uId; //新闻id
@property (strong, nonatomic) NSData *imageData; //图片二进制数据
@end
