//
//  DesignPicScrollView.h
//  GuyubinUIExam
//
//  Created by 古玉彬 on 15/10/31.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DesignPicScrollView : UIScrollView

@property (copy, nonatomic) NSArray *imageModelArray; //图片模型数组

@property (assign, nonatomic) NSInteger picIndex; //当前页
//通过下标修改显示的图片
- (void)updatePicByIndex:(NSInteger)picIndex;
@end
