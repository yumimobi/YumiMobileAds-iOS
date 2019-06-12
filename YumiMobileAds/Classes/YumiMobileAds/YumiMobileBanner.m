//
//  YumiMobileBanner.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import "YumiMobileBanner.h"
#import "YumiMobileRequestManager.h"
#import "YumiMobileResponseModel.h"
#import "YumiMobileTools.h"
#import "YumiMobileBannerAppStore.h"
#import <WebKit/WebKit.h>

#define YumiMobileImageUrlConstant @"##IMG-SRC-URL##"
#define YumiMobileTitleConstant @"##TITLE##"
#define YumiMobiletargetUrlConstant @"##A-HREF-URL##"
#define YumiMobileDescConstant @"##DESC##"
#define YumiMobileLogoUrlConstant @"##YUMI_LOGO_URL##"

@interface YumiMobileBanner ()<WKNavigationDelegate,UIGestureRecognizerDelegate>
@property (nonatomic) NSString *sspToken;
@property (nonatomic) NSString *appID;
@property (nonatomic) NSString *placementID;
@property (nonatomic, assign) YumiMobileBannerSize bannerSize;
@property (nonatomic, weak) id<YumiMobileBannerDelegate> delegate;
@property (nonatomic) UIViewController *rootViewController;
@property (nonatomic, assign) CGSize adSize;

@property (nonatomic) WKWebView *web;
@property (nonatomic) YumiMobileAdsModel *ad;
@property (nonatomic) CGPoint point;
@end

@implementation YumiMobileBanner
- (instancetype)initWithSSPToken:(NSString *)sspToken
                           appID:(NSString *)appID
                     placementID:(NSString *)placementID
                      bannerSize:(YumiMobileBannerSize)bannerSize
                        delegate:(id<YumiMobileBannerDelegate>)delegate
              rootViewController:(UIViewController *)rootViewController {
    self = [super init];
    
    self.gdprConsentStatus = YumiMobileGDPRConsentStatusUnknown;
    self.sspToken = sspToken ?: @"";
    self.appID = appID ?: @"";
    self.placementID = placementID ?: @"";
    self.delegate = delegate;
    self.rootViewController = rootViewController;
    // adSize
    self.adSize = CGSizeMake(320, 50);
    if (bannerSize == kYumiMobileAdViewBanner728x90) {
        self.adSize = CGSizeMake(728, 90);
    }
    self.frame = CGRectMake(0, 0, self.adSize.width, self.adSize.height);
    self.backgroundColor = [UIColor blackColor];
    self.web = [[WKWebView alloc] initWithFrame:self.frame];
    self.web.navigationDelegate = self;
    self.web.scrollView.scrollEnabled = NO;
    if (@available(iOS 11, *)) {
        [self.web.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    // add click event
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick:)];
    tapG.delegate = self;
    self.web.userInteractionEnabled = YES;
    [self.web addGestureRecognizer:tapG];
    [self addSubview:self.web];
    
    return self;
}

- (void)tapGestureClick:(UITapGestureRecognizer *)grconizer {
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint p = [touch locationInView:self.web];
    self.point = p;
    return YES;
}

- (void)requestAd {
    NSString *gdprConsentStatus = @"";
    if (self.gdprConsentStatus == YumiMobileGDPRConsentStatusPersonalized) {
        gdprConsentStatus = @"yes";
    }
    if (self.gdprConsentStatus == YumiMobileGDPRConsentStatusNonPersonalized) {
        gdprConsentStatus = @"no";
    }
    // request model
    YumiMobileRequestModel *requestModel =
    [[YumiMobileRequestModel alloc]
     initRequestModelWithSSPToken:self.sspToken
                            appID:self.appID
                      placementID:self.placementID
                           adType:kYumiMobileAdBanner
                           adSize:self.adSize
                gdprConsentStatus:gdprConsentStatus];
    __weak __typeof(self)weakSelf = self;
    // request server
    [[YumiMobileRequestManager sharedManager]
     requestAdWithRequestModel:requestModel
                       success:^(YumiMobileResponseModel * _Nonnull ad) {
                           weakSelf.ad = ad.ads.firstObject;
                           [weakSelf setUpBannerMaterial];
                      }failure:^(NSError * _Nonnull error) {
                          [weakSelf errorHandler:error];
                      }];
}

