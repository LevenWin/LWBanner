//
//  LWBannerView.m
//  Banner
//
//  Created by leven on 2018/5/3.
//  Copyright © 2018年 leven. All rights reserved.
//

#import "LWBannerView.h"

/**
外部注册bannerItemView时，生成的model。后面根据这个model，生成bannerItemView；
 */
@interface LWBannerItemReuseModel : NSObject
@property (nonatomic, strong) NSString *reusedKey;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *nibName;
@end

@implementation LWBannerItemReuseModel
@end


@class BXLBannerViewCollectionViewCell;
@protocol BXLBannerViewCollectionViewCellDelegate<NSObject>


/**
 当前的BannerViewItem即将进行重用时的回调。在回调里讲用户注册的view缓存起来。以供下次显示时使用

 @param cell 当前显示的 BXLBannerViewCollectionViewCell；
 */
- (void)BXLBannerViewCollectionViewCellWillReuseCell:(BXLBannerViewCollectionViewCell *)cell;
@end

/**
 bannerViewItem继承于UICollectionViewCell，
 */
@interface BXLBannerViewCollectionViewCell()
@property (nonatomic, weak) id<BXLBannerViewCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) UIView <BXLBannerViewCollectionCellView>*cellView;
- (void)fillWithCellView:(UIView *)cellView;
@end

@implementation BXLBannerViewCollectionViewCell

- (void)prepareForReuse {
    if ([_delegate respondsToSelector:@selector(BXLBannerViewCollectionViewCellWillReuseCell:)]) {
        [_delegate BXLBannerViewCollectionViewCellWillReuseCell:self];
    }
    [super prepareForReuse];
}

- (void)fillWithCellView:(UIView <BXLBannerViewCollectionCellView>*)cellView {
    _cellView = cellView;
    [self.contentView addSubview:_cellView];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _cellView.frame = self.contentView.bounds;
}

@end

@interface LWBannerView()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
BXLBannerViewCollectionViewCellDelegate>{
    CGSize _cellSize;
    NSInteger _totalPage;
    NSInteger _currentIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *reuseCellArr;
@property (nonatomic, strong) NSMutableArray *reuseCellModelArr;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LWBannerView

#pragma mark - Init
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

- (void)setPageDuring:(NSTimeInterval)pageDuring {
    _pageDuring = pageDuring;
    [self generateTimer];
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)setupUI {
    self.layer.masksToBounds = YES;
    _reuseCellArr = @[].mutableCopy;
    _reuseCellModelArr = @[].mutableCopy;
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    self.pageDuring = 5;
    _currentIndex = -1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
    _cellSize = _collectionView.frame.size;
    _pageControl.frame = CGRectMake(20, self.frame.size.height-20, self.frame.size.width - 40, 15);
}

- (UIView *)reusedViewWithReusedKey:(NSString *)reusedKey {
    NSDictionary *useDict = nil;
    NSArray *searArr = [_reuseCellArr copy];
    for (NSDictionary *dict in searArr) {
        UIView *view = [dict objectForKey:reusedKey];
        if (view) {
            useDict = dict;
            break;
        }
    }
    UIView *view = nil;
    if (!useDict) {
        view = [self generateReusedViewWithReusedKey:reusedKey];
    }else{
        view = [useDict objectForKey:reusedKey];
        [_reuseCellArr removeObject:useDict];
    }
    return view;
}

- (UIView *)generateReusedViewWithReusedKey:(NSString *)reusedKey {
    LWBannerItemReuseModel *item = nil;
    for (LWBannerItemReuseModel *model in _reuseCellModelArr) {
        if ([model.reusedKey isEqualToString:reusedKey]) {
            item = model;
            break;
        }
    }
    
    if (item.className) {
        Class class = NSClassFromString(item.className);
        if (class) {
            UIView *view = [class new];
            return view;
        }
    }else if (item.nibName){
        UIView *cellView = [[NSBundle mainBundle] loadNibNamed:item.nibName owner:self options:nil].firstObject;
        if (cellView) {
            return cellView;
        }else{
            return [UIView new];
        }
    }
    return [UIView new];
}


- (void)scrollPage{
    _currentIndex ++;
    [self updateCollectionOffsetAnimation:YES];
}

- (void)pageClick {
    _currentIndex = _pageControl.currentPage;
    [self updateCollectionOffsetAnimation: YES];
}

- (void)updateCollectionOffsetAnimation:(BOOL)animation{
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.frame.size.width * (_currentIndex + 1), 0) animated:animation];
}

