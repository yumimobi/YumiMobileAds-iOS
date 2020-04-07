//
//  MPYumiMobileBannerCustomEvent.m
//  YumiMobileAds_Example
//
//  Created by 王泽永 on 2019/6/10.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "MPYumiMobileBannerCustomEvent.h"
#import "YumiMobileBanner.h"

@interface MPYumiMobileBannerCustomEvent ()<YumiMobileBannerDelegate>
@property (nonatomic) YumiMobileBanner *yumiBanner;

@end

@implementation MPYumiMobileBannerCustomEvent
- (void)requestAdWithSize:(CGSize)size
          customEventInfo:(NSDictionary *)info
                 adMarkup:(NSString *)adMarkup {
    NSString *sspToken = [info objectForKey:@"sspToken"];
    NSString *appID = [info objectForKey:@"appID"];
    NSString *placementID =  [info objectForKey:@"placementID"];
    
    YumiMobileBannerSize yumiBannerSize = kYumiMobileAdViewBanner320x50;
    if (size.width == 728 && size.height == 90) {
        yumiBannerSize = kYumiMobileAdViewBanner728x90;
    }
    
    self.yumiBanner = [[YumiMobileBanner alloc] initWithSSPToken:sspToken appID:appID placementID:placementID bannerSize:yumiBannerSize delegate:self rootViewController:[self.delegate viewControllerForPresentingModalView]];
    [self.yumiBanner requestAd];
}

- (void)yumiMobileBannerDidReceiveAd:(YumiMobileBanner *)bannerView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent:didLoadAd:)]) {
        [self.delegate bannerCustomEvent:self didLoadAd:bannerView];
    }
}
- (void)yumiMobileBanner:(YumiMobileBanner *)bannerView didFailToReceivAdWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent:didFailToLoadAdWithError:)]) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    }
}
- (void)yumimobileBannerDidClickAd:(YumiMobileBanner *)bannerView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEventWillBeginAction:)]) {
        [self.delegate bannerCustomEventWillBeginAction:self];
    }
    if ([self.delegate respondsToSelector:@selector(bannerCustomEventDidFinishAction:)]) {
        [self.delegate bannerCustomEventDidFinishAction:self];
    }
}

- (void)dealloc {
    self.yumiBanner = nil;
}

@end
