//
//  ATUnityAdsRewardedVideoAdapter.m
//  AnyThinkUnityAdsAdapter
//
//  Created by GUO PENG on 2025/2/13.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import "AlexMaxRewardedVideoAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <AnyThinkSDK/AnyThinkSDK.h>


@interface AlexMaxRewardedVideoAdapter()<MARewardedAdDelegate>

@property(nonatomic, strong) MARewardedAd *rewardedAd;
@end


@implementation AlexMaxRewardedVideoAdapter

- (void)dealloc
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoAdapter dealloc" type:ATLogTypeExternal];
}

#pragma mark - init
+ (nullable ATBaseMediationAdapter *)getLoadAdAdapter:(nonnull ATAdMediationArgument *)argument
{
    
    ATBaseMediationAdapter *adapter;
    
    if (argument.jointAdType == ATUnitGroupJointAdOtherType || argument.jointAdType == ATUnitGroupJointAdRewardedType) {
        adapter = [[AlexMaxRewardedVideoAdapter alloc] init];
    }
    return adapter;
}

#pragma mark - load Ad
- (void)loadADWithArgument:(ATAdMediationArgument *)argument
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoAdapter loadADWithArgument" type:ATLogTypeExternal];
    
    if(self.argument.localInfoDic[kATAdLoadingExtraUserIDKey] != nil)
    {
        [ALSdk shared].settings.userIdentifier = self.argument.localInfoDic[kATAdLoadingExtraUserIDKey];
    }
    else
    {
        [ALSdk shared].settings.userIdentifier = self.argument.serverContentDic[@"userID"];
    }
    
    self.rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier:argument.serverContentDic[@"unit_id"] sdk:[ALSdk shared]];
    
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S && argument.dynamicFloorPrice)
    {
        [self.rewardedAd setExtraParameterForKey:@"jC7Fp" value:argument.dynamicFloorPrice];
    }
    self.rewardedAd.delegate = self;
    [self.rewardedAd loadAd];
}

- (BOOL)adReadyRewardedWithInfo:(nonnull NSDictionary *)info
{
    return self.rewardedAd.isReady;
}

- (void)showRewardedVideoInViewController:(nonnull UIViewController *)viewController
{
    [self.rewardedAd showAd];
}

#pragma mark - MARewardedAdDelegate

- (void)didLoadAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoDelegate::didLoadAd:" type:ATLogTypeExternal];

    self.maxAd = ad;
    
    [self.adStatusBridge setNetworkCustomInfo: [self networkCustomInfo]];
    
    NSDictionary *extraDic;
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S)
    {
        extraDic = [self getC2SPriceDic:ad];
    }
    [self.adStatusBridge atOnRewardedAdLoadedExtra:extraDic];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoDelegate::didFailToLoadAdForAdUnitIdentifier:" type:ATLogTypeExternal];

    NSError *loadFailError = [self getMaxError:error adUnitIdentifier:adUnitIdentifier];
    [self.adStatusBridge atOnAdLoadFailed:loadFailError adExtra:nil];
}

- (void)didDisplayAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoDelegate::didDisplayAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdShow:nil];
    [self.adStatusBridge atOnAdVideoStart:nil];
}

- (void)didHideAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoDelegate::didHideAd:" type:ATLogTypeExternal];
    [self.adStatusBridge setCloseType:ATAdCloseCountdown];
    [self.adStatusBridge atOnAdVideoEnd:nil];
    [self.adStatusBridge atOnAdClosed:nil];
}

- (void)didClickAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoDelegate::didClickAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoDelegate::didFailToDisplayAd:" type:ATLogTypeExternal];
    NSError *showFailError = [NSError errorWithDomain:@"com.anythink.MaxRewardedVideo" code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    [self.adStatusBridge atOnAdDidFailToPlayVideo:showFailError extra:nil];
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    [ATAdLogger logMessage:@"AlexMaxRewardedVideoDelegate::didRewardUserForAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnRewardedVideoAdRewarded];
}
@end
