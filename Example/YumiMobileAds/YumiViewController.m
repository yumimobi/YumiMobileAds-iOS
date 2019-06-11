//
//  YumiViewController.m
//  YumiMobileAds
//
//  Created by wzy2010416033@163.com on 06/05/2019.
//  Copyright (c) 2019 wzy2010416033@163.com. All rights reserved.
//

#import "YumiViewController.h"
#import "MPAdView.h"
#import "YumiMobileTools.h"
#import "MPInterstitialAdController.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
@interface YumiViewController () <MPAdViewDelegate,MPInterstitialAdControllerDelegate>
@property (nonatomic) MPAdView *MPbanner;
@property (nonatomic) UITextView *console;
@property (nonatomic) UIButton *requestBanner;
@property (nonatomic) UIButton *requestInterstitial;
@property (nonatomic) UIButton *presentInterstitial;
@property (nonatomic) MPInterstitialAdController *interstitial;

@end

@implementation YumiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setUpUI {
    YumiMobileTools *tool = [YumiMobileTools sharedTool];
    CGFloat buttonWidth = [tool adaptedValue6:200];
    CGFloat buttonHeight = [tool adaptedValue6:50];
    CGFloat margin = [tool adaptedValue6:10];
    CGFloat topMargin = [tool adaptedValue6:10];
    if ([tool isiPhoneX]) {
        topMargin += kIPHONEXSTATUSBAR;
    }
    if ([tool isiPhoneXR]) {
        topMargin += kIPHONEXRSTATUSBAR;
    }
    // request banner
    self.requestBanner = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, topMargin, buttonWidth, buttonHeight)];
    [self.requestBanner addTarget:self action:@selector(requestBannerAd) forControlEvents:UIControlEventTouchUpInside];
    self.requestBanner.backgroundColor = [UIColor blackColor];
    self.requestBanner.layer.cornerRadius = 10;
    self.requestBanner.layer.masksToBounds = YES;
    [self.requestBanner setTitle:@"Request Banner" forState:UIControlStateNormal];
    [self.view addSubview:self.requestBanner];
    // request interstitial
    self.requestInterstitial = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, topMargin + buttonHeight + margin, buttonWidth, buttonHeight)];
    [self.requestInterstitial addTarget:self action:@selector(requestInterstitialAd) forControlEvents:UIControlEventTouchUpInside];
    self.requestInterstitial.backgroundColor = [UIColor blackColor];
    self.requestInterstitial.layer.cornerRadius = 10;
    self.requestInterstitial.layer.masksToBounds = YES;
    [self.requestInterstitial setTitle:@"Request Interstitial" forState:UIControlStateNormal];
    [self.view addSubview:self.requestInterstitial];
    // present interstitial
    self.presentInterstitial = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - buttonWidth)/2, topMargin + buttonHeight * 2 + margin * 2, buttonWidth, buttonHeight)];
    [self.presentInterstitial addTarget:self action:@selector(presentInterstitialAd) forControlEvents:UIControlEventTouchUpInside];
    self.presentInterstitial.backgroundColor = [UIColor blackColor];
    self.presentInterstitial.layer.cornerRadius = 10;
    self.presentInterstitial.layer.masksToBounds = YES;
    [self.presentInterstitial setTitle:@"Present Interstitial" forState:UIControlStateNormal];
    [self.view addSubview:self.presentInterstitial];
    self.console = [[UITextView alloc] initWithFrame:CGRectMake(0, topMargin + buttonHeight * 3 + margin * 3, screenWidth, screenHeight*0.7 - 100)];
    self.console.backgroundColor = [UIColor grayColor];
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

- (void)requestBannerAd {
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

- (void)requestInterstitialAd {
    self.interstitial = [MPInterstitialAdController
                         interstitialAdControllerForAdUnitId:@"76594f39485b4ad696e11cb9192cc202"];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (void)presentInterstitialAd {
    if (self.interstitial.ready){
        [self.interstitial showFromViewController:self];
    }else {
        [self addLog:@"interstitial not ready"];
    }
}

#pragma mark - MPBannerDelegate
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

#pragma mark - MPInterstitialDelegate
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [self addLog:@"interstitialDidLoadAd"];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
                          withError:(NSError *)error {
    [self addLog:[NSString stringWithFormat:@"interstitialDidFailToLoadAd error:%@",error.localizedDescription]];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    [self addLog:@"interstitialWillAppear"];
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    [self addLog:@"interstitialDidAppear"];
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    [self addLog:@"interstitialWillDisappear"];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    [self addLog:@"interstitialDidDisappear"];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    [self addLog:@"interstitialDidExpire"];
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    [self addLog:@"interstitialDidReceiveTapEvent"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
