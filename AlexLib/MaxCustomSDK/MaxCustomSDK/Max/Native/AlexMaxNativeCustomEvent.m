
#import "AlexMaxNativeCustomEvent.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxC2SBiddingRequestManager.h"

NSString *const kAlexMAXNativeAssetsExpressAdViewKey = @"max_express_ad_view";

@implementation AlexMaxNativeCustomEvent

#pragma mark - MANativeAdDelegate
- (void)didLoadNativeAd:(nullable MANativeAdView *)nativeAdView forAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didLoadAd---networkName:%@",ad.networkName);
    if ([self isMaxAdTemplateType]) {
        [self templateDidLoadNativeAd:ad nativeAdView:nativeAdView];
        return;
    }
    [self selfRenderingDidLoadNativeAd:ad];
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    
    NSError *loadFailError = [NSError errorWithDomain:(adUnitIdentifier ?: @"") code:error.code userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:error.message}];
    NSLog(@"%@",[NSString stringWithFormat:@"AlexMaxNativeCustomEvent:didFailToLoadNativeAdForAdUnitIdentifier:%@ withError:%@",adUnitIdentifier,loadFailError]);
    
    if ([self isMaxAdTemplateType]) {
        [self templateDidFailToLoadAd:adUnitIdentifier error:loadFailError];
        return;
    }
    [self selfRenderingDidFailToLoadAd:adUnitIdentifier error:loadFailError];
}

- (void)didClickNativeAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didClickNativeAd---networkName:%@",ad.networkName);

    [self trackNativeAdClick];
}

- (void)didExpireNativeAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didExpireNativeAd---networkName:%@",ad.networkName);
}

- (void)didPayRevenueForAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didPayRevenueForAd::NativeAdImpression---networkName:%@",ad.networkName);
    [self trackNativeAdImpression];
}

#pragma mark - public
- (void)maxNativeRenderWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView {
    
    if ([self isMaxAdTemplateType]) {
        [self maxExpressWithMaAd:ad nativeAdView:nativeAdView];
    } else {
        [self maxSelfRenderWithMaAd:ad];
    }
}
#pragma mark - 自渲染
- (void)selfRenderingDidLoadNativeAd:(MAAd * _Nonnull)ad{
    self.maxAd = ad;
    if (self.isC2SBiding) {
        [self c2sPriceWithAd:ad];
        self.isC2SBiding = NO;
    } else {
        [self maxSelfRenderWithMaAd:ad];
    }
}

- (void)maxSelfRenderWithMaAd:(MAAd * _Nonnull)ad {
    
    NSMutableArray<NSDictionary*>* assetArray = [NSMutableArray<NSDictionary*> array];
    NSMutableDictionary *assetDic = [NSMutableDictionary dictionary];
    [assetDic setValue:self forKey:kATAdAssetsCustomEventKey];
    [assetDic setValue:self forKey:kATAdAssetsDelegateObjKey];
    [assetDic setValue:self.maxNativeAdLoader forKey:kATAdAssetsCustomObjectKey];
    [assetDic setValue:@(0) forKey:kATNativeADAssetsIsExpressAdKey];
    [assetArray addObject:assetDic];
    [self trackNativeAdLoaded:assetArray];
    
}
- (void)selfRenderingDidFailToLoadAd:(NSString * _Nonnull)adUnitIdentifier error:(NSError * _Nonnull)error {

    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:error key:kATSDKFailedToLoadNativeADMsg unitID:self.networkAdvertisingID];
    } else {
        [self trackNativeAdLoadFailed:error];
    }
}

#pragma mark - 模板
- (void)templateDidLoadNativeAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView {
    
    if (self.isC2SBiding) {
        AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:nativeAdView];
        request.nativeAds = array;
        [self c2sPriceWithAd:ad];
        self.isC2SBiding = NO;
    }else{
        self.maxAd = ad;
        [self maxExpressWithMaAd:ad nativeAdView:nativeAdView];
    }
}

- (void)templateDidFailToLoadAd:(NSString * _Nonnull)adUnitIdentifier error:(NSError * _Nonnull)error {
    
    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:error key:kATSDKFailedToLoadNativeADMsg unitID:self.networkAdvertisingID];
    }else{
        [self trackNativeAdLoadFailed:error];
    }
}

- (void)maxExpressWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView {
    NSMutableArray<NSDictionary*>* assetArray = [NSMutableArray<NSDictionary*> array];
    
    NSMutableDictionary *assetDic = [NSMutableDictionary dictionary];
    [assetDic setValue:self forKey:kATAdAssetsCustomEventKey];
    [assetDic setValue:self forKey:kATAdAssetsDelegateObjKey];
    [assetDic setValue:self.maxNativeAdLoader forKey:kATAdAssetsCustomObjectKey];
    [assetDic setValue:nativeAdView forKey:kAlexMAXNativeAssetsExpressAdViewKey];
    [assetDic setValue:@(1) forKey:kATNativeADAssetsIsExpressAdKey];
    [assetDic setValue:[NSString stringWithFormat:@"%lf",nativeAdView.frame.size.width] forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
    [assetDic setValue:[NSString stringWithFormat:@"%lf",nativeAdView.frame.size.height] forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
    
    [assetArray addObject:assetDic];
    [self trackNativeAdLoaded:assetArray];
}

#pragma mark - other
- (void)c2sPriceWithAd:(MAAd * _Nonnull)ad {
    NSString *price = [NSString stringWithFormat:@"%f",ad.revenue * 1000];
    [AlexMaxC2SBiddingRequestManager disposeLoadSuccessCall:price customObject:ad unitID:self.networkAdvertisingID];
}
- (BOOL)isMaxAdTemplateType {
    if ([self.serverInfo[@"unit_type"] integerValue] == AlexMaxNativeRenderTypeTemplate) {
        return YES;
    }
    return NO;
}

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
