//
//  ATUnityAdsBannerAdapter.m
//  AnyThinkUnityAdsAdapter
//
//  Created by GUO PENG on 2025/2/13.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import "AlexMaxBannerAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <AnyThinkSDK/AnyThinkSDK.h>

@interface AlexMaxBannerAdapter()<MAAdViewAdDelegate,MAAdRevenueDelegate>

@property(nonatomic, strong) MAAdView *adView;

@end

@implementation AlexMaxBannerAdapter

- (void)dealloc
{
    [ATAdLogger logMessage:@"AlexMaxBannerAdapter dealloc" type:ATLogTypeExternal];
}

#pragma mark - init
+ (nullable ATBaseMediationAdapter *)getLoadAdAdapter:(nonnull ATAdMediationArgument *)argument {
    
    ATBaseMediationAdapter *adapter;
    
    if (argument.jointAdType == ATUnitGroupJointAdOtherType || argument.jointAdType == ATUnitGroupJointAdBannerType) {
        adapter = [[AlexMaxBannerAdapter alloc] init];
    }
    return adapter;
}

#pragma mark - load Ad
- (void)loadADWithArgument:(ATAdMediationArgument *)argument
{
    [ATAdLogger logMessage:@"AlexMaxBannerAdapter loadADWithArgument" type:ATLogTypeExternal];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAd];
    });
}

- (void)loadAd
{
    MAAdFormat *format = [self.argument.serverContentDic[@"unit_type"] boolValue] ? [MAAdFormat mrec] : [MAAdFormat banner];
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier:self.argument.serverContentDic[@"unit_id"] adFormat:format sdk:[ALSdk shared]];
    self.adView.delegate = self;
//    self.adView.revenueDelegate = self;
    self.adView.frame = [self.argument.serverContentDic[@"unit_type"] boolValue] ? CGRectMake(0, 0, 300, 250) : CGRectMake(0, 0, 320, 50);
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S
        && self.argument.dynamicFloorPrice)
    {
        [self.adView setExtraParameterForKey:@"jC7Fp" value:self.argument.dynamicFloorPrice];
    }
    [self.adView loadAd];
}


//- (void)didPayRevenueForAd:(MAAd *)ad
//{
//    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didPayRevenueForAd:" type:ATLogTypeExternal];
//    [self.adStatusBridge atOnAdShow:nil];
//    [self.adStatusBridge atOnAdVideoStart:nil];
//}

#pragma mark - MAAdViewAdDelegate

- (void)didLoadAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didLoadAd:" type:ATLogTypeExternal];

    [self.adStatusBridge setSendImpressionTrackingIfNeed:YES];
    
    self.maxAd = ad;
    
    [self.adStatusBridge setNetworkCustomInfo: [self networkCustomInfo]];
    
    NSDictionary *extraDic;
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S)
    {
        extraDic = [self getC2SPriceDic:ad];
    }
    [self.adStatusBridge atOnBannerAdLoadedWithView:self.adView adExtra:extraDic];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didFailToLoadAdForAdUnitIdentifier:" type:ATLogTypeExternal];

    NSError *loadFailError = [self getMaxError:error adUnitIdentifier:adUnitIdentifier];
    [self.adStatusBridge atOnAdLoadFailed:loadFailError adExtra:nil];
}

- (void)didDisplayAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didDisplayAd:" type:ATLogTypeExternal];
}

- (void)didHideAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didHideAd:" type:ATLogTypeExternal];
    [self.adStatusBridge setCloseType:ATAdCloseCountdown];
    [self.adStatusBridge atOnAdVideoEnd:nil];
    [self.adStatusBridge atOnAdClosed:nil];
}

- (void)didClickAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didClickAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didFailToDisplayAd:" type:ATLogTypeExternal];
    NSError *showFailError = [NSError errorWithDomain:@"com.anythink.MaxInterstitial" code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    [self.adStatusBridge atOnAdDidFailToPlayVideo:showFailError extra:nil];
}

- (void)didExpandAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didExpandAd:" type:ATLogTypeExternal];
}

- (void)didCollapseAd:(MAAd *)ad
{
    [ATAdLogger logMessage:@"AlexMaxBannerDelegate::didCollapseAd:" type:ATLogTypeExternal];
    [self.adStatusBridge atOnAdClosed:nil];
}
@end
