//
//  YumiViewController.m
//  YumiMobileAds
//
//  Created by wzy2010416033@163.com on 06/05/2019.
//  Copyright (c) 2019 wzy2010416033@163.com. All rights reserved.
//

#import "YumiViewController.h"
#import <YumiMobileAds/YumiMobileBanner.h>

@interface YumiViewController ()<YumiMobileBannerDelegate>

@end

@implementation YumiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    YumiMobileBanner *banner = [[YumiMobileBanner alloc] initWithSSPToken:@"EXVTAW2VYMKUY30TBGLUZ3XPC3H2YW6NQHPWBGF6LMNVBTA6LK9YNS6PMJAUNZG=" appID:@"yywtptfq" placementID:@"5jr45zcy" bannerSize:kYumiMobileAdViewBanner320x50 delegate:self rootViewController:self];
    [banner requestAd];
    banner.frame = CGRectMake((self.view.frame.size.width - 320)/2,self.view.frame.size.height - 50, 320, 50);
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:banner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
