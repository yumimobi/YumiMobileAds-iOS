//
//  YumiMobileInterstitial.m
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/11.
//

#import "YumiMobileInterstitial.h"
#import "YumiMobileRequestManager.h"
#import "YumiMobileResponseModel.h"
#import "YumiMobileTools.h"
#import "YumiMobileAppStore.h"
#import <WebKit/WebKit.h>

#define YumiMobileImageUrlConstant @"##IMG-SRC-URL##"
#define YumiMobileTitleConstant @"##TITLE##"
#define YumiMobiletargetUrlConstant @"##A-HREF-URL##"
#define YumiMobileDescConstant @"##DESC##"
#define YumiMobileLogoUrlConstant @"##YUMI_LOGO_URL##"

@interface YumiMobileInterstitial ()<WKNavigationDelegate,UIGestureRecognizerDelegate>
@property (nonatomic) NSString *sspToken;
@property (nonatomic) NSString *appID;
@property (nonatomic) NSString *placementID;
@property (nonatomic, assign) YumiMobileBannerSize bannerSize;
@property (nonatomic, weak) id<YumiMobileInterstitialDelegate> delegate;
@property (nonatomic) UIViewController *rootViewController;
@property (nonatomic, assign) CGSize adSize;

@property (nonatomic) WKWebView *web;
@property (nonatomic) YumiMobileAdsModel *ad;
@property (nonatomic) CGPoint point;
@property (nonatomic) YumiMobileAppStore *appStore;
@end

@implementation YumiMobileInterstitial
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (instancetype)initWithSSPToken:(NSString *)sspToken
                           appID:(NSString *)appID
                     placementID:(NSString *)placementID
                interstitialSize:(YumiMobileInterstitialSize)interstitialSize
                        delegate:(id<YumiMobileInterstitialDelegate>)delegate {
    self = [super init];
    
    self.gdprConsentStatus = YumiMobileGDPRConsentStatusUnknown;
    self.sspToken = sspToken ?: @"";
    self.appID = appID ?: @"";
    self.placementID = placementID ?: @"";
    self.delegate = delegate;
    
    // adSize
    self.adSize = CGSizeMake(640, 960);
    if (![[YumiMobileTools sharedTool] isInterfaceOrientationPortrait]) {
        if (interstitialSize == kYumiMobileAdInterstitial300x250) {
            self.adSize = CGSizeMake(300, 250);
        }
        if (interstitialSize == kYumiMobileAdInterstitial600x500) {
            self.adSize = CGSizeMake(600, 500);
        }
        if (interstitialSize == kYumiMobileAdInterstitial960x640) {
            self.adSize = CGSizeMake(960, 640);
        }
    }
    if ([[YumiMobileTools sharedTool] isInterfaceOrientationPortrait]) {
        if (interstitialSize == kYumiMobileAdInterstitial300x250) {
            self.adSize = CGSizeMake(250, 300);
        }
        if (interstitialSize == kYumiMobileAdInterstitial600x500) {
            self.adSize = CGSizeMake(500, 600);
        }
    }
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
     adType:kYumiMobileAdInterstitial
     adSize:self.adSize];
    __weak __typeof(self)weakSelf = self;
    // request server
    [[YumiMobileRequestManager sharedManager]
     requestAdWithRequestModel:requestModel
     success:^(YumiMobileResponseModel * _Nonnull ad) {
         weakSelf.ad = ad.ads.firstObject;
         [weakSelf setUpUI];
         [weakSelf setUpInterstitialMaterial];
     }failure:^(NSError * _Nonnull error) {
         [weakSelf errorHandler:error];
     }];
}

- (void)setUpUI {
    // close button
    NSString *path = [[[YumiMobileTools sharedTool] resourcesBundleWithBundleName:@"YumiMobileAds"] pathForResource:@"yumi_close" ofType:@"png"];
    UIImage *closeImg = [[UIImage alloc] initWithContentsOfFile:path];
    CGFloat closeButtonW = [[YumiMobileTools sharedTool] adaptedValue6:30];
    CGFloat closebuttonH = [[YumiMobileTools sharedTool] adaptedValue6:30];
    CGFloat margin = [[YumiMobileTools sharedTool] adaptedValue6:10];
    CGFloat topMargin = [[YumiMobileTools sharedTool] adaptedValue6:10];
    CGFloat bottomMargin = [[YumiMobileTools sharedTool] adaptedValue6:10];
    if ([[YumiMobileTools sharedTool] isiPhoneX]) {
        topMargin = kIPHONEXSTATUSBAR;
        bottomMargin = kIPHONEXHOMEINDICATOR;
    }
    if ([[YumiMobileTools sharedTool] isiPhoneXR]) {
        topMargin = kIPHONEXRSTATUSBAR;
        bottomMargin = kIPHONEXRHOMEINDICATOR;
    }
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake((kSCREEN_WIDTH-closeButtonW-margin), topMargin, closeButtonW, closebuttonH)];
    [closeButton setBackgroundImage:closeImg forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeYumiMobileInterstitial) forControlEvents:UIControlEventTouchUpInside];
    // web
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat proportionWidth = 1.0f;
    CGFloat proportionHeight = 1.0f;
    if (self.ad.adW > kSCREEN_WIDTH) {
        proportionWidth = kSCREEN_WIDTH/self.ad.adW;
    }
    if (self.ad.adH > kSCREEN_HEIGHT) {
        proportionHeight = kSCREEN_HEIGHT/self.ad.adH;
    }
    CGFloat adW = self.ad.adW * proportionWidth;
    CGFloat adH = self.ad.adH * proportionHeight;
    self.web = [[WKWebView alloc] initWithFrame:CGRectMake((kSCREEN_WIDTH - adW)/2, (kSCREEN_HEIGHT - adH)/2, adW, adH)];
    if ([[YumiMobileTools sharedTool] isiPhoneX] || [[YumiMobileTools sharedTool] isiPhoneXR]) {
        self.web.frame = CGRectMake((kSCREEN_WIDTH-adW)/2, topMargin, adW, adH-topMargin-bottomMargin);
    }
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
    [self.view addSubview:self.web];
    [self.view addSubview:closeButton];
}

