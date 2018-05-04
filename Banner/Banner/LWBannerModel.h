//
//  LWBannerModel.h
//  Banner
//
//  Created by leven on 2018/5/3.
//  Copyright © 2018年 leven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger , LWBannerItemType) {
    LWBannerImageItemType = 0,
    LWBannerColorItemType,
};

@interface LWBannerModel : NSObject
@property (nonatomic) LWBannerItemType type;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *color;

+ (NSArray<LWBannerModel *>*)defaultModel;
@end
