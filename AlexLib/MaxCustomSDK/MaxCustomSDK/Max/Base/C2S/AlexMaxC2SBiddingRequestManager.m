
#import "AlexMaxC2SBiddingRequestManager.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxNativeCustomEvent.h"
#import "AlexMaxSplashCustomEvent.h"
#import "AlexMaxBannerCustomEvent.h"
#import "AlexMaxRewardedVideoCustomEvent.h"
#import "AlexMaxInterstitialCustomEvent.h"

@implementation AlexMaxC2SBiddingRequestManager

+ (instancetype)sharedInstance {
    static AlexMaxC2SBiddingRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AlexMaxC2SBiddingRequestManager alloc] init];
    });
    return sharedInstance;
}

- (void)startWithRequestItem:(AlexMaxBiddingRequest *)request {
    [[AlexMAXNetworkC2STool sharedInstance] saveRequestItem:request withUnitId:request.unitID];
    
    [AlexMaxBaseManager initWithCustomInfo:request.extraInfo localInfo:request.extraInfo maxInitFinishBlock:^{
        [self initSuccessStartLoad:request];
    }];
}

- (void)initSuccessStartLoad:(AlexMaxBiddingRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request) {
            NSString *unitId = request.unitGroup.content[@"unit_id"];
            if (!unitId || [unitId isEqualToString:@""]) {
                NSError *error = [[NSError alloc] initWithDomain:@"com.anythink" code:2000 userInfo:nil];
                [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:error key:@"unit_id must be not nil or empty" unitID:unitId];
                return;
            }
        }
        switch (request.adType) {
            case ATAdFormatInterstitial:
                [self startLoadInterstitialAdWithRequest:request];
                break;
                
            case ATAdFormatRewardedVideo:
                [self startLoadRewardedVideoAdWithRequest:request];
                break;
                
            case ATAdFormatNative:
                [self startLoadNativeAdWithRequest:request];
                break;
                
            case ATAdFormatBanner:
                [self startLoadBannerAdWithRequest:request];
                break;
                
            case ATAdFormatSplash:
                [self startLoadSplashAdWithRequest:request];
                break;
                
            default:
                break;
        }
    });
}

#pragma mark - ATAdFormatInterstitial
- (void)startLoadInterstitialAdWithRequest:(AlexMaxBiddingRequest *)request {
    MAInterstitialAd *interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:request.unitGroup.content[@"unit_id"] sdk:[ALSdk shared]];
    
    interstitialAd.delegate = (AlexMaxInterstitialCustomEvent *)request.customEvent;    
    // 动态出价设置最大价格
    if ([request.extraInfo.allKeys containsObject: kATAdapterCustomInfoMaxFilledPriceKey]) {
        NSString *maxPrice = request.extraInfo[kATAdapterCustomInfoMaxFilledPriceKey];
        if (maxPrice == nil) {
            maxPrice = @"0";
        }
        [interstitialAd setExtraParameterForKey:@"jC7Fp" value:maxPrice];
    }
    [interstitialAd loadAd];
    request.customObject = interstitialAd;
}

#pragma mark - ATAdFormatRewardedVideo
- (void)startLoadRewardedVideoAdWithRequest:(AlexMaxBiddingRequest *)request {
    MARewardedAd *rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier:request.unitGroup.content[@"unit_id"] sdk:[ALSdk shared]];
    rewardedAd.delegate = (AlexMaxRewardedVideoCustomEvent *)request.customEvent;
    // 动态出价设置最大价格
    if ([request.extraInfo.allKeys containsObject :kATAdapterCustomInfoMaxFilledPriceKey]) {
        NSString *maxPrice = request.extraInfo[kATAdapterCustomInfoMaxFilledPriceKey];
        if (maxPrice == nil) {
            maxPrice = @"0";
        }
        [rewardedAd setExtraParameterForKey:@"jC7Fp" value:maxPrice];
    }
    [rewardedAd loadAd];
    request.customObject = rewardedAd;
}

#pragma mark - ATAdFormatNative
- (void)startLoadNativeAdWithRequest:(AlexMaxBiddingRequest *)request {
    MANativeAdLoader *maxNativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:request.unitGroup.content[@"unit_id"] sdk:[ALSdk shared]];
    maxNativeAdLoader.nativeAdDelegate = (AlexMaxNativeCustomEvent *)request.customEvent;
    maxNativeAdLoader.revenueDelegate = (AlexMaxNativeCustomEvent *)request.customEvent;

    // 动态出价设置最大价格
    if ([request.extraInfo.allKeys containsObject :kATAdapterCustomInfoMaxFilledPriceKey]) {
        NSString *maxPrice = request.extraInfo[kATAdapterCustomInfoMaxFilledPriceKey];
        if (maxPrice == nil) {
            maxPrice = @"0";
        }
        [maxNativeAdLoader setExtraParameterForKey:@"jC7Fp" value:maxPrice];
    }
    [maxNativeAdLoader loadAd];
    request.customObject = maxNativeAdLoader;
}

