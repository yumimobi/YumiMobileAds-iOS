//
//  YumiAppStore.h
//  Expecta
//
//  Created by d on 17/5/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMobileBannerAppStore : NSObject
+ (instancetype)sharedYumiMobileAppStore;
- (void)setItunesLink:(NSString *)linkUrl;
- (void)present;

@end

NS_ASSUME_NONNULL_END
