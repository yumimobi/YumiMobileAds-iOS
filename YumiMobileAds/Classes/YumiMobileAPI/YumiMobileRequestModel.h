//
//  YumiMobileRequestModel.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kYumiMobileAdBanner = 0,
    kYumiMobileAdInterstitial = 1,
    kYumiMobileAdVideo = 4,
} YumiMobileAdType;

NS_ASSUME_NONNULL_BEGIN

@interface YumiMobileRequestModel : NSObject
- (instancetype)initRequestModelWithSSPToken:(NSString *)sspToken
                                       appID:(NSString *)appID
                                 placementID:(NSString *)placementID
                                      adType:(YumiMobileAdType)adType
                                      adSize:(CGSize)adSize;

@end

NS_ASSUME_NONNULL_END
