//
//  YumiMobileTools.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/6.
//

#import "YumiMobileTools.h"
#import "NSObject+YMModel.h"
#import "YMHTTPSessionManager.h"
#import "YMNetworkReachabilityManager.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>
#include <sys/sysctl.h>

#define IPURL @"https://corn.yumimobi.com/api/getip.php"

@interface YumiMobileTools ()
@property (nonatomic, assign) int screenScale;
@property (nonatomic, assign) int dpi;
@property (nonatomic) NSString *userAgent;
@property (nonatomic) NSString *macAddress;
@property (nonatomic) NSString *model;
@property (nonatomic) NSString *idfa;
@property (nonatomic) NSString *idfv;
@property (nonatomic) NSString *plmn;
@property (nonatomic) NSString *systemVersion;
@property (nonatomic) NSString *appVersion;
@property (nonatomic) NSString *openUDID;
@property (nonatomic) NSString *networkStatus;
@property (nonatomic) NSString *bundleID;
@property (nonatomic) NSString *appName;
@property (nonatomic) NSString *carrierName;
@property (nonatomic) NSString *mcc;
@property (nonatomic) NSString *mnc;
@property (nonatomic) NSString *ip;
@property (nonatomic) NSString *deviceName;
@property (nonatomic, assign) BOOL allowArbitraryLoads;
@property (nonatomic) NSString *uuid;

@property (nonatomic) CTTelephonyNetworkInfo *networkInfo;
@property (nonatomic) YMNetworkReachabilityManager *reachabilityManager;

@property (nonatomic) NSTimer *updateIPTimer;
@property (nonatomic) NSString *language;
@end

@implementation YumiMobileTools
+ (void)load {
    [self sharedTool];
}

+ (instancetype)sharedTool {
    static YumiMobileTools *sharedTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTool = [[self alloc] init];
    });
    return sharedTool;
}

- (instancetype)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [self startMonitoringNetworkReachabilityStatus];
    [self updateIP];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectZero];
        weakSelf.userAgent = [web stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    });
    return self;
}

- (void)startMonitoringNetworkReachabilityStatus {
    __weak typeof(self) weakSelf = self;
    
    self.reachabilityManager = [YMNetworkReachabilityManager manager];
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(YMNetworkReachabilityStatus status) {
        switch (status) {
            case YMNetworkReachabilityStatusReachableViaWiFi: {
                weakSelf.networkStatus = @"WIFI";
                break;
            }
                
            case YMNetworkReachabilityStatusReachableViaWWAN: {
                NSString *currentStatus = weakSelf.networkInfo.currentRadioAccessTechnology;
                NSDictionary *statuses = @{
                                           @"CTRadioAccessTechnologyGPRS" : @"2G",
                                           @"CTRadioAccessTechnologyEdge" : @"2G",
                                           @"CTRadioAccessTechnologyCDMA1x" : @"2G",
                                           @"CTRadioAccessTechnologyWCDMA" : @"3G",
                                           @"CTRadioAccessTechnologyHSDPA" : @"3G",
                                           @"CTRadioAccessTechnologyHSUPA" : @"3G",
                                           @"CTRadioAccessTechnologyCDMAEVDORev0" : @"3G",
                                           @"CTRadioAccessTechnologyCDMAEVDORevA" : @"3G",
                                           @"CTRadioAccessTechnologyCDMAEVDORevB" : @"3G",
                                           @"CTRadioAccessTechnologyeHRPD" : @"3G",
                                           @"CTRadioAccessTechnologyLTE" : @"4G"
                                           };
                weakSelf.networkStatus = [statuses objectForKey:currentStatus] ?: @"UNKNOWN";
                break;
            }
                
            default: {
                weakSelf.networkStatus = @"UNKNOWN";
                break;
            }
        }
    }];
    [self.reachabilityManager startMonitoring];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// NOTE: cannot get mac address starting from iOS 7
- (NSString *)macAddress {
    if (!_macAddress) {
        _macAddress = @"02:00:00:00:00:00";
    }
    
    return _macAddress;
}

- (NSString *)model {
    if (!_model) {
        int mib[2];
        size_t len;
        char *machine;
        mib[0] = CTL_HW;
        mib[1] = HW_MACHINE;
        sysctl(mib, 2, NULL, &len, NULL, 0);
        machine = malloc(len);
        sysctl(mib, 2, machine, &len, NULL, 0);
        _model = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding] ?: @"";
        free(machine);
    }
    
    return _model;
}