- (NSInteger)realIndexByIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return _totalPage-1;
    }else if (indexPath.row == _totalPage + 1){
        return 0;
    }
    return indexPath.row - 1;
}

#pragma mark - CollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(numberOfItemsInBannerView:)]) {
        _totalPage  = [_dataSource numberOfItemsInBannerView:self];
        self.pageControl.numberOfPages = _totalPage;
    }
    if (_totalPage <= 0) {
        return 0;
    }
    return _totalPage + 2; // 首位各多加一个,为了可无限的左右滑动
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BXLBannerViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BXLBannerViewCollectionViewCell class]) forIndexPath:indexPath];
    if ([_dataSource respondsToSelector:@selector(reusedKeyForIndex:bannerView:)]) {
        NSInteger index  = [self realIndexByIndexPath:indexPath];
        NSString *reusedKey = [_dataSource reusedKeyForIndex:index bannerView:self];
        UIView *reusedView = [self reusedViewWithReusedKey:reusedKey];
        if ([_dataSource respondsToSelector:@selector(itemView:forIndex:withBannerView:)]) {
            [_dataSource itemView:reusedView forIndex:index withBannerView:self];
        }
        cell.delegate = self;
        [cell fillWithCellView:reusedView];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(bannerView:didClickViewAtIndex:)]) {
        [_delegate bannerView:self didClickViewAtIndex:[self realIndexByIndexPath:indexPath]];
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

#pragma mark - BXLBannerViewCollectionViewCellDelegate
- (void)BXLBannerViewCollectionViewCellWillReuseCell:(BXLBannerViewCollectionViewCell *)cell {
    NSString *reusedKey = cell.cellView.reusedKey;
    if (cell.cellView
        && reusedKey) {
        [self.reuseCellArr addObject:@{reusedKey:cell.cellView}];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat scrollW = scrollView.frame.size.width;
    NSInteger currentPage = scrollView.contentOffset.x / scrollW;
    
    if (currentPage == _totalPage+1) {
        _currentIndex = 0;
        [self updateCollectionOffsetAnimation:NO];
    } else if (currentPage == 0) {
        _currentIndex = _totalPage-1;
        [self updateCollectionOffsetAnimation:NO];
    }else {
        _currentIndex = currentPage - 1;
    }
    self.pageControl.currentPage = _currentIndex;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self generateTimer];
    __weak __typeof(_timer)weakTimer = _timer;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_pageDuring * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakTimer setFireDate:[NSDate distantPast]];
    });
}

#pragma mark - Public Method
- (void)reloadData {
    [_collectionView reloadData];
}

- (void)registerItemViewNib:(NSString *)nibName reusedKey:(NSString *)reusedKey{
    if (nibName
        && reusedKey) {
        LWBannerItemReuseModel *model = [LWBannerItemReuseModel new];
        model.nibName = nibName;
        model.reusedKey = reusedKey;
        [self.reuseCellModelArr addObject:model];
    }
}

- (void)registerItemViewClass:(NSString *)className reusedKey:(NSString *)reusedKey{
    if (className
        && reusedKey) {
        LWBannerItemReuseModel *model = [LWBannerItemReuseModel new];
        model.className = className;
        model.reusedKey = reusedKey;
        [self.reuseCellModelArr addObject:model];
    }
}

#pragma mark - Lazy Load
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[BXLBannerViewCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([BXLBannerViewCollectionViewCell class])];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        [_pageControl addTarget:self action:@selector(pageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageControl;
}


- (NSTimer *)generateTimer {
    [self removeTimer];
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer timerWithTimeInterval:_pageDuring
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
        [weakSelf scrollPage];
    }];
    [_timer setFireDate:[NSDate distantFuture]];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    return _timer;
}

- (void)removeTimer {
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}
- (void)dealloc {
    NSLog(@"banner view dealloc");
}
@end

