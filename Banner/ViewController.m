//
//  ViewController.m
//  Banner
//
//  Created by leven on 2018/5/3.
//  Copyright © 2018年 leven. All rights reserved.
//

#import "ViewController.h"
#import "BViewController.h"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)present:(id)sender {
    [self.navigationController pushViewController:[BViewController new] animated:YES];
}

- (void)dealloc {
    NSLog(@"view controller dealloc");
}

@end
