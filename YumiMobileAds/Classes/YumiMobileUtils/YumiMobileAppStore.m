//
//  YumiMobileAppStore.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/11.
//

#import "YumiMobileAppStore.h"
#import "YumiMobileTools.h"
#import "YumiMobileConstants.h"
#import <StoreKit/StoreKit.h>

@interface YumiMobileAppStore ()
@property (nonatomic) NSString *iTunesLink;
@property (nonatomic, assign) BOOL appStoreLoaded;
@property (nonatomic) SKStoreProductViewController *appStore;
@end

@implementation YumiMobileAppStore
- (instancetype)initWithItunesLink:(NSString *)linkUrl {
    self = [super init];
    self.iTunesLink = linkUrl;
    [self preloadStoreProductView];
    
    return self;
}

- (void)present {
    if (self.appStoreLoaded) {
        [[[YumiMobileTools sharedTool] topMostController] presentViewController:self.appStore animated:YES completion:nil];
    } else {
        [self openAppStore:self.iTunesLink];
    }
}

- (void)preloadStoreProductView {
    // 通过linkUrl 获取iTunesID
    NSString *iTunesID = [[YumiMobileTools sharedTool] fetchItunesIdWith:self.iTunesLink];
    // 使用内置appstore预缓存功能在 iOS11.0 ~ 11.2.x的系统上会出现白屏现象，打开App Store链接
    // 如果 itunesID == nil, 就直接返回
    NSString *osVersion = [YumiMobileTools sharedTool].systemVersion;
    if (!iTunesID || [osVersion hasPrefix:@"11.0"] || [osVersion hasPrefix:@"11.1"] || [osVersion hasPrefix:@"11.2"]) {
        return;
    }
    self.appStore = [[SKStoreProductViewController alloc] init];
    self.appStore.delegate = self;
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier : iTunesID};
    __weak typeof(self) weakSelf = self;
    self.appStoreLoaded = NO;
    [self.appStore
     loadProductWithParameters:parameters
     completionBlock:^(BOOL result, NSError *_Nullable error) {
         if (error) {
             return;
         }
         weakSelf.appStoreLoaded = result;
     }];
}

- (void)openAppStore:(NSString *)iTunesLink {
    // iTunesLink 为空 就直接返回
    if (iTunesLink.length == 0) {
        return;
    }
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:NO completion:nil];
    // 11.3 以上第二次还是打开内置浏览器，11.0以下和12.0第二次就跳转App Store
    NSString *osVersion = [YumiMobileTools sharedTool].systemVersion;
    if (SYSTEM_VERSION_LESS_THAN(@"11.0") || [osVersion isEqualToString:@"12.0"]) {
        self.appStoreLoaded = NO;
    }
}
@end
