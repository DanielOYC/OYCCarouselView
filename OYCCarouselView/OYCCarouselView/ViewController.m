//
//  ViewController.m
//  OYCCarouselView
//
//  Created by cao on 16/10/5.
//  Copyright © 2016年 OYC. All rights reserved.
//

#import "ViewController.h"
#import "OYCCarouselView.h"

@interface ViewController ()

/**
 *  数据源
 */
@property(nonatomic,strong)NSMutableArray *showDatas;

@end

@implementation ViewController

/**
 *  待显示的数据源
 */
-(NSMutableArray *)showDatas{
    if (!_showDatas) {
        _showDatas = [NSMutableArray array];
    }
    return _showDatas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数据
    [self setupData];
    
    //创建轮播视图
    [self setupCarouselView];
}

/**
 *  初始化数据
 */
-(void)setupData{
    
    for (NSInteger i = 0; i < 5; i++) {
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"resources.bundle/Yosemite0%ld",i] withExtension:@"jpg"];
        [self.showDatas addObject:url];
        
    }
    
}

/**
 *  创建轮播视图
 */
-(void)setupCarouselView{
    
    //创建并且设置frame
    OYCCarouselView *carouselView = [OYCCarouselView sharedCarouselView];
    carouselView.frame = CGRectMake(100, 100, 300, 300);
    carouselView.timeInterval = 1.5;
    
    //传递数据
    carouselView.showDatas = self.showDatas;
    
    [self.view addSubview:carouselView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

}

@end
