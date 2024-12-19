

#import <AnyThinkSplash/AnyThinkSplash.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxSplashCustomEvent : ATSplashCustomEvent<MAAdDelegate>

@property(nonatomic, weak) id splashAd;

@property (nonatomic, readwrite) MAAd *maxAd;

@end

NS_ASSUME_NONNULL_END
