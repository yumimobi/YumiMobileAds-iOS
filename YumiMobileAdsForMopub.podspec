Pod::Spec.new do |s|
  s.name             = 'YumiMobileAdsForMopub'
  s.version          = '0.1.0'
  s.summary          = 'YumiMobileAds for iOS.'
  s.description      = 'The Yumi Mobile Ads SDK is the latest generation in Yumi mobile advertising featuring refined ad formats and streamlined APIs for access to mobile ad networks and advertising solutions. The SDK enables mobile app developers to maximize their monetization on Android and iOS. The Yumi Mobile Ads SDK is available to customers.' 
  s.homepage         = 'https://www.yumimobi.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YumiSDK' => 'wzy2010416033@163.com' }
  s.source           = { :git => 'https://github.com/yumimobi/YumiMobileAds-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Example/YumiMobileAds/MPYumiMobileBannerCustomEvent.{h,m}'
  s.dependency 'YumiMobileAds'
  s.dependency 'mopub-ios-sdk'

end