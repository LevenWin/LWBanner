//
//  LWBannerView.h
//  Banner
//
//  Created by leven on 2018/5/3.
//  Copyright © 2018年 leven. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BXLBannerViewCollectionCellView<NSObject>
@property (nonatomic, copy) NSString *reusedKey;
@end

@interface BXLBannerViewCollectionViewCell : UICollectionViewCell
@property (nonatomic, readonly) UIView <BXLBannerViewCollectionCellView> *cellView;
@end



@class LWBannerView;

@protocol LWBannerViewDelegate<NSObject>
- (void)bannerView:(LWBannerView *)bannerView didClickViewAtIndex:(NSInteger)index;
@end

@protocol LWBannerViewDataSource<NSObject>

- (NSInteger)numberOfItemsInBannerView:(LWBannerView *)bannerView;

/**
 根据index获取reusedKey ，然后根据reusedKey生成或者从重用池中获取bannerItemView。
 @param index 当前的inedx
 @param bannerView 当前的bannerView
 @return 返回字符串reusedKey
 */
- (NSString *)reusedKeyForIndex:(NSInteger)index
                     bannerView:(LWBannerView *)bannerView;


/**
 内部返回itemView，已经index。在这里可以对itemView进行数据赋值。

 @param itemView 根据reusedKey生成的itemView
 @param index 当前index
 @param bannerView 当前的bannerView
 */
- (void)itemView:(UIView *)itemView
        forIndex:(NSInteger)index
  withBannerView:(LWBannerView *)bannerView;
@end



/**
 LWBannerView 支持多个不同样式的BannerItem，采用collectionView配合timer轮播。
 */
@interface LWBannerView : UIView
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, weak) id<LWBannerViewDelegate> delegate;
@property (nonatomic, weak) id<LWBannerViewDataSource> dataSource;
@property (nonatomic, strong, readonly) UIPageControl *pageControl;
@property (nonatomic) NSTimeInterval pageDuring;

- (void)reloadData;

// 注册自定义的bannerItem，使用重用机制。
- (void)registerItemViewNib:(NSString *)nibName reusedKey:(NSString *)reusedKey;
- (void)registerItemViewClass:(NSString *)className reusedKey:(NSString *)reusedKey;

@end
