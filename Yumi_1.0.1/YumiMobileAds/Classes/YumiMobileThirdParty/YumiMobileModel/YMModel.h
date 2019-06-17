//
//  YMModel.h
//  YMModel <https://github.com/ibireme/YMModel>
//
//  Created by ibireme on 15/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#if __has_include(<YMModel / YMModel.h>)
FOUNDATION_EXPORT double YMModelVersionNumber;
FOUNDATION_EXPORT const unsigned char YMModelVersionString[];
#import <YMModel/NSObject+YMModel.h>
#import <YMModel/YMClassInfo.h>
#else
#import "NSObject+YMModel.h"
#import "YMClassInfo.h"
#endif
