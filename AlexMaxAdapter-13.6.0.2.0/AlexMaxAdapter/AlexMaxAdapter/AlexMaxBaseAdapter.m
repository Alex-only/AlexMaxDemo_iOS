//
//  AlexMaxBaseAdapter.m
//  AlexMaxAdapter
//
//  Created by GUO PENG on 2025/4/17.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import "AlexMaxBaseAdapter.h"
#import <AnyThinkSDK/AnyThinkSDK.h>

@implementation AlexMaxBaseAdapter

- (Class)initializeClassName {
    return [AlexMaxInitAdapter class];
}

- (id)getAdObject
{
    return self.maxAd;
}

- (NSDictionary *)getC2SPriceDic:(MAAd *)ad
{
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *price = [NSString stringWithFormat:@"%f",ad.revenue * 1000];
    [extraDic AT_setDictValue:price key:ATAdSendC2SBidPriceKey];
    [extraDic AT_setDictValue:@(ATBiddingCurrencyTypeUS) key:ATAdSendC2SCurrencyTypeKey];
    NSString *logString = [NSString stringWithFormat:@"[Network:C2S]::MAX::%@",extraDic];
    [ATAdLogger logMessage:logString type:ATLogTypeInternal];
    return extraDic;
}

- (NSError *)getMaxError:(MAError *)error adUnitIdentifier:(NSString *)adUnitIdentifier
{
    NSMutableDictionary *errorDic = [NSMutableDictionary dictionary];
    [errorDic AT_setDictValue:@(error.code) key:@"code"];
    [errorDic AT_setDictValue:error.message key:@"errorMsg"];
    NSError *atError = [NSError errorWithDomain:adUnitIdentifier ? adUnitIdentifier : @"" code:error.code userInfo:errorDic];
    return atError;
}

- (NSDictionary *)networkCustomInfo
{
    NSMutableDictionary *customInfo = [[NSMutableDictionary alloc] init];
    [customInfo setValue:@(self.maxAd.revenue) forKey:@"Revenue"];
    [customInfo setValue:self.maxAd.adUnitIdentifier forKey:@"AdUnitId"];
    [customInfo setValue:self.maxAd.creativeIdentifier forKey:@"CreativeId"];
    [customInfo setValue:[AlexMaxInitAdapter getMaxFormat:self.maxAd] forKey:@"Format"];
    [customInfo setValue:self.maxAd.networkName forKey:@"NetworkName"];
    [customInfo setValue:self.maxAd.networkPlacement forKey:@"NetworkPlacement"];
    [customInfo setValue:self.maxAd.placement forKey:@"Placement"];
    [customInfo setValue:self.maxAd.DSPName forKey:@"DSPName"];
    [customInfo setValue:self.maxAd.DSPIdentifier forKey:@"DSPIdentifier"];
    [customInfo setValue:[NSValue valueWithCGSize:self.maxAd.size] forKey:@"Size"];
    ALSdk *alSdk = [ALSdk shared];
    [customInfo setValue:alSdk.configuration.countryCode forKey:@"CountryCode"];
    return customInfo;
}

@end
