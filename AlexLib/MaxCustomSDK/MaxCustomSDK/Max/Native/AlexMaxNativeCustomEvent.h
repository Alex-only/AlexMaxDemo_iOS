

#import <AnyThinkNative/AnyThinkNative.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kAlexMAXNativeAssetsExpressAdViewKey;

@interface AlexMaxNativeCustomEvent : ATNativeADCustomEvent<MANativeAdDelegate,MAAdRevenueDelegate>

@property(nonatomic, weak) id maxNativeAdLoader;

@property (nonatomic, readwrite) MAAd *maxAd;

- (void)maxExpressWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView;

- (void)maxSelfRenderWithMaAd:(MAAd * _Nonnull)ad;

- (void)maxNativeRenderWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView;

@end

NS_ASSUME_NONNULL_END
