
#import "AlexMaxBannerCustomEvent.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxC2SBiddingRequestManager.h"

@interface AlexMaxBannerCustomEvent ()
@end

@implementation AlexMaxBannerCustomEvent

#pragma mark - MAAdDelegate Protocol
- (void)didLoadAd:(MAAd *)ad {
    
    if (self.isC2SBiding) {
        NSString *price = [NSString stringWithFormat:@"%f",ad.revenue * 1000];
        [AlexMaxC2SBiddingRequestManager disposeLoadSuccessCall:price customObject:ad unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    }else{
        self.maxAd = ad;
        [self trackBannerAdLoaded:self.adView adExtra:nil];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    NSError *loadFailError = [NSError errorWithDomain:(adUnitIdentifier ?: @"") code:error.code userInfo:@{
        NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg,
        NSLocalizedFailureReasonErrorKey:error.message
    }];
    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:loadFailError key:kATSDKFailedToLoadBannerADMsg unitID:self.networkAdvertisingID];
    }else{
        [self trackBannerAdLoadFailed:loadFailError];        
    }
}

- (void)didClickAd:(MAAd *)ad {
    [self trackBannerAdClick];
}

- (void)didDisplayAd:(MAAd *)ad {
}

- (void)didHideAd:(MAAd *)ad {
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
}

#pragma mark - MAAdViewAdDelegate Protocol
- (void)didExpandAd:(MAAd *)ad {
}

- (void)didCollapseAd:(MAAd *)ad {
    [self trackBannerAdClosed];
}

/// This is an override method, for more detailsplease refer to ATBannerCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
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