- (BOOL)isiPhone {
    return [self.model hasPrefix:@"iPhone"];
}

- (BOOL)isiPad {
    return [self.model hasPrefix:@"iPad"];
}

- (BOOL)isiPod {
    return [self.model hasPrefix:@"iPod"];
}

- (BOOL)isSimulator {
    return [self.model isEqualToString:@"i386"] || [self.model isEqualToString:@"x86_64"];
}

- (BOOL)isAdTrackingEnabled {
    return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

- (NSString *)idfa {
    if (!_idfa.length) {
        [self refreshIDFA];
    }
    
    return _idfa;
}

- (NSString *)idfv {
    if (!_idfv.length) {
        NSUUID *idfvUUID = [[UIDevice currentDevice] identifierForVendor];
        // NOTE:
        // According to https://developer.apple.com/reference/uikit/uidevice/1620059-identifierforvendor?language=objc
        // If the value is nil, wait and get the value again later. This happens, for example, after the device has been
        // restarted but before the user has unlocked the device.
        //
        // So we set empty string to idfv and it will be retrieved again
        _idfv = idfvUUID ? [idfvUUID UUIDString] : @"";
    }
    
    return _idfv;
}

- (CTTelephonyNetworkInfo *)networkInfo {
    if (!_networkInfo) {
        _networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    
    return _networkInfo;
}

- (NSString *)plmn {
    if (!_plmn.length) {
        _plmn = [self plmnFromCarrier:[self carrier]] ?: @"";
    }
    
    return _plmn;
}

- (BOOL)allowArbitraryLoads {
    if (!_allowArbitraryLoads) {
        _allowArbitraryLoads =
        [[[NSBundle mainBundle] infoDictionary][@"NSAppTransportSecurity"][@"NSAllowsArbitraryLoads"] boolValue];
    }
    return _allowArbitraryLoads;
}

- (NSString *)systemVersion {
    if (!_systemVersion.length) {
        _systemVersion = [UIDevice currentDevice].systemVersion ?: @"";
    }
    
    return _systemVersion;
}

- (NSString *)appVersion {
    if (!_appVersion.length) {
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: @"";
    }
    
    return _appVersion;
}

- (BOOL)isInterfaceOrientationPortrait {
    if ([[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        return isPortrait;
    } else {
        __block BOOL isPortrait;
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        });
        
        return isPortrait;
    }
}

- (int)screenScale {
    if (!_screenScale) {
        _screenScale = (int)floor([UIScreen mainScreen].scale);
    }
    
    return _screenScale;
}

- (int)dpi {
    
    if (!_dpi) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat pixel = 3.5;
        if (screenHeight == 480) { // 4
            pixel = 3.5;
        } else if (screenHeight == 568) { // 5
            pixel = 4;
        } else if (screenHeight == 667) { // 6
            pixel = 4.7;
        } else if (screenHeight == 736) { // 6p
            pixel = 5.5;
        }
        _dpi = ceil(sqrt(powf(screenWidth, 2) + powf(screenHeight, 2)) / pixel);
    }
    
    return _dpi;
}

- (NSString *)userAgent {
    return _userAgent ? _userAgent : @"";
}

// https://github.com/ylechelle/OpenUDID
// OpenUDID is deprecated 4 years ago, don't use
- (NSString *)openUDID {
    if (!_openUDID) {
        _openUDID = @""; // set it to empty , suggestions from the server
    }
    
    return _openUDID;
}

- (NSString *)uuid {
    return [[NSUUID UUID] UUIDString];
}

- (NSString *)preferredLanguage {
    return [[NSLocale preferredLanguages] firstObject] ?: @"";
}

- (NSString *)networkStatus {
    if (!_networkStatus) {
        _networkStatus = @"UNKNOW";
    }
    
    return _networkStatus;
}

- (NSString *)bundleID {
    if (!_bundleID.length) {
        _bundleID = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"] ?: @"";
    }
    
    return _bundleID;
}

- (NSString *)appName {
    if (!_appName.length) {
        _appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
        if (!_appName) {
            _appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"] ?: @"";
        }
    }
    
    return _appName;
}

- (NSString *)carrierName {
    if (!_carrierName.length) {
        _carrierName = [self carrier].carrierName ?: @"";
    }
    
    return _carrierName;
}

- (NSString *)mcc {
    if (!_mcc.length) {
        _mcc = [[self carrier] mobileCountryCode] ?: @"";
    }
    
    return _mcc;
}

- (NSString *)mnc {
    if (!_mnc.length) {
        _mnc = [[self carrier] mobileNetworkCode] ?: @"";
    }
    
    return _mnc;
}

- (CTCarrier *)carrier {
    return [self.networkInfo subscriberCellularProvider];
}

- (NSBundle *)resourcesBundleWithBundleName:(NSString *)bundleName {
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [selfBundle URLForResource:bundleName withExtension:@"bundle"];
    return [NSBundle bundleWithURL:bundleURL];
}

- (NSString *)ip {
    return _ip.length ? _ip : @"127.0.0.1";
}

- (NSString *)deviceName {
    if (!_deviceName) {
        _deviceName = [[UIDevice currentDevice] name];
    }
    
    return _deviceName;
}

- (void)updateIP {
    YMHTTPSessionManager *manager = [YMHTTPSessionManager manager];
    manager.requestSerializer = [YMJSONRequestSerializer new];
    manager.responseSerializer = [YMJSONResponseSerializer new];
    manager.responseSerializer.acceptableContentTypes = nil;
    
    __weak typeof(self) weakSelf = self;
    
    [manager GET:IPURL
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
             weakSelf.ip = responseObject[@"IP"];
         }
         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [weakSelf updateIP];
                            });
         }];
}

