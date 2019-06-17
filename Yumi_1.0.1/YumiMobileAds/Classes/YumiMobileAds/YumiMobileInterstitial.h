//
//  YumiMobileInterstitial.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YumiMobileConstants.h"

NS_ASSUME_NONNULL_BEGIN
@class YumiMobileInterstitial;
@protocol YumiMobileInterstitialDelegate <NSObject>
@optional
- (void)yumiMobileInterstitialDidReceiveAd:(YumiMobileInterstitial *)interstitial;
- (void)yumiMobileInterstitial:(YumiMobileInterstitial *)interstitial didFailToReceivAdWithError:(NSError *)error;
- (void)yumiMobileInterstitialWillAppear:(YumiMobileInterstitial *)interstitial;
- (void)yumiMobileInterstitialWillDisappear:(YumiMobileInterstitial *)interstitial;
- (void)yumimobileInterstitialDidClickAd:(YumiMobileInterstitial *)interstitial;

@end

@interface YumiMobileInterstitial : UIViewController
/// Default is YumiMobileGDPRConsentStatusUnknown.
@property (nonatomic, assign) YumiMobileGDPRConsentStatus gdprConsentStatus;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// Initializes and returns a interstitial viewcontroller.
- (instancetype)initWithSSPToken:(NSString *)sspToken
                           appID:(NSString *)appID
                     placementID:(NSString *)placementID
                      interstitialSize:(YumiMobileInterstitialSize)interstitialSize
                        delegate:(id<YumiMobileInterstitialDelegate>)delegate;
- (void)requestAd;
- (void)presentFromRootViewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
