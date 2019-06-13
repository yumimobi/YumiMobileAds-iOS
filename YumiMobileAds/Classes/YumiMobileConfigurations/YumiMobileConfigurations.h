//
//  YumiMobileConfigurations.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMobileConfigurations : NSObject
// Indicates the GDPR requirement of the user. If it's 1, the user's subject to the GDPR laws.
// Default is 0.
@property (nonatomic, assign) int gdpr;
// Your user's consent string. In this case, the user has given consent to store and process personal information.
// Default is true.
@property (nonatomic, assign) BOOL consent;
// Indicates the coppa requirement of the user. If it's 1, the user's subject to the coppa laws.
// Default is 1.
@property (nonatomic, assign) int coppa;

+ (instancetype)sharedYumiMobileConfigurations;

@end

NS_ASSUME_NONNULL_END
