//
//  YumiMobileAppStore.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMobileAppStore : NSObject
- (instancetype)initWithItunesLink:(NSString *)linkUrl;
- (void)present;
@end

NS_ASSUME_NONNULL_END