- (void)closeYumiMobileInterstitial {
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(yumiMobileInterstitialWillDisappear:)]) {
        [self.delegate yumiMobileInterstitialWillDisappear:self];
    }
    [[YumiMobileRequestManager sharedManager] sendTrackerUrl:self.ad.closeArray clickPoint:self.point];
}

- (void)setUpInterstitialMaterial {
    if (self.ad.targetUrl.length) {
        self.appStore = [[YumiMobileAppStore alloc] initWithItunesLink:self.ad.targetUrl];
    }
    NSString *resourceName = @"";
    // image
    if (self.ad.materailType == 1) {
        resourceName = @"interstitial-2";
    }
    // image & text
    if (self.ad.materailType == 2) {
        resourceName = @"interstitial-4";
    }
    // text
    if (self.ad.materailType == 5) {
        resourceName = @"interstitial-1";
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
    if (finalHtml.length && [finalHtml rangeOfString:YumiMobileLogoUrlConstant].location != NSNotFound && self.ad.logoUrl.length) {
        finalHtml = [finalHtml stringByReplacingOccurrencesOfString:YumiMobileLogoUrlConstant withString:self.ad.logoUrl];
    }
    [self.web loadHTMLString:finalHtml baseURL:nil];
}

- (void)tapGestureClick:(UITapGestureRecognizer *)grconizer {
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint p = [touch locationInView:self.web];
    self.point = p;
    return YES;
}

- (void)errorHandler:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yumiMobileInterstitial:didFailToReceivAdWithError:)]) {
        [self.delegate yumiMobileInterstitial:self didFailToReceivAdWithError:error];
    }
}

- (void)presentFromRootViewController:(UIViewController *)viewController {
    self.rootViewController = viewController;
    [viewController presentViewController:self animated:NO completion:nil];
    if ([self.delegate respondsToSelector:@selector(yumiMobileInterstitialWillAppear:)]) {
        [self.delegate yumiMobileInterstitialWillAppear:self];
    }
    [[YumiMobileRequestManager sharedManager] sendTrackerUrl:self.ad.impressionArray clickPoint:self.point];
}

- (void)switchClickTypeWith:(NSURL *)url {
    // replace define
    CGFloat x = -999;
    CGFloat y = -999;
    if (self.point.x || self.point.y) {
        x = self.point.x;
        y = self.point.y;
    }
    NSString *timeStamp = [[YumiMobileTools sharedTool] timestamp];
    NSDictionary *replaceStr = @{
                                 @"YUMI_ADSERVICE_CLICK_DOWN_X" : @(x),
                                 @"YUMI_ADSERVICE_CLICK_DOWN_Y" : @(y),
                                 @"YUMI_ADSERVICE_CLICK_UP_X" : @(x),
                                 @"YUMI_ADSERVICE_CLICK_UP_Y" : @(y),
                                 @"YUMI_ADSERVICE_UNIX_ORIGIN_TIME" : timeStamp,
                                 };
    __block NSString *urlString = [NSString stringWithFormat:@"%@", url];
    if (![urlString isKindOfClass:[NSNull class]] && urlString) {
        [replaceStr enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            urlString =
            [urlString stringByReplacingOccurrencesOfString:key withString:[NSString stringWithFormat:@"%@", obj]];
        }];
    }
    url = [NSURL URLWithString:urlString];
    // 1，2 浏览器
    // 6，8 App Store
    // 7 deeplink
    YumiMobileTools *tool = [YumiMobileTools sharedTool];
    if (self.ad.action == 1 || self.ad.action == 2) {
        [tool openBySystemMethod:url];
    }
    if (self.ad.action == 6 || self.ad.action == 8) {
        [self.appStore present];
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(yumimobileInterstitialDidClickAd:)]) {
            [self.delegate yumimobileInterstitialDidClickAd:self];
        }
        [self switchClickTypeWith:[NSURL URLWithString:targetUrl]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yumiMobileInterstitialDidReceiveAd:)]) {
        [self.delegate yumiMobileInterstitialDidReceiveAd:self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self errorHandler:error];
}

@end
