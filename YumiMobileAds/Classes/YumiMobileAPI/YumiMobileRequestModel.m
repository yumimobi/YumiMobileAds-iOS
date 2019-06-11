//
//  YumiMobileRequestModel.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import "YumiMobileRequestModel.h"
#import "YumiMobileTools.h"

@interface YumiMobileRequestModel ()
@property (nonatomic) NSString *protocolVersion;
@property (nonatomic) NSString *sspToken;
@property (nonatomic) NSString *appID;
@property (nonatomic) NSString *appName;
@property (nonatomic) NSString *bundleID;
@property (nonatomic) NSString *model;
@property (nonatomic) NSString *make;
@property (nonatomic) NSString *connectionType;
@property (nonatomic, assign) int carrier;
@property (nonatomic, assign) int orientation;
@property (nonatomic) NSString *idfa;
@property (nonatomic) NSString *osType;
@property (nonatomic) NSString *osVersion;
@property (nonatomic, assign) int screenW;
@property (nonatomic, assign) int screenH;
@property (nonatomic) NSArray *ads;
// 创意类型
// 1.图片，2.图文，4.html,5.文本
@property (nonatomic) NSArray *inventoryTypes;

@end

@implementation YumiMobileRequestModel
- (instancetype)initRequestModelWithSSPToken:(NSString *)sspToken
                                       appID:(NSString *)appID
                                 placementID:(NSString *)placementID
                                      adType:(YumiMobileAdType)adType
                                      adSize:(CGSize)adSize
                           gdprConsentStatus:(NSString *)consentStatus {
    self = [super init];
    YumiMobileTools *tool = [YumiMobileTools sharedTool];
    
    self.protocolVersion = @"1.1";
    self.sspToken = sspToken;
    self.appID = appID;
    self.appName = tool.appName;
    self.bundleID = tool.bundleID;
    self.model = tool.model;
    self.make = @"Apple";
    self.connectionType = [@{@"2G" : @"2g", @"3G" : @"3g", @"4G" : @"4g", @"WIFI" : @"wifi",@"UNKNOW":@"cell_unknown"} objectForKey:tool.networkStatus] ?: @"wifi";
    self.carrier = 1;
    self.orientation = tool.isInterfaceOrientationPortrait ? 1 : 3;
    self.idfa = tool.idfa;
    self.osType = @"ios";
    self.osVersion = tool.systemVersion;
    self.screenW = [UIScreen mainScreen].bounds.size.width;
    self.screenH = [UIScreen mainScreen].bounds.size.height;
    self.ads = @[@{@"type":@(adType),@"place_id":placementID,@"w":@(adSize.width),@"h":@(adSize.height),@"inventory_types":@[@1,@2,@4,@5]}];
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"protocolVersion" : @"ver",
             @"sspToken" : @"ssp_token",
             @"appID" : @"app.id",
             @"appName" : @"app.name",
             @"bundleID" : @"app.bundle",
             @"model" : @"device.model",
             @"make" : @"device.make",
             @"connectionType" : @"device.connection_type",
             @"carrier" : @"device.carrier",
             @"orientation" : @"device.orientation",
             @"idfa" : @"device.ios_adid",
             @"osType" : @"device.os_type",
             @"osVersion" : @"device.os_version",
             @"screenW" : @"device.screen.w",
             @"screenH" : @"device.screen.h",
             };
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    return YES;
}

@end
