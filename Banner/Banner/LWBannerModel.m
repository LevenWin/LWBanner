//
//  LWBannerModel.m
//  Banner
//
//  Created by leven on 2018/5/3.
//  Copyright © 2018年 leven. All rights reserved.
//

#import "LWBannerModel.h"

@implementation LWBannerModel


+ (NSArray<LWBannerModel *>*)defaultModel {
    NSArray *colors = @[@"#ef3478",
                        @"#CDCDCD",
                        @"#343434",
                        @"#767676"];
    NSArray *images = @[@"http://g.hiphotos.baidu.com/image/h%3D300/sign=d72d649b8e025aafcc3278cbcbecab8d/f3d3572c11dfa9ec8c2d744c6ed0f703918fc16d.jpg",
                        @"http://c.hiphotos.baidu.com/image/h%3D300/sign=9f9323341c38534393cf8121a312b01f/e1fe9925bc315c609e11bbb781b1cb13485477e6.jpg",
                        @"http://g.hiphotos.baidu.com/image/h%3D300/sign=95c56bd522dda3cc14e4be2031e83905/b03533fa828ba61e76203a654d34970a314e59aa.jpg",
                        @"http://c.hiphotos.baidu.com/image/h%3D300/sign=e47101aea16eddc439e7b2fb09dab6a2/377adab44aed2e736151a9678b01a18b86d6fac5.jpg"];
    
    NSMutableArray *datas = @[].mutableCopy;

    for (NSInteger i = 0; i < 8; i ++) {
        LWBannerModel *model = [LWBannerModel new];
        model.type = (i % 2);
        if (model.type == LWBannerColorItemType) {
            model.color = colors[i/2];
        }else if (model.type == LWBannerImageItemType){
            model.imageUrl = images[i/2];
        }
        [datas addObject:model];
    }
    return datas;
}

@end
