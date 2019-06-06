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
#import "YumiMobileTools.h"
#import "YumiMobileConstants.h"

#define yumiMobileRequestURL @"https://bid.adx.yumimobi.com/adx"

@interface YumiMobileRequestManager ()
@property (nonatomic) YMURLSessionManager *client;

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

- (YMURLSessionManager *)client {
    if (!_client) {
        _client = [[YMURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _client;
}

- (void)requestAdWithRequestModel:(YumiMobileRequestModel *)model
                          success:(void (^)(YumiMobileResponseModel *ad))success
                          failure:(void (^)(NSError *error))failure {
    NSMutableURLRequest *request = [[YMHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:yumiMobileRequestURL parameters:nil error:nil];
    [request setValue:[YumiMobileTools sharedTool].userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:[YumiMobileTools sharedTool].ip forHTTPHeaderField:@"X-Forwarded-For"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[model ym_modelToJSONObject] options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setHTTPBody:jsonData];
    YMHTTPResponseSerializer *responseSerializer = [YMJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes =
    [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
    self.client.responseSerializer = responseSerializer;
    
    [[self.client dataTaskWithRequest:request
                       uploadProgress:nil
                     downloadProgress:nil
                    completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        if (error || !responseObject) {
                            failure(error);
                            return;
                        }
                        YumiMobileResponseModel *responseModel = [YumiMobileResponseModel ym_modelWithJSON:responseObject];
                        if (responseModel.ads && responseModel.result == 0) {
                            success(responseModel);
                            return;
                        } else {
                            NSError *error = [[NSError alloc] initWithDomain:YumiMobileErrorDomin code:204 userInfo:@{@"NSLocalizedDescriptionKey":responseModel.msg}];
                            failure(error);
                        }
                        
                    }] resume];
}
@end
