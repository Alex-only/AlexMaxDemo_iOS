
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, AlexMaxNativeRenderType) {
    AlexMaxNativeRenderTypeTemplate = 1,
    AlexMaxNativeRenderTypeSelfRendering = 2,
};

@class ATUnitGroupModel,ATAdCustomEvent,ATBidInfo;

#define AlexAutoLoadSWKey @"auto_load_sw"

typedef void(^ATMaxInitFinishBlock)(void);

@interface AlexMaxBaseManager : ATNetworkBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo maxInitFinishBlock:(ATMaxInitFinishBlock)maxInitFinishBlock;

+ (NSString *)getMaxFormat:(MAAd *)maxAd;
+ (BOOL)isLimitCOPPA;
@end

NS_ASSUME_NONNULL_END