- (void)setUpdateIPInterval:(NSTimeInterval)interval {
    interval = MAX(30, interval);
    
    [self.updateIPTimer invalidate];
    self.updateIPTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self
                                                        selector:@selector(updateIP)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (NSString *)fetchItunesIdWith:(NSString *)tempString {
    NSArray *stringArray = [tempString componentsSeparatedByString:@"/"];
    __block NSString *itunesID = @"";
    [stringArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj hasPrefix:@"id"]) {
            obj = [obj substringFromIndex:2];
            if ([obj rangeOfString:@"?"].location != NSNotFound) {
                NSArray *tempArray = [obj componentsSeparatedByString:@"?"];
                obj = tempArray.firstObject;
            }
            if ([obj rangeOfString:@"&"].location != NSNotFound) {
                NSArray *tempArray = [obj componentsSeparatedByString:@"&"];
                obj = tempArray.firstObject;
            }
        }
        itunesID = obj;
    }];
    return itunesID;
}

- (void)openBySystemMethod:(NSURL *)openUrl {
    if (!openUrl) {
        return;
    }
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:openUrl options:@{} completionHandler:nil];
    }else {
        [[UIApplication sharedApplication] openURL:openUrl];
    }
}

#pragma mark - Notifications
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self refreshIDFA];
}

#pragma mark - Helper methods
- (NSString *)plmnFromCarrier:(CTCarrier *)carrier {
    NSString *mnc = [carrier mobileNetworkCode];
    NSString *mcc = [carrier mobileCountryCode];
    return [NSString stringWithFormat:@"%@%@", mcc ?: @"", mnc ?: @""];
}

- (void)refreshIDFA {
    NSUUID *uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    self.idfa = uuid ? [uuid UUIDString] : @"";
}

- (BOOL)isiPhoneX {
    // iPhone X
    if (!self.isInterfaceOrientationPortrait) {
        return kSCREEN_WIDTH == kIPHONEXHEIGHT && kSCREEN_HEIGHT == kIPHONEXWIDTH;
    }
    return kSCREEN_WIDTH == kIPHONEXWIDTH && kSCREEN_HEIGHT == kIPHONEXHEIGHT;
}

- (BOOL)isiPhoneXR {
    if (!self.isInterfaceOrientationPortrait) {
        return kSCREEN_WIDTH == kIPHONEXRHEIGHT && kSCREEN_HEIGHT == kIPHONEXRWIDTH;
    }
    return kSCREEN_WIDTH == kIPHONEXRWIDTH && kSCREEN_HEIGHT == kIPHONEXRHEIGHT;
}

- (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (NSString *)language {
    if (!_language.length) {
        _language = [[NSLocale preferredLanguages] firstObject];
    }
    
    return _language;
}
- (BOOL)iSSimplifiedChinese {
    
    return [self.language hasPrefix:@"zh-Hans"];
}
@end
