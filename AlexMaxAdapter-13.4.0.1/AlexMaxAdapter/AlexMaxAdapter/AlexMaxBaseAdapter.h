//
//  AlexMaxBaseAdapter.h
//  AlexMaxAdapter
//
//  Created by GUO PENG on 2025/4/17.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import <AnyThinkSDK/ATBaseMediationAdapter.h>
#import "AlexMaxInitAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>


NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxBaseAdapter : ATBaseMediationAdapter

- (NSDictionary *)getC2SPriceDic:(MAAd *)ad;

- (NSError *)getMaxError:(MAError *)error adUnitIdentifier:(NSString *)adUnitIdentifier;

- (NSDictionary *)networkCustomInfo;

@property (nonatomic, strong) MAAd *maxAd;
@end

NS_ASSUME_NONNULL_END
