//
//  ATUnityAdsSplashAdapter.m
//  AnyThinkUnityAdsAdapter
//
//  Created by GUO PENG on 2025/2/13.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import "AlexMaxSplashAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <AnyThinkSDK/AnyThinkSDK.h>
#import "AlexMaxNativeAdapter.h"

@interface AlexMaxSplashAdapter()<MAAdDelegate>

@property (nonatomic, strong) MAAppOpenAd *splashAd;

@end


@implementation AlexMaxSplashAdapter

- (void)dealloc
{
    [ATAdLogger logMessage:@"AlexMaxSplashAdapter dealloc" type:ATLogTypeExternal];
}

#pragma mark - init
+ (nullable ATBaseMediationAdapter *)getLoadAdAdapter:(nonnull ATAdMediationArgument *)argument {
    
    ATBaseMediationAdapter *adapter;
    
    if (argument.jointAdType == ATUnitGroupJointAdOtherType || argument.jointAdType == ATUnitGroupJointAdSplashType)
    {
        adapter = [[AlexMaxSplashAdapter alloc] init];
    }
    else if (argument.jointAdType == ATUnitGroupJointAdNativeType)
    {
        adapter = [[AlexMaxNativeAdapter alloc] init];
    }
    
    return adapter;
}

#pragma mark - load Ad
- (void)loadADWithArgument:(ATAdMediationArgument *)argument
{
    [ATAdLogger logMessage:@"AlexMaxSplashAdapter loadADWithArgument" type:ATLogTypeExternal];
    self.splashAd = [[MAAppOpenAd alloc] initWithAdUnitIdentifier:argument.serverContentDic[@"unit_id"] sdk:[ALSdk shared]];
    self.splashAd.delegate = self;
    
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S && argument.dynamicFloorPrice) {
        [self.splashAd setExtraParameterForKey:@"jC7Fp" value:argument.dynamicFloorPrice];
    }
    [self.splashAd loadAd];
}

- (BOOL)adReadySplashWithInfo:(nonnull NSDictionary *)info
{
    return self.splashAd.isReady;
}

- (void)showSplashAdInWindow:(nonnull UIWindow *)window inViewController:(nonnull UIViewController *)inViewController parameter:(nonnull NSDictionary *)parameter
{
    [self.splashAd showAd];

}

#pragma mark - MAAdDelegate

- (void)didLoadAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxSplashDelegate::didLoadAd:" type:ATLogTypeExternal];

    self.maxAd = ad;
    
    [self.adStatusBridge setNetworkCustomInfo: [self networkCustomInfo]];
    
    NSDictionary *extraDic;
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S)
    {
        extraDic = [self getC2SPriceDic:ad];
    }
    [self.adStatusBridge atOnSplashAdLoadedExtra:extraDic];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxSplashDelegate::didFailToLoadAdForAdUnitIdentifier:" type:ATLogTypeExternal];

    NSError *loadFailError = [self getMaxError:error adUnitIdentifier:adUnitIdentifier];
    [self.adStatusBridge atOnAdLoadFailed:loadFailError adExtra:nil];
}

- (void)didDisplayAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxSplashDelegate::didDisplayAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdShow:nil];
    [self.adStatusBridge atOnAdVideoStart:nil];
}

- (void)didHideAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxSplashDelegate::didHideAd:" type:ATLogTypeExternal];
    [self.adStatusBridge setCloseType:ATAdCloseCountdown];
    [self.adStatusBridge atOnAdVideoEnd:nil];
    [self.adStatusBridge atOnAdClosed:nil];
}

- (void)didClickAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxSplashDelegate::didClickAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxSplashDelegate::didFailToDisplayAd:" type:ATLogTypeExternal];
    NSError *showFailError = [NSError errorWithDomain:@"com.anythink.MaxSplash" code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    [self.adStatusBridge atOnAdDidFailToPlayVideo:showFailError extra:nil];
}
@end