- (void)setUpBannerMaterial {
    if (self.ad.targetUrl.length) {
        [[YumiMobileBannerAppStore sharedYumiMobileAppStore] setItunesLink:self.ad.targetUrl];
    }
    NSString *resourceName = @"";
    // image
    if (self.ad.materailType == 1) {
        resourceName = @"banner-3";
    }
    // image & text
    if (self.ad.materailType == 2) {
        resourceName = @"banner-1";
    }
    // text
    if (self.ad.materailType == 5) {
        resourceName = @"banner-2";
    }
    NSString *htmlPath = [[[YumiMobileTools sharedTool] resourcesBundleWithBundleName:@"YumiMobileAds"] pathForResource:resourceName ofType:@"html"];
    NSString *logoPath = [[[YumiMobileTools sharedTool] resourcesBundleWithBundleName:@"YumiMobileAds"] pathForResource:@"logo" ofType:@"html"];
    NSData *htmlData = [[NSData alloc] initWithContentsOfFile:htmlPath];
    NSData *logoData = [[NSData alloc] initWithContentsOfFile:logoPath];
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    // html
    if (self.ad.materailType == 4) {
        html = self.ad.html;
    }
    NSString *logo = [[NSString alloc] initWithData:logoData encoding:NSUTF8StringEncoding];
    NSString *finalHtml = [NSString stringWithFormat:@"%@%@",html,logo];
    // image
    if (finalHtml.length && [finalHtml rangeOfString:YumiMobileImageUrlConstant].location != NSNotFound && self.ad.imageUrl.length) {
        finalHtml = [finalHtml stringByReplacingOccurrencesOfString:YumiMobileImageUrlConstant withString:self.ad.imageUrl];
    }
    // title
    if (finalHtml.length && [finalHtml rangeOfString:YumiMobileTitleConstant].location != NSNotFound && self.ad.title.length) {
        finalHtml = [finalHtml stringByReplacingOccurrencesOfString:YumiMobileTitleConstant withString:self.ad.title];
    }
    // target url
    if (finalHtml.length && [finalHtml rangeOfString:YumiMobiletargetUrlConstant].location != NSNotFound && self.ad.targetUrl.length) {
        finalHtml = [finalHtml stringByReplacingOccurrencesOfString:YumiMobiletargetUrlConstant withString:self.ad.targetUrl];
    }
    // desc
    if (finalHtml.length && [finalHtml rangeOfString:YumiMobileDescConstant].location != NSNotFound && self.ad.desc.length) {
        finalHtml = [finalHtml stringByReplacingOccurrencesOfString:YumiMobileDescConstant withString:self.ad.desc];
    }
    // logo url
    if (finalHtml.length && [finalHtml rangeOfString:YumiMobiletargetUrlConstant].location != NSNotFound && self.ad.logoUrl.length) {
        finalHtml = [finalHtml stringByReplacingOccurrencesOfString:YumiMobiletargetUrlConstant withString:self.ad.logoUrl];
    }
    [self.web loadHTMLString:finalHtml baseURL:nil];
}

- (void)errorHandler:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yumiMobileBanner:didFailToReceivAdWithError:)]) {
        [self.delegate yumiMobileBanner:self didFailToReceivAdWithError:error];
    }
}

- (void)switchClickTypeWith:(NSURL *)url {
    // 1，2 浏览器
    // 6，8 App Store
    // 7 deeplink
    YumiMobileTools *tool = [YumiMobileTools sharedTool];
    if (self.ad.action == 1 || self.ad.action == 2) {
        [tool openBySystemMethod:url];
    }
    if (self.ad.action == 6 || self.ad.action == 8) {
        [[YumiMobileBannerAppStore sharedYumiMobileAppStore] present];
    }
    if (self.ad.action == 7) {
        [tool openBySystemMethod:url];
    }
    // report click
    [[YumiMobileRequestManager sharedManager] sendTrackerUrl:self.ad.clickArray clickPoint:self.point];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *targetUrl = [navigationAction.request.URL absoluteString];
    if (self.ad.targetUrl.length) {
        targetUrl = self.ad.targetUrl;
    }
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(yumimobileBannerDidClickAd:)]) {
            [self.delegate yumimobileBannerDidClickAd:self];
        }
        [self switchClickTypeWith:[NSURL URLWithString:targetUrl]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yumiMobileBannerDidReceiveAd:)]) {
        [self.delegate yumiMobileBannerDidReceiveAd:self];
    }
    [[YumiMobileRequestManager sharedManager] sendTrackerUrl:self.ad.impressionArray clickPoint:self.point];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self errorHandler:error];
}

@end