#pragma mark - ATAdFormatBanner
- (void)startLoadBannerAdWithRequest:(AlexMaxBiddingRequest *)request {
    MAAdFormat *format = [request.unitGroup.content[@"unit_type"] boolValue] ? [MAAdFormat mrec] : [MAAdFormat banner];
    MAAdView *adView = [[MAAdView alloc] initWithAdUnitIdentifier:request.unitGroup.content[@"unit_id"] adFormat:format sdk:[ALSdk shared]];
    adView.delegate = (AlexMaxBannerCustomEvent *)request.customEvent;
    // 动态出价设置最大价格
    if ([request.extraInfo.allKeys containsObject :kATAdapterCustomInfoMaxFilledPriceKey]) {
        NSString *maxPrice = request.extraInfo[kATAdapterCustomInfoMaxFilledPriceKey];
        if (maxPrice == nil) {
            maxPrice = @"0";
        }
        [adView setExtraParameterForKey:@"jC7Fp" value:maxPrice];
    }
    
    if (request.unitGroup.unitGroupType == ATUnitGroupTypeDynamicHB) {
        // 关闭预缓存
       [adView setExtraParameterForKey:@"disable_precache" value:@"true"];
        // 暂停自动刷新
        [adView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
        [adView stopAutoRefresh];
    }
    
    UIView *bannerView = (UIView *)adView;
    bannerView.frame = [request.unitGroup.content[@"unit_type"] boolValue] ? CGRectMake(0, 0, 300, 250) : CGRectMake(0, 0, 320, 50);
    [adView loadAd];
    request.customObject = adView;
}

#pragma mark - ATAdFormatSplash
- (void)startLoadSplashAdWithRequest:(AlexMaxBiddingRequest *)request {
    MAAppOpenAd *splashAd = [[MAAppOpenAd alloc] initWithAdUnitIdentifier:request.unitGroup.content[@"unit_id"] sdk:[ALSdk shared]];
    splashAd.delegate = (AlexMaxSplashCustomEvent *)request.customEvent;
    // 动态出价设置最大价格
    if ([request.extraInfo.allKeys containsObject: kATAdapterCustomInfoMaxFilledPriceKey]) {
        NSString *maxPrice = request.extraInfo[kATAdapterCustomInfoMaxFilledPriceKey];
        if (maxPrice == nil) {
            maxPrice = @"0";
        }
        [splashAd setExtraParameterForKey:@"jC7Fp" value:maxPrice];
    }
    [splashAd loadAd];
    request.customObject = splashAd;
}

#pragma mark - create C2S bidinfo
+ (void)disposeLoadSuccessCall:(NSString *)priceStr customObject:(id)customObject unitID:(NSString *)unitID {
    if ([priceStr doubleValue] < 0) {
        priceStr = @"0";
    }
    AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:unitID];
    request.price = priceStr;
    if (request == nil) {
        return;
    }
    
    ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:ATBiddingCurrencyTypeUS expirationInterval:request.unitGroup.bidTokenTime customObject:customObject];
    bidInfo.networkFirmID = request.unitGroup.networkFirmID;
    bidInfo.curRate = [self handleRateForBidInfo:bidInfo];
    
    if (request.bidCompletion) {
        request.bidCompletion(bidInfo, nil);
    }
}

+ (void)disposeLoadFailCall:(NSError *)error key:(NSString *)keyStr unitID:(NSString *)unitID {
    AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:unitID];
    if (request == nil) {
        return;
    }
    
    if (request.bidCompletion) {
        request.bidCompletion(nil, [NSError errorWithDomain:@"com.anythink.MaxSDK" code:error.code userInfo:@{
            NSLocalizedDescriptionKey:keyStr,
            NSLocalizedFailureReasonErrorKey:error}]);
    }
    [[AlexMAXNetworkC2STool sharedInstance] removeRequestItemWithUnitID:unitID];
}

+ (NSString *)handleRateForBidInfo:(ATBidInfo *)bidInfo {
    NSString *currentRate = bidInfo.curRate;
    if (!currentRate && [currentRate doubleValue] > 1) {
        return currentRate;
    }
    NSDecimalNumber *rateDecimal = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSDecimalNumber *pointDecimal = [NSDecimalNumber decimalNumberWithString:@"100"];
    if (bidInfo.networkFirmID == ATAdNetWorkSigmobType) { //US-point 100
        currentRate = [[rateDecimal decimalNumberByMultiplyingBy:pointDecimal] stringValue];
    }
    if (bidInfo.currencyType == ATBiddingCurrencyTypeCNY || bidInfo.networkFirmID == ATAdNetWorkKuaiShouType) { //CNY-point
        NSDecimalNumber *c2uRateDecimal = [NSDecimalNumber decimalNumberWithString:[ATBidInfo getExchRateC2U:bidInfo.placementID]];
        currentRate = [[[rateDecimal decimalNumberByDividingBy:c2uRateDecimal] decimalNumberByMultiplyingBy:pointDecimal] stringValue];
    }
    return currentRate;
}

@end
