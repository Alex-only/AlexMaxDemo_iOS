

#import <AnyThinkNative/AnyThinkNative.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxCommendAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kAlexMAXNativeAssetsExpressAdViewKey;

@interface AlexMaxNativeCustomEvent : ATNativeADCustomEvent<AlexMaxCommendAdDelegate>

@property(nonatomic, weak) id maxNativeAdLoader;

@property (nonatomic, readwrite) MAAd *maxAd;

@end

NS_ASSUME_NONNULL_END
