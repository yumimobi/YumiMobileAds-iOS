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
@property (nonatomic) YMHTTPSessionManager *reportClient;

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

- (YMHTTPSessionManager *)reportClient {
    if (!_reportClient) {
        _reportClient = [YMHTTPSessionManager manager];
        _reportClient.requestSerializer.timeoutInterval = 15;
        _reportClient.responseSerializer = [YMHTTPResponseSerializer serializer];
    }
    
    [_reportClient.requestSerializer setValue:[YumiMobileTools sharedTool].userAgent forHTTPHeaderField:@"User-Agent"];
    return _reportClient;
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
                        if (responseModel.ads.count && responseModel.result == 0) {
                            success(responseModel);
                            return;
                        } else {
                            NSError *error = [[NSError alloc] initWithDomain:YumiMobileErrorDomin code:204 userInfo:@{@"NSLocalizedDescriptionKey":responseModel.msg}];
                            failure(error);
                        }
                        
                    }] resume];
}

- (void)sendTrackerUrl:(NSArray<NSString *> *)trackerUrls
            clickPoint:(CGPoint)clickPoint {
    CGFloat x = -999;
    CGFloat y = -999;
    if (clickPoint.x || clickPoint.y) {
        x = clickPoint.x;
        y = clickPoint.y;
    }
    NSString *timeStamp = [[YumiMobileTools sharedTool] timestamp];
    NSDictionary *replaceStr = @{
                                 @"YUMI_ADSERVICE_CLICK_DOWN_X" : @(x),
                                 @"YUMI_ADSERVICE_CLICK_DOWN_Y" : @(y),
                                 @"YUMI_ADSERVICE_CLICK_UP_X" : @(x),
                                 @"YUMI_ADSERVICE_CLICK_UP_Y" : @(y),
                                 @"YUMI_ADSERVICE_UNIX_ORIGIN_TIME" : timeStamp,
                                 };
    for (int i = 0; i < trackerUrls.count; i++) {
        __block NSString *serUrl = [trackerUrls objectAtIndex:i];
        if (![serUrl isKindOfClass:[NSNull class]] && serUrl) {
            [replaceStr enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
                serUrl =
                [serUrl stringByReplacingOccurrencesOfString:key withString:[NSString stringWithFormat:@"%@", obj]];
            }];
            [self sendToThirdParty:serUrl withMaxRetries:5 attempts:0];
        }
    }
}

- (void)sendToThirdParty:(NSString *)trackerUrl
          withMaxRetries:(int)maxRetries
                attempts:(int)attempts {
    __weak typeof(self) weakSelf = self;
    void (^retryIfNeeded)(NSError *) = ^(NSError *error) {
        if (attempts > maxRetries) {
            return;
        }
        dispatch_after(
                       dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 1 << attempts)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                           [weakSelf sendToThirdParty:trackerUrl withMaxRetries:maxRetries attempts:attempts + 1];
                       });
    };
    if (![NSURL URLWithString:trackerUrl]) {
        return;
    }
    [self.reportClient GET:trackerUrl
                parameters:nil
                  progress:nil
                   success:nil
                   failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                       retryIfNeeded(error);
                   }];
}
@end
