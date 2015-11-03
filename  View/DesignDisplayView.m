//
//  DesignDisplayView.m
//  GuyubinUIExam
//
//  Created by 古玉彬 on 15/10/31.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "DesignDisplayView.h"

@interface DesignDisplayView (){
    UIImageView *_bgImageView; //背景图
    UILabel *_descpitionLabel; //描述label
    
}

@end

@implementation DesignDisplayView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgImageView.userInteractionEnabled = YES;
        [self addSubview:_bgImageView];
        _descpitionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height - 90, frame.size.width-20, 80)];
        _descpitionLabel.numberOfLines = 2;
        //透明度
        //_descpitionLabel.backgroundColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.3];
        //字体颜色
        [_descpitionLabel setTextColor:[UIColor whiteColor]];
        //字体大小
        [_descpitionLabel setFont:[UIFont systemFontOfSize:20]];
        [self addSubview:_descpitionLabel];
    }
    return self;
}

- (void)setBgImage:(UIImage *)bgImage {
    _bgImageView.image = bgImage;
}

- (void)setPicDesription:(NSString *)picDesription {
    _descpitionLabel.text =picDesription;
}
@end
