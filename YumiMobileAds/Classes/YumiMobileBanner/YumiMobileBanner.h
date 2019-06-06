//
//  YumiMobileBanner.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import <Foundation/Foundation.h>
/// Represents the fixed banner ad size
typedef NS_ENUM(NSUInteger, YumiMobileBannerSize) {
    /// iPhone and iPod Touch ad size. Typically 320x50.
    kYumiMobileAdViewBanner320x50 = 1 << 0,
    /// Leaderboard size for the iPad. Typically 728x90.
    kYumiMobileAdViewBanner728x90 = 1 << 1,
};

typedef enum : NSUInteger {
    /// The user has granted consent for personalized ads.
    YumiMobileGDPRConsentStatusPersonalized,
    /// The user has granted consent for non-personalized ads.
    YumiMobileGDPRConsentStatusNonPersonalized,
    /// The user has neither granted nor declined consent for personalized or non-personalized ads.
    YumiMobileGDPRConsentStatusUnknown,
} YumiMobileGDPRConsentStatus;

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
