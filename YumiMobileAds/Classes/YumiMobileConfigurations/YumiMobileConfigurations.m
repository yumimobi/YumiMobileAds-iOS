//
//  YumiMobileConfigurations.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/12.
//

#import "YumiMobileConfigurations.h"

@implementation YumiMobileConfigurations
+ (instancetype)sharedYumiMobileConfigurations {
    static YumiMobileConfigurations *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    
    self.gdpr = 0;
    self.consent = true;
    self.coppa = 1;
    return self;
}
@end
