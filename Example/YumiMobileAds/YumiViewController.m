//
//  YumiViewController.m
//  YumiMobileAds
//
//  Created by wzy2010416033@163.com on 06/05/2019.
//  Copyright (c) 2019 wzy2010416033@163.com. All rights reserved.
//

#import "YumiViewController.h"
#import "MPAdView.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
@interface YumiViewController () <MPAdViewDelegate>
@property (nonatomic) MPAdView *MPbanner;
@property (nonatomic) UITextView *console;
@property (nonatomic) UIButton *requestBanner;

@end

@implementation YumiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUI];
}

- (void)setUpUI {
    self.console = [[UITextView alloc] initWithFrame:CGRectMake(0, screenHeight*0.3, screenWidth, screenHeight*0.7 - 100)];
    CGFloat buttonWidth = 150;
    CGFloat buttonHeight = 50;
    self.requestBanner = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, 50, buttonWidth, buttonHeight)];
    [self.requestBanner addTarget:self action:@selector(requestAd) forControlEvents:UIControlEventTouchUpInside];
    self.requestBanner.backgroundColor = [UIColor blackColor];
    self.requestBanner.layer.cornerRadius = 10;
    self.requestBanner.layer.masksToBounds = YES;
    [self.requestBanner setTitle:@"Request Banner" forState:UIControlStateNormal];
    [self.view addSubview:self.requestBanner];
    [self.view addSubview:self.console];
}

- (void)addLog:(NSString *)newLog {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.console.layoutManager.allowsNonContiguousLayout = NO;
        NSString *oldLog = weakSelf.console.text;
        NSString *text = [NSString stringWithFormat:@"%@\n%@", oldLog, newLog];
        if (oldLog.length == 0) {
            text = [NSString stringWithFormat:@"%@", newLog];
        }
        [weakSelf.console scrollRangeToVisible:NSMakeRange(text.length, 1)];
        weakSelf.console.text = text;
    });
}

- (void)requestAd {
    if (!self.MPbanner) {
        self.MPbanner = [[MPAdView alloc] initWithAdUnitId:@"fbd076b7ac6d4cd78e37fa62ff5dbc11"
                                                    size:MOPUB_BANNER_SIZE];
        self.MPbanner.delegate = self;
        self.MPbanner.frame = CGRectMake((screenWidth - MOPUB_BANNER_SIZE.width) / 2,
                                       screenHeight - MOPUB_BANNER_SIZE.height - 34,
                                       MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
        [self.view addSubview:self.MPbanner];
    }
    [self.MPbanner loadAd];
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view {
    [self addLog:@"adViewDidLoadAd"];
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    [self addLog:[NSString stringWithFormat:@"adViewDidFailToLoadAd,error:%@",error.localizedDescription]];
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
    [self addLog:@"willPresentModalViewForAd"];
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
    [self addLog:@"willLeaveApplicationFromAd"];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view {
    [self addLog:@"didDismissModalViewForAd"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
