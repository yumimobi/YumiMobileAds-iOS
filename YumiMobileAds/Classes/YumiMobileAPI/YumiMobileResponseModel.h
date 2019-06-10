//
//  YumiMobileResponseModel.h
//  YumiMobileAds
//
//  Created by 王泽永 on 2019/6/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface YumiMobileAdsModel : NSObject
@property (nonatomic, assign) int action;
@property (nonatomic) NSString *targetUrl;
@property (nonatomic) NSString *html;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSArray<NSString *> *clickArray;
@property (nonatomic) NSArray<NSString *> *impressionArray;
@property (nonatomic) NSArray<NSString *> *closeArray;
@property (nonatomic, assign) int materailType;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *desc;
@property (nonatomic) NSString *logoUrl;

@end


@interface YumiMobileResponseModel : NSObject
// =0, success.
// <0, fail
@property (nonatomic, assign) int result;
@property (nonatomic) NSString *msg;
@property (nonatomic) NSArray<YumiMobileAdsModel *> *ads;
@end

NS_ASSUME_NONNULL_END
