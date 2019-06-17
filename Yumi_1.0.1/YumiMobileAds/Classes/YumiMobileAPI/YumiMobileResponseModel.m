//
//  YumiMobileResponseModel.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import "YumiMobileResponseModel.h"
#import "YMModel.h"

@implementation YumiMobileAdsModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"html" : @"html_snippet",
             @"imageUrl" : @"image_url",
             @"targetUrl" : @"target_url",
             @"materailType" : @"inventory_type",
             @"clickArray" : @"click_trackers",
             @"impressionArray" : @"imp_trackers",
             @"closeArray" : @"close_trackers",
             @"adW" : @"w",
             @"adH" : @"h",
             @"logoUrl" : @"logo_url"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    return YES;
}

- (NSString *)description {
    return [self ym_modelDescription];
}
@end

@implementation YumiMobileResponseModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"ads" : [YumiMobileAdsModel class]};
}

- (NSString *)description {
    return [self ym_modelDescription];
}

@end
