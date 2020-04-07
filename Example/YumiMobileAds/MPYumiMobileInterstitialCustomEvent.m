//
//  MPYumiMobileInterstitialCustomEvent.m
//  YumiMobileAds_Example
//
//  Created by 王泽永 on 2019/6/11.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "MPYumiMobileInterstitialCustomEvent.h"
#import "YumiMobileInterstitial.h"

@interface MPYumiMobileInterstitialCustomEvent ()<YumiMobileInterstitialDelegate>
@property (nonatomic) YumiMobileInterstitial *yumiInterstitial;
@property (nonatomic, assign) BOOL isReady;
@end

@implementation MPYumiMobileInterstitialCustomEvent
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
                                      adMarkup:(NSString *)adMarkup {
    NSString *sspToken = [info objectForKey:@"sspToken"];
    NSString *appID = [info objectForKey:@"appID"];
    NSString *placementID =  [info objectForKey:@"placementID"];
    self.isReady = NO;
    self.yumiInterstitial = [[YumiMobileInterstitial alloc] initWithSSPToken:sspToken appID:appID placementID:placementID interstitialSize:kYumiMobileAdInterstitial960x640 delegate:self];
    [self.yumiInterstitial requestAd];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController{
    if ([self isReady]) {
        [self.yumiInterstitial presentFromRootViewController:rootViewController];
        if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventWillAppear:)]) {
            [self.delegate interstitialCustomEventWillAppear:self];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidAppear:)]) {
            [self.delegate interstitialCustomEventDidAppear:self];
        }
    }
}

#pragma mark: YumiMediationInterstitialDelegate
- (void)yumiMobileInterstitialDidReceiveAd:(YumiMobileInterstitial *)interstitial {
    self.isReady = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:interstitial];
    }
}
- (void)yumiMobileInterstitial:(YumiMobileInterstitial *)interstitial didFailToReceivAdWithError:(NSError *)error {
    self.isReady = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}
- (void)yumiMobileInterstitialWillAppear:(YumiMobileInterstitial *)interstitial {
}
- (void)yumiMobileInterstitialWillDisappear:(YumiMobileInterstitial *)interstitial {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventWillDisappear:)]) {
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidDisappear:)]) {
        [self.delegate interstitialCustomEventDidDisappear:self];
    }
}
- (void)yumimobileInterstitialDidClickAd:(YumiMobileInterstitial *)interstitial {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidReceiveTapEvent:)]) {
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    }
}

- (void)dealloc {
    self.yumiInterstitial = nil;
}
@end
