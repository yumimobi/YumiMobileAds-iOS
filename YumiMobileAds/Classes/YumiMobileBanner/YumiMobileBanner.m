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
#import <WebKit/WebKit.h>

#define YumiMobileImageUrlConstant @"##IMG-SRC-URL##"
#define YumiMobileTitleConstant @"##TITLE##"
#define YumiMobiletargetUrlConstant @"##A-HREF-URL##"
#define YumiMobileDescConstant @"##DESC##"
#define YumiMobileLogoUrlConstant @"##YUMI_LOGO_URL##"

@interface YumiMobileBanner ()<WKNavigationDelegate>
@property (nonatomic) NSString *sspToken;
@property (nonatomic) NSString *appID;
@property (nonatomic) NSString *placementID;
@property (nonatomic, assign) YumiMobileBannerSize bannerSize;
@property (nonatomic, weak) id<YumiMobileBannerDelegate> delegate;
@property (nonatomic) UIViewController *rootViewController;
@property (nonatomic, assign) CGSize adSize;

@property (nonatomic) WKWebView *web;
@property (nonatomic) YumiMobileAdsModel *ad;
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
    [self addSubview:self.web];
    
    return self;
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
    // html
    if (self.ad.materailType == 4) {
        finalHtml = self.ad.html;
    }
    [self.web loadHTMLString:finalHtml baseURL:nil];
}

- (void)errorHandler:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yumiMobileBanner:didFailToReceivAdWithError:)]) {
        [self.delegate yumiMobileBanner:self didFailToReceivAdWithError:error];
    }
}

#pragma mark - WKNavigationDelegate
/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
}

/*! @abstract Decides whether to allow or cancel a navigation after its
 response is known.
 @param webView The web view invoking the delegate method.
 @param navigationResponse Descriptive information about the navigation
 response.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
 @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

/*! @abstract Invoked when the web view needs to respond to an authentication challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to the challenge. The
 disposition argument is one of the constants of the enumerated type
 NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
 the credential argument is the credential to use, or nil to indicate continuing without a
 credential.
 @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
}

/*! @abstract Invoked when the web view's web content process is terminated.
 @param webView The web view whose underlying web content process was terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    
}
@end
