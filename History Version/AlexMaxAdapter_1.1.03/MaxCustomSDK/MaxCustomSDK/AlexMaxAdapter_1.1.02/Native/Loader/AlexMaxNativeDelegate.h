//
//  AlexMaxNativeDelegate.h
//  AlexMaxAdapter
//
//  Created by GUO PENG on 2025/2/19.
//  Copyright © 2025 AnyThink. All rights reserved.
//
 
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxCommendAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxNativeDelegate : NSObject<MANativeAdDelegate,MAAdRevenueDelegate>

@property (nonatomic, strong) NSDictionary *serverInfo;

@property (nonatomic, weak) id<AlexMaxCommendAdDelegate> delegate;
 
@property(nonatomic, weak) id maxNativeAdLoader;

@property (nonatomic, readwrite) MAAd *maxAd;

@property (assign, nonatomic) BOOL isC2SBiding;

- (void)maxNativeRenderWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView;

@property (nonatomic, strong) NSString *networkAdvertisingID;

@end

NS_ASSUME_NONNULL_END
