//
//  YumiMobileResponseModel.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import "YumiMobileResponseModel.h"
#import "YMModel.h"

@implementation YumiMobileAds
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"html" : @"html_snippet",
             @"imageUrl" : @"image_url",
             @"targetUrl" : @"target_url",
             @"materailType" : @"inventory_type",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.clickArray = dic[@"click_trackers"];
    self.impressionArray = dic[@"imp_trackers"];
    self.closeArray = dic[@"close_trackers"];
    return YES;
}

@end

@implementation YumiMobileResponseModel
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.ads = dic[@"ads"][0];
    return YES;
}

- (NSString *)description {
    return [self ym_modelDescription];
}

@end
