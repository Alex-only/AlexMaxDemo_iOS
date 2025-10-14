//
//  ATUnityAdsInterstitialAdapter.m
//  AnyThinkUnityAdsAdapter
//
//  Created by GUO PENG on 2025/2/13.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import "AlexMaxInterstitialAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <AnyThinkSDK/AnyThinkSDK.h>

@interface AlexMaxInterstitialAdapter()<MAAdDelegate>

@property(nonatomic, strong) MAInterstitialAd *interstitialAd;

@end

@implementation AlexMaxInterstitialAdapter

- (void)dealloc
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialAdapter dealloc" type:ATLogTypeExternal];
}


#pragma mark - init
+ (nullable ATBaseMediationAdapter *)getLoadAdAdapter:(nonnull ATAdMediationArgument *)argument {
    
    ATBaseMediationAdapter *adapter;
    
    if (argument.jointAdType == ATUnitGroupJointAdOtherType || argument.jointAdType == ATUnitGroupJointAdInterstitialType) {
        adapter = [[AlexMaxInterstitialAdapter alloc] init];
    }
    return adapter;
}

#pragma mark - load Ad
- (void)loadADWithArgument:(ATAdMediationArgument *)argument
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialAdapter loadADWithArgument" type:ATLogTypeExternal];
    self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:argument.serverContentDic[@"unit_id"] sdk:[ALSdk shared]];
    self.interstitialAd.delegate = self;
    
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S && argument.dynamicFloorPrice) {
        [self.interstitialAd setExtraParameterForKey:@"jC7Fp" value:argument.dynamicFloorPrice];
    }
    
    [self.interstitialAd loadAd];
}


- (BOOL)adReadyInterstitialWithInfo:(nonnull NSDictionary *)info
{
    return self.interstitialAd.isReady;
}

- (void)showInterstitialInViewController:(nonnull UIViewController *)viewController {
    [self.interstitialAd showAd];
}


#pragma mark - MAAdDelegate

- (void)didLoadAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialDelegate::didLoadAd:" type:ATLogTypeExternal];

    self.maxAd = ad;
    
    [self.adStatusBridge setNetworkCustomInfo: [self networkCustomInfo]];
    
    NSDictionary *extraDic;
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S)
    {
        extraDic = [self getC2SPriceDic:ad];
    }
    [self.adStatusBridge atOnInterstitialAdLoadedExtra:extraDic];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialDelegate::didFailToLoadAdForAdUnitIdentifier:" type:ATLogTypeExternal];

    NSError *loadFailError = [self getMaxError:error adUnitIdentifier:adUnitIdentifier];
    [self.adStatusBridge atOnAdLoadFailed:loadFailError adExtra:nil];
}

- (void)didDisplayAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialDelegate::didDisplayAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdShow:nil];
    [self.adStatusBridge atOnAdVideoStart:nil];
}

- (void)didHideAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialDelegate::didHideAd:" type:ATLogTypeExternal];
    [self.adStatusBridge setCloseType:ATAdCloseCountdown];
    [self.adStatusBridge atOnAdVideoEnd:nil];
    [self.adStatusBridge atOnAdClosed:nil];
}

- (void)didClickAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialDelegate::didClickAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxInterstitialDelegate::didFailToDisplayAd:" type:ATLogTypeExternal];
    NSError *showFailError = [NSError errorWithDomain:@"com.anythink.MaxInterstitial" code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    [self.adStatusBridge atOnAdDidFailToPlayVideo:showFailError extra:nil];
}
@end
