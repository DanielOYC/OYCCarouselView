//
//  OYCCarouselView.h
//  OYCCarouselView
//
//  Created by cao on 16/9/29.
//  Copyright © 2016年 OYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OYCCarouselView : UIView

/**
 *  待展示的数据
 */
@property(nonatomic,strong)NSArray *showDatas;
/**
 *  轮播时间间隔
 */
@property(nonatomic,assign)NSTimeInterval timeInterval;
/**
 *  静态方法创建
 */
+(instancetype)sharedCarouselView;
/**
 *  pageIndicatorTintColor
 */
@property(nonatomic,strong)UIColor *pageIndicatorTintColor;

@end
