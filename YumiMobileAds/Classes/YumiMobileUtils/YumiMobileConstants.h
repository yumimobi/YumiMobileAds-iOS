//
//  YumiMobileConstants.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//
#import <Foundation/Foundation.h>

#ifndef YumiMobileConstants_h
#define YumiMobileConstants_h

#define YumiMobileErrorDomin @"Yumi_Mobile_Error_Domin_10010"
#define SYSTEM_VERSION_LESS_THAN(v)                                                                                    \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#endif /* YumiMobileConstants_h */
