
#import "AlexMaxRewardedVideoCustomEvent.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxC2SBiddingRequestManager.h"

@interface AlexMaxRewardedVideoCustomEvent ()
@end

@implementation AlexMaxRewardedVideoCustomEvent

#pragma mark - MAAdDelegate Protocol
- (void)didLoadAd:(MAAd *)ad {
    
    if (self.isC2SBiding) {
        NSString *price = [NSString stringWithFormat:@"%f",ad.revenue * 1000];
        [AlexMaxC2SBiddingRequestManager disposeLoadSuccessCall:price customObject:ad unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    }else{
        self.maxAd = ad;
        [self trackRewardedVideoAdLoaded:self.rewardedAd adExtra:nil];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    
    NSError *loadFailError = [NSError errorWithDomain:(adUnitIdentifier ?: @"") code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:loadFailError key:kATSDKFailedToLoadRewardedVideoADMsg unitID:self.networkAdvertisingID];
    }else{
        [self trackRewardedVideoAdLoadFailed:loadFailError];
    }
}

- (void)didClickAd:(MAAd *)ad {
    [self trackRewardedVideoAdClick];
}

- (void)didDisplayAd:(MAAd *)ad {
    [self trackRewardedVideoAdShow];
}

- (void)didHideAd:(MAAd *)ad {
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted extra:@{kATADDelegateExtraDismissTypeKey:self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    NSError *showFailError = [NSError errorWithDomain:@"com.anythink.MaxRewardedVideo" code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    [self trackRewardedVideoAdPlayEventWithError:showFailError];
}

#pragma mark - MARewardedAdDelegate Protocol
- (void)didStartRewardedVideoForAd:(MAAd *)ad {
    [self trackRewardedVideoAdVideoStart];
}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {
    [self trackRewardedVideoAdVideoEnd];
    self.closeType = ATAdCloseCountdown;
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward {
    [self trackRewardedVideoAdRewarded];
}

#pragma mark - other
- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

- (NSDictionary *)networkCustomInfo {
    NSMutableDictionary *customInfo = [[NSMutableDictionary alloc] init];
    [customInfo setValue:@(self.maxAd.revenue) forKey:@"Revenue"];
    [customInfo setValue:self.maxAd.adUnitIdentifier forKey:@"AdUnitId"];
    [customInfo setValue:self.maxAd.creativeIdentifier forKey:@"CreativeId"];
    [customInfo setValue:[AlexMaxBaseManager getMaxFormat:self.maxAd] forKey:@"Format"];
    [customInfo setValue:self.maxAd.networkName forKey:@"NetworkName"];
    [customInfo setValue:self.maxAd.networkPlacement forKey:@"NetworkPlacement"];
    [customInfo setValue:self.maxAd.placement forKey:@"Placement"];
    
    ALSdk *alSdk = [ALSdk sharedWithKey:self.serverInfo[@"sdk_key"]];
    [customInfo setValue:alSdk.configuration.countryCode forKey:@"CountryCode"];
    return customInfo;
}

@end
