//
//  YumiAppStore.h
//  Expecta
//
//  Created by d on 17/5/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YumiMobileAppStore : NSObject
- (instancetype)initWithItunesLink:(NSString *)linkUrl;
- (void)present;

@end

NS_ASSUME_NONNULL_END
