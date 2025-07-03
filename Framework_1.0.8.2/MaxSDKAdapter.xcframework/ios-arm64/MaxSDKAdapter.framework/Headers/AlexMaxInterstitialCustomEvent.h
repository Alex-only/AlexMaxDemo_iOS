
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import "AlexMaxInterstitialAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxInterstitialCustomEvent : ATInterstitialCustomEvent<MAAdDelegate>

@property(nonatomic, weak) id interstitialAd;

@property (nonatomic, readwrite) MAAd *maxAd;

@end

NS_ASSUME_NONNULL_END
