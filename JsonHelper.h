//
//  JsonHelper.h
//  ZhihuDailyReport
//
//  Created by 古玉彬 on 15/11/2.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CallBack)(id obj);
@interface JsonHelper : NSObject

- (void)jsonHelperWithUrlStr:(NSString *)urlStr WithBlock:(CallBack)callback;
@end
