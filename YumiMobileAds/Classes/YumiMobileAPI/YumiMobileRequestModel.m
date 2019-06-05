//
//  YumiMobileRequestModel.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import "YumiMobileRequestModel.h"
@interface YumiMobileRequestModel ()

@end

@implementation YumiMobileRequestModel
- (instancetype)initRequestModelWithSSPToken:(NSString *)sspToken
                                       appID:(NSString *)appID
                                 placementID:(NSString *)placementID
                                      adType:(YumiMobileAdType)adType
                                      adSize:(CGSize)adSize
                           gdprConsentStatus:(NSString *)consentStatus {
    self = [super init];
    
    return self;
}

@end
