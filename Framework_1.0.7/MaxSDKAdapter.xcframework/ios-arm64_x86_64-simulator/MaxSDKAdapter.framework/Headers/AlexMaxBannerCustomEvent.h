

#import <AnyThinkBanner/AnyThinkBanner.h>

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxBannerCustomEvent : ATBannerCustomEvent<MAAdDelegate,MAAdViewAdDelegate>

@property(nonatomic, weak) id adView;

@property (nonatomic, readwrite) MAAd *maxAd;

@end

NS_ASSUME_NONNULL_END
