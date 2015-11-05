//
//  DesignPicScrollView.m
//  GuyubinUIExam
//
//  Created by 古玉彬 on 15/10/31.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "DesignPicScrollView.h"
#import "DesignDisplayView.h"
#import "NewsModel.h"




@interface DesignPicScrollView ()<UIScrollViewDelegate> {
    
    DesignDisplayView *_leftImageView; //左侧视图
    DesignDisplayView *_centerImageView; //中间视图
    DesignDisplayView *_rightImageView; //右侧视图
    UIPageControl *_pageController; //小白点
    CGFloat _viewHeight; //容器宽度
    CGFloat _viewWidth; //容器宽度
}
@property (strong,nonatomic) NSMutableDictionary *imageDataDic; //图片数据保存下载的图片
@end

@implementation DesignPicScrollView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _viewHeight = frame.size.height;
        _viewWidth = frame.size.width;
        self.showsHorizontalScrollIndicator = NO;
        self.contentSize = CGSizeMake(_viewWidth * 3, _viewHeight-64);
        self.contentOffset = CGPointMake(_viewWidth, 0);
        self.pagingEnabled = YES;
        self.delegate = self;
        [self setDatailLayout]; //设置布局

    }
    return self;
}


//赋值数据
- (void)setImageModelArray:(NSArray *)imageModelArray {
    _imageModelArray = imageModelArray; //初始化模型数组
    self.imageDataDic = [@{} mutableCopy]; //初始化图片数据字典
    [self initDisplay]; //初始化显示。加载前三张
    [self loadImage]; //异步加载图片(后面2张)
    
    _pageController.numberOfPages = _imageModelArray.count ;//总图片数

}
//布局
- (void)setDatailLayout {
    
    //imageView
    _leftImageView = [[DesignDisplayView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, _viewHeight+70)];
    [self addSubview:_leftImageView];
    _centerImageView =[[DesignDisplayView alloc] initWithFrame:CGRectMake(_viewWidth, 0, _viewWidth, _viewHeight+70)];
    [self addSubview:_centerImageView];
    //rightImageView
    _rightImageView = [[DesignDisplayView alloc]initWithFrame:CGRectMake(_viewWidth * 2, 0, _viewWidth, _viewHeight+70)];
    [self addSubview:_rightImageView];
    
    //pageControll
    _pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(_viewWidth, _viewHeight-32, _viewWidth, 32)];
    [self addSubview:_pageController];
}

//初始化显示样式
- (void)initDisplay {
    [self updatePicByIndex:self.picIndex];
    _pageController.currentPage = 0; //当前页
}

//修改当前显示的图片
-(void)updatePicByIndex:(NSInteger)picIndex {
    
    NewsModel *leftPicModel = self.imageModelArray[[self calIndex:picIndex - 1]];
    NewsModel *centerPicModel = self.imageModelArray[[self calIndex:picIndex]];
    NewsModel *rightPicModel = self.imageModelArray[[self calIndex:picIndex + 1]];
    
    //更新左侧视图
    [self updateImage:_leftImageView withDesignModel:leftPicModel];
    //中间视图
    [self updateImage:_centerImageView withDesignModel:centerPicModel];
    //右侧视图
    [self updateImage:_rightImageView withDesignModel:rightPicModel];

}

//计算图片下标
- (NSInteger)calIndex:(NSInteger) picIndex {
    return (picIndex + self.imageModelArray.count) % self.imageModelArray.count;
}

//更新自定义视图图片和文字描述
- (void)updateImage:(DesignDisplayView *)view withDesignModel:(NewsModel *)model {
    id obj = self.imageDataDic[[NSNumber numberWithInteger:[self.imageModelArray indexOfObject:model]]]; //获取该字典中key对应的图片

    if ([obj isKindOfClass:[UIImage class]]) { //是图片数据
        [self updateView:view withDesignModel:obj];
    }
    else{ //没有图片
        //异步加载图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self requestImage:view withDesignModel:model];
        });

    }
    
    //主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        view.picDesription = model.title;
    });

}

#pragma mark - 滚动视图协议代理
//滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
    CGPoint point = scrollView.contentOffset;
    //偏移量太小。不修改
    if (fabs(point.x - _viewWidth) < _viewWidth/2) {
        return;
    }
    if (point.x > _viewWidth) { //往右滑
        self.picIndex = [self calIndex:self.picIndex+1];
    }
    else{
        self.picIndex = [self calIndex:self.picIndex-1];
    }
    
    //更新UI
    [self updatePicByIndex:self.picIndex];
    
    //设置偏移量
    self.contentOffset = CGPointMake(_viewWidth, 0);
    
    //设置分页
    _pageController.currentPage = self.picIndex;
}

//异步请求图片
- (void)requestImage:(DesignDisplayView *)view withDesignModel:(NewsModel *)model {
    NSString *imagePath = model.images;
    NSURL *imageUrl = [NSURL URLWithString:[imagePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];

    if (image) {
        
        if (view) {
            //主线程刷新UI
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateView:view withDesignModel:image];
            });
        }
        
        //保存图片到字典
        [self.imageDataDic setObject:image forKey:[NSNumber numberWithInteger:[self.imageModelArray indexOfObject:model]]];
        //保存图片到model
        model.imageData = imageData;
    }
    
}

//更新UI
- (void)updateView:(DesignDisplayView *)view withDesignModel:(UIImage *)image {
    view.bgImage = image;
}

//加载图片数组
- (void)loadImage {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //加载从第三张后面的数据
    for (NewsModel *model in [self.imageModelArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, self.imageModelArray.count-3)]]) {
        //加载图片
        [queue addOperationWithBlock:^{
            [self requestImage:nil withDesignModel:model];
        }];
    }
}
@end
