//
//  YumiMobileTools.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/6.
//

#import <Foundation/Foundation.h>

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// iPhone X / XS
#define kIPHONEXHEIGHT 812.0
#define kIPHONEXHOMEINDICATOR 34.0
#define kIPHONEXSTATUSBAR 44.0
#define kIPHONEXWIDTH 375.0
// iPhone XR / XS MAX
#define kIPHONEXRHEIGHT 896.0
#define kIPHONEXRHOMEINDICATOR 34.0
#define kIPHONEXRSTATUSBAR 44.0
#define kIPHONEXRWIDTH 414.0
// iPhone X / XS / XR / XS MAX Landscape
#define kIPHONEXLANDSCAPEHOMEINDICATOR 21

NS_ASSUME_NONNULL_BEGIN
@interface YumiMobileTools : NSObject
@property (nonatomic, assign, readonly) int screenScale;
@property (nonatomic, assign, readonly) int dpi;
@property (nonatomic, readonly) NSString *userAgent;
@property (nonatomic, readonly) NSString *macAddress;
@property (nonatomic, readonly) NSString *model;
@property (nonatomic, readonly) NSString *idfa;
@property (nonatomic, readonly) NSString *idfv;
@property (nonatomic, readonly) NSString *plmn;
@property (nonatomic, readonly) NSString *systemVersion;
@property (nonatomic, readonly) NSString *appVersion;
@property (nonatomic, readonly) NSString *openUDID;
@property (nonatomic, readonly) NSString *preferredLanguage;
@property (nonatomic, readonly) NSString *networkStatus;
@property (nonatomic, readonly) NSString *bundleID;
@property (nonatomic, readonly) NSString *appName;
@property (nonatomic, readonly) NSString *carrierName;
@property (nonatomic, readonly) NSString *mcc;
@property (nonatomic, readonly) NSString *mnc;
@property (nonatomic, readonly) NSString *ip;
@property (nonatomic, readonly) NSString *deviceName;
@property (nonatomic, assign, readonly) BOOL allowArbitraryLoads;
@property (nonatomic, readonly) NSString *uuid;

+ (instancetype _Nonnull)sharedTool;

- (BOOL)isiPhone;
- (BOOL)isiPad;
- (BOOL)isiPod;
- (BOOL)isSimulator;
- (BOOL)isAdTrackingEnabled;
- (BOOL)isInterfaceOrientationPortrait;
- (NSBundle *_Nullable)resourcesBundleWithBundleName:(NSString *)bundleName;
- (void)setUpdateIPInterval:(NSTimeInterval)interval;
- (NSString *)fetchItunesIdWith:(NSString *)tempString;
- (void)openBySystemMethod:(NSURL *)openUrl;
- (BOOL)isiPhoneX;
- (BOOL)isiPhoneXR;
- (UIViewController *)topMostController;
- (BOOL)iSSimplifiedChinese;
@end
NS_ASSUME_NONNULL_END
