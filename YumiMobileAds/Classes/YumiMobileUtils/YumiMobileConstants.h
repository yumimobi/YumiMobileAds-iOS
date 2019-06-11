//
//  YumiMobileConstants.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//
#import <Foundation/Foundation.h>

#ifndef YumiMobileConstants_h
#define YumiMobileConstants_h

#define YumiMobileErrorDomin @"Yumi_Mobile_Error_Domin_10010"
#define SYSTEM_VERSION_LESS_THAN(v)                                                                                    \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

typedef enum : NSUInteger {
    /// The user has granted consent for personalized ads.
    YumiMobileGDPRConsentStatusPersonalized,
    /// The user has granted consent for non-personalized ads.
    YumiMobileGDPRConsentStatusNonPersonalized,
    /// The user has neither granted nor declined consent for personalized or non-personalized ads.
    YumiMobileGDPRConsentStatusUnknown,
} YumiMobileGDPRConsentStatus;

/// Represents the fixed banner ad size
typedef NS_ENUM(NSUInteger, YumiMobileBannerSize) {
    /// iPhone and iPod Touch ad size. Typically 320x50.
    kYumiMobileAdViewBanner320x50 = 1 << 0,
    /// Leaderboard size for the iPad. Typically 728x90.
    kYumiMobileAdViewBanner728x90 = 1 << 1,
};

typedef enum : NSUInteger {
    /// Default is 300*250 in landscape,250*300 in portrait.
    kYumiMobileAdInterstitial300x250,
    /// Default is 600*500 in landscape,500*600 in portrait.
    kYumiMobileAdInterstitial600x500,
    /// Default is 960*640 in landscape,640*900 in portrait.
    kYumiMobileAdInterstitial960x640,
} YumiMobileInterstitialSize;

#endif /* YumiMobileConstants_h */
