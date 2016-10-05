//
//  OYCCarouselView.m
//  OYCCarouselView
//
//  Created by cao on 16/9/29.
//  Copyright © 2016年 OYC. All rights reserved.
//

#import "OYCCarouselView.h"

#define OYCPageControlHeight 20
#define OYCViewWidth self.frame.size.width
#define OYCViewHeight self.frame.size.height
#define OYCDefaultTimeInterval 1.0
#define OYCScrollForward 0
#define OYCScrollNext 1

@interface OYCCarouselView()<UIScrollViewDelegate>

/**
 *  滚动视图scrollView
 */
@property(nonatomic,weak)UIScrollView *scrollView;
/**
 *  pageControl
 */
@property(nonatomic,weak)UIPageControl *pageControl;
/**
 *  前一张视图
 */
@property(nonatomic,weak)UIImageView *previousImageView;
/**
 *  当前视图
 */
@property(nonatomic,weak)UIImageView *currentImageView;
/**
 *  下一张视图
 */
@property(nonatomic,weak)UIImageView *nextImageView;
/**
 *  轮播定时器
 */
@property(nonatomic,strong)NSTimer *timer;
/**
 *  当前视图显示的是第几张图片
 */
@property(nonatomic,assign)NSInteger currentPageIndex;
/**
 *  上一张视图显示的是第几张图片
 */
@property(nonatomic,assign)NSInteger previousPageIndex;
/**
 *  下一张视图显示的是第几张图片
 */
@property(nonatomic,assign)NSInteger nextPageIndex;
/**
 *  默认有三张视图
 */
@property(nonatomic,assign)NSInteger defaultImageViewNum;

@end

static OYCCarouselView *carouselView;
static BOOL isAutoFlag;

@implementation OYCCarouselView
/**
 *  滚动视图
 */
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        _scrollView = scrollView;
        _scrollView.delegate = self;
        [self addSubview:scrollView];
    }
    return _scrollView;
}

/**
 *  pageControl
 */
-(UIPageControl *)pageControl{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc]init];
        _pageControl = pageControl;
        [self addSubview:pageControl];
    }
    return _pageControl;
}

/**
 *  静态方法创建视图
 */
+(instancetype)sharedCarouselView{
    
    if (!carouselView) {
        carouselView = [[OYCCarouselView alloc]init];
    }
    return carouselView;
}

/**
 *  前一张视图
 */
-(UIImageView *)previousImageView{
    if (!_previousImageView) {
        UIImageView *previousImageView = [[UIImageView alloc]init];
        _previousImageView = previousImageView;
        _previousImageView.frame = CGRectMake(0, 0, OYCViewWidth, OYCViewHeight);
        [self.scrollView addSubview:previousImageView];
    }
    return _previousImageView;
}

/**
 *  当前视图
 */
-(UIImageView *)currentImageView{
    if (!_currentImageView) {
        UIImageView *currentImageView = [[UIImageView alloc]init];
        _currentImageView = currentImageView;
        _currentImageView.frame = CGRectMake(OYCViewWidth, 0, OYCViewWidth, OYCViewHeight);
        [self.scrollView addSubview:currentImageView];
    }
    return _currentImageView;
}

/**
 *  下一张视图
 */
-(UIImageView *)nextImageView{
    if (!_nextImageView) {
        UIImageView *nextImageView = [[UIImageView alloc]init];
        _nextImageView = nextImageView;
        _nextImageView.frame = CGRectMake(OYCViewWidth * 2, 0, OYCViewWidth, OYCViewHeight);
        [self.scrollView addSubview:nextImageView];
    }
    return _nextImageView;
}

/**
 *  在此做界面布局
 */
-(void)layoutSubviews{
    [super layoutSubviews];
    
    //判断应该用几张视图来显示
    [self caculateImageViewNum];
    
    //创建scrollView
    [self setupScrollView];
    
    //创建pageControl
    [self setupPageControl];
    
    //添加内容视图
    [self setupContentView];
    
    //开启轮播
    [self startCarousel];
}

/**
 *  判断应该用几张视图来显示
 */
-(void)caculateImageViewNum{
    self.showDatas.count > 1 ? (self.defaultImageViewNum = 3 ) : (self.defaultImageViewNum = 1 );
}

