//
//  LWImageBannerView.m
//  Banner
//
//  Created by leven on 2018/5/3.
//  Copyright © 2018年 leven. All rights reserved.
//

#import "LWImageBannerView.h"
#import "LWBannerView.h"
#import "LWBannerColorItemView.h"
#import "LWBannerModel.h"
#import <YYKit.h>

static NSString *const kLWImageBannerItemViewReusedKey = @"kLWImageBannerItemViewReusedKey";
@interface LWImageBannerItemView : UIView<BXLBannerViewCollectionCellView>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *reusedKey;
@end

@implementation LWImageBannerItemView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        self.reusedKey = kLWImageBannerItemViewReusedKey;
    }
    return self;
}

-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}
@end



@interface LWImageBannerView()<LWBannerViewDelegate, LWBannerViewDataSource>
@property (nonatomic, strong) LWBannerView *bannerView;
@property (nonatomic, strong) NSArray <LWBannerModel *>*datas;
@end

@implementation LWImageBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.bannerView];
    [self loadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bannerView.frame = self.bounds;
    [_bannerView setNeedsLayout];
    [_bannerView layoutIfNeeded];
}

- (void)loadData {
    _datas = [LWBannerModel defaultModel];
    [self.bannerView reloadData];
}

#pragma mark - LWBannerViewDelegate
- (void)bannerView:(LWBannerView *)bannerView didClickViewAtIndex:(NSInteger)index {
    NSLog(@"点击Index %@",@(index));
}

#pragma mark - LWBannerViewDataSource
- (NSInteger)numberOfItemsInBannerView:(LWBannerView *)bannerView {
    return _datas.count;
}

- (NSString *)reusedKeyForIndex:(NSInteger)index
                     bannerView:(LWBannerView *)bannerView {
    LWBannerModel *model = _datas[index];
    NSString *reusedKey = nil;
    if (model.type == LWBannerImageItemType) {
        reusedKey = kLWImageBannerItemViewReusedKey;
    }else if (model.type == LWBannerColorItemType) {
        reusedKey = kLWColorBannerItemViewReusedKey;
    }
    return reusedKey;
}

- (void)itemView:(UIView *)itemView
        forIndex:(NSInteger)index
  withBannerView:(LWBannerView *)bannerView {
    LWBannerModel *model = _datas[index];
    if (model.type == LWBannerImageItemType) {
        LWImageBannerItemView *imageView = (LWImageBannerItemView *)itemView;
        [imageView.imageView setImageURL:[NSURL URLWithString:model.imageUrl]];
    }else if (model.type == LWBannerColorItemType) {
        LWBannerColorItemView *colorView = (LWBannerColorItemView *)itemView;
        colorView.backgroundColor = [UIColor colorWithHexString:model.color];
    }
}

#pragma mark - Lazy load

- (LWBannerView *)bannerView {
    if (!_bannerView) {
        _bannerView = [LWBannerView new];
        _bannerView.delegate = self;
        _bannerView.dataSource = self;
        [_bannerView registerItemViewClass:NSStringFromClass([LWImageBannerItemView class]) reusedKey:kLWImageBannerItemViewReusedKey];
        [_bannerView registerItemViewNib:NSStringFromClass([LWBannerColorItemView class]) reusedKey:kLWColorBannerItemViewReusedKey];
    }
    return _bannerView;
}
@end
