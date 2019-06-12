//
//  YumiMobileBanner.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import <Foundation/Foundation.h>
#import "YumiMobileConstants.h"

NS_ASSUME_NONNULL_BEGIN
@class YumiMobileBanner;
@protocol YumiMobileBannerDelegate <NSObject>
@optional
- (void)yumiMobileBannerDidReceiveAd:(YumiMobileBanner *)bannerView;
- (void)yumiMobileBanner:(YumiMobileBanner *)bannerView didFailToReceivAdWithError:(NSError *)error;
- (void)yumimobileBannerDidClickAd:(YumiMobileBanner *)bannerView;
@end

@interface YumiMobileBanner : UIView
/// Default is YumiMobileGDPRConsentStatusUnknown.
@property (nonatomic, assign) YumiMobileGDPRConsentStatus gdprConsentStatus;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/// Initializes and returns a banner view relative to the banner's superview.
- (instancetype)initWithSSPToken:(NSString *)sspToken
                           appID:(NSString *)appID
                     placementID:(NSString *)placementID
                      bannerSize:(YumiMobileBannerSize)bannerSize
                        delegate:(id<YumiMobileBannerDelegate>)delegate
              rootViewController:(UIViewController *)rootViewController;

- (void)requestAd;
@end

NS_ASSUME_NONNULL_END