/**
 *  创建scrollView
 */
-(void)setupScrollView{
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(OYCViewWidth * self.defaultImageViewNum, OYCViewHeight);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
}

/**
 *  创建pageControl
 */
-(void)setupPageControl{
    
    self.pageControl.frame = CGRectMake(0, OYCViewHeight - OYCPageControlHeight, OYCViewWidth, OYCPageControlHeight);
    self.pageControl.numberOfPages = self.showDatas.count;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.pageIndicatorTintColor = self.pageIndicatorTintColor == nil ? [UIColor cyanColor] : self.pageIndicatorTintColor;
}

/**
 *  添加内容视图
 */
-(void)setupContentView{
    if (self.defaultImageViewNum == 1) {//一张视图显示
        [self setImageView:self.previousImageView withImageUrl:self.showDatas[self.previousPageIndex]];
        
        //不开启轮播
        isAutoFlag = NO;
    }else{//三张视图显示
        self.previousPageIndex = self.showDatas.count - 1;
        self.currentPageIndex = 0;
        self.nextPageIndex = 1;
        
        [self setImageView:self.previousImageView withImageUrl:self.showDatas[self.previousPageIndex]];
        [self setImageView:self.currentImageView withImageUrl:self.showDatas[self.currentPageIndex]];
        [self setImageView:self.nextImageView withImageUrl:self.showDatas[self.nextPageIndex]];
        
        //开启轮播标志
        isAutoFlag = YES;
        //默认显示中间的视图
        [self.scrollView setContentOffset:CGPointMake(OYCViewWidth, 0) animated:NO];
    }
}

/**
 *  给图片视图的图片赋值
 */
-(void)setImageView:(UIImageView *)imageView withImageUrl:(NSURL *)url{
    NSData *data = [NSData dataWithContentsOfURL:url];
    imageView.image = [UIImage imageWithData:data];
}

/**
 *  开启轮播
 */
-(void)startCarousel{
    if (isAutoFlag) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(self.timeInterval == 0.0 ? OYCDefaultTimeInterval : self.timeInterval) target:self selector:@selector(carouselAnimation) userInfo:nil repeats:YES];
    }else{
//        isAutoFlag = YES;
//        [self startCarousel];
        [self.timer invalidate];
        self.timer = nil;
    }
}

/**
 *  轮播动画
 */
-(void)carouselAnimation{
    [self.scrollView setContentOffset:CGPointMake(OYCViewWidth * 2, 0) animated:YES];
}

#pragma - mark <UIScrollViewDelegate>
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (isAutoFlag) {
        [self scrollDirection:OYCScrollNext];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    isAutoFlag = NO;
    [self.timer invalidate];
    self.timer = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat currentOffestX = scrollView.contentOffset.x;
    
    if (currentOffestX / OYCViewWidth == 0) {
        
        [self scrollDirection:OYCScrollForward];
        
    }else if(currentOffestX / OYCViewWidth == 2){

        [self scrollDirection:OYCScrollNext];
    }else{
        //doNothing
    }
    
    isAutoFlag = YES;
    [self startCarousel];
}

/**
 *  向前或者向后滚，0向前，1向后
 */
-(void)scrollDirection:(NSInteger)direction{
    if (direction == OYCScrollForward) {//向前滚
        self.nextPageIndex = self.currentPageIndex;
        self.currentPageIndex = self.previousPageIndex;
        self.previousPageIndex == 0 ? self.previousPageIndex = self.showDatas.count - 1 : --self.previousPageIndex;
    }else{//向后滚
        self.previousPageIndex = self.currentPageIndex;
        self.currentPageIndex = self.nextPageIndex;
        self.nextPageIndex == self.showDatas.count - 1 ? self.nextPageIndex = 0 : ++self.nextPageIndex;
    }
    
    [self setImageView:self.previousImageView withImageUrl:self.showDatas[self.previousPageIndex]];
    [self setImageView:self.currentImageView withImageUrl:self.showDatas[self.currentPageIndex]];
    [self setImageView:self.nextImageView withImageUrl:self.showDatas[self.nextPageIndex]];
    
    [self.scrollView setContentOffset:CGPointMake(OYCViewWidth, 0) animated:NO];
    self.pageControl.currentPage = self.currentPageIndex;
}

@end
