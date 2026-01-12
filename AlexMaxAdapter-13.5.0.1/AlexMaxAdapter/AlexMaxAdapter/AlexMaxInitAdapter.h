
#import <AnyThinkSDK/ATBaseInitAdapter.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, AlexMaxNativeRenderType) {
    AlexMaxNativeRenderTypeTemplate = 1,
    AlexMaxNativeRenderTypeSelfRendering = 2,
};

@class ATUnitGroupModel,ATAdCustomEvent,ATBidInfo;


@interface AlexMaxInitAdapter : ATBaseInitAdapter

+ (NSString *)getMaxFormat:(MAAd *)maxAd;

@end

NS_ASSUME_NONNULL_END
