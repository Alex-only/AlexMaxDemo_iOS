
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<MAAdDelegate, MARewardedAdDelegate>

@property(nonatomic, weak) id rewardedAd;
@property (nonatomic, readwrite) MAAd *maxAd;

@end

NS_ASSUME_NONNULL_END
