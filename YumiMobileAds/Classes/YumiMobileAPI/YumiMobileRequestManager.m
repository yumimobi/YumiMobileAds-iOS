//
//  YumiMobileRequestManager.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import "YumiMobileRequestManager.h"
#import "YMNetworking.h"
#import "YumiMobileRequestModel.h"
#import "YumiMobileResponseModel.h"
#import "YMModel.h"

@interface YumiMobileRequestManager ()
@property (nonatomic) YMHTTPSessionManager *client;
@property (nonatomic) NSString *ua;

@end

@implementation YumiMobileRequestManager
+ (instancetype)sharedManager {
    static YumiMobileRequestManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[YumiMobileRequestManager alloc] init];
    });
    
    return sharedManager;
}

- (YMHTTPSessionManager *)client {
    if (!_client) {
        _client = [YMHTTPSessionManager manager];
        _client.requestSerializer.timeoutInterval = 15;
        _client.responseSerializer = [YMJSONResponseSerializer serializer];
    }
    
    [_client.requestSerializer setValue:self.ua forHTTPHeaderField:@"User-Agent"];
    return _client;
}

- (void)requestAdWithRequestModel:(YumiMobileRequestModel *)model
                               ua:(NSString *)ua
                          success:(void (^)(YumiMobileResponseModel *ad))success
                          failure:(void (^)(NSError *error))failure {
    self.ua = ua;
    YMHTTPSessionManager *client = self.client;
    
    NSString *parameters = [model ym_modelToJSONObject];
    
}
@end
