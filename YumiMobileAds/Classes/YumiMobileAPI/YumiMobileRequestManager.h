//
//  YumiMobileRequestManager.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import <Foundation/Foundation.h>
#import "YumiMobileResponseModel.h"
#import "YumiMobileRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YumiMobileRequestManager : NSObject
+ (instancetype)sharedManager;
- (void)requestAdWithRequestModel:(YumiMobileRequestModel *)model
                          success:(void (^)(YumiMobileResponseModel *ad))success
                          failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
