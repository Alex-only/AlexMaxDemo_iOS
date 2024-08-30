
#import "AlexMaxSplashCustomEvent.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxBaseManager.h"
#import "AlexMaxC2SBiddingRequestManager.h"

@implementation AlexMaxSplashCustomEvent

- (void)didLoadAd:(MAAd *)ad {
    
    if (self.isC2SBiding) {
        NSString *price = [NSString stringWithFormat:@"%f",ad.revenue * 1000];
        [AlexMaxC2SBiddingRequestManager disposeLoadSuccessCall:price customObject:ad unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    }else{
        self.maxAd = ad;
        [self trackSplashAdLoaded:self.splashAd adExtra:nil];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    
    NSError *loadFailError = [NSError errorWithDomain:(adUnitIdentifier ?: @"") code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:loadFailError key:kATSDKFailedToLoadSplashADMsg unitID:self.networkAdvertisingID];
    }else{
        [self trackSplashAdLoadFailed:loadFailError];
    }
}

- (void)didClickAd:(MAAd *)ad {
    [self trackSplashAdClick];
}

- (void)didDisplayAd:(MAAd *)ad {
    [self trackSplashAdShow];
}

- (void)didHideAd:(MAAd *)ad {
    [self trackSplashAdClosed:@{kATADDelegateExtraDismissTypeKey:@(ATAdCloseUnknow)}];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    NSError *showFailError = [NSError errorWithDomain:@"com.anythink.MaxSplash" code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    [self trackSplashAdShowFailed:showFailError];
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
