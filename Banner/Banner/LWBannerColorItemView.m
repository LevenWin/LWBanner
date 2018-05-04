//
//  LWBannerColorItemView.m
//  Banner
//
//  Created by leven on 2018/5/3.
//  Copyright © 2018年 leven. All rights reserved.
//

#import "LWBannerColorItemView.h"


NSString *const kLWColorBannerItemViewReusedKey = @"kLWColorBannerItemViewReusedKey";

@implementation LWBannerColorItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reusedKey = kLWColorBannerItemViewReusedKey;
    }
    return self;
}

@end
