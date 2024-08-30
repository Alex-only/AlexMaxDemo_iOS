
#import "AlexMaxInterstitialCustomEvent.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxC2SBiddingRequestManager.h"

@interface AlexMaxInterstitialCustomEvent ()

@end

@implementation AlexMaxInterstitialCustomEvent

- (void)didLoadAd:(MAAd *)ad {
    
    if (self.isC2SBiding) {
        NSString *price = [NSString stringWithFormat:@"%f",ad.revenue * 1000];
        [AlexMaxC2SBiddingRequestManager disposeLoadSuccessCall:price customObject:ad unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    }else{
        self.maxAd = ad;
        [self trackInterstitialAdLoaded:self.interstitialAd adExtra:nil];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    NSError *loadFailError = [NSError errorWithDomain:(adUnitIdentifier ?: @"") code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:loadFailError key:kATSDKFailedToLoadInterstitialADMsg unitID:self.networkAdvertisingID];
    }else{
        [self trackInterstitialAdLoadFailed:loadFailError];
    }
}

- (void)didClickAd:(MAAd *)ad {
    [self trackInterstitialAdClick];
}

- (void)didDisplayAd:(MAAd *)ad {
    [self trackInterstitialAdShow];
    [self trackInterstitialAdVideoStart];
}

- (void)didHideAd:(MAAd *)ad {
    [self trackInterstitialAdClose:@{kATADDelegateExtraDismissTypeKey:@(ATAdCloseUnknow)}];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    NSError *showFailError = [NSError errorWithDomain:@"com.anythink.MaxInterstitial" code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    [self trackInterstitialAdShowFailed:showFailError];
    [self trackInterstitialAdDidFailToPlayVideo:showFailError];
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
