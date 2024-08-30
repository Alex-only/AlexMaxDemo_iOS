

#import "AlexMaxBaseManager.h"
#import "AlexMaxSafeThreadArray.h"

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AppLovinSDK/ALSdkConfiguration.h>

@interface AlexMaxBaseManager()
@property (atomic, assign) BOOL isInitSucceed;
@property (nonatomic, strong) AlexMaxSafeThreadArray *blockArray;
@end

@implementation AlexMaxBaseManager

+ (instancetype)sharedManager {
    static AlexMaxBaseManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AlexMaxBaseManager alloc] init];
        sharedManager.blockArray = [AlexMaxSafeThreadArray array];
    });
    return sharedManager;
}

#pragma mark - 初始化
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo maxInitFinishBlock:(nonnull ATMaxInitFinishBlock)maxInitFinishBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setCommonSetting:serverInfo];
        
        if ([AlexMaxBaseManager sharedManager].isInitSucceed) {
            if (maxInitFinishBlock) {
                maxInitFinishBlock();
            }
            return;
        }

        if (maxInitFinishBlock) {
            [[AlexMaxBaseManager sharedManager].blockArray addObject:maxInitFinishBlock];
        }
        [self initWithCustomInfo:serverInfo localInfo:localInfo];
    });
}

+ (void)setCommonSetting:(NSDictionary * _Nonnull)serverInfo {
    ATUnitGroupModel *unitGroupModel = (ATUnitGroupModel*)serverInfo[kATAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kATAdapterCustomInfoPlacementModelKey];
    
    [AlexMaxBaseManager setPersonalizedStateWithUnitGroupModel:unitGroupModel];
    
    // for max dynamic HB to set sdkSetting
    ALSdkSettings *sdkSettings = [ALSdk shared].settings;
    [AlexMaxBaseManager setSdkSettings:sdkSettings placementModel:placementModel];
}

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:[ALSdk version] forNetwork:kATNetworkNameMax];
        
        [self initMaxSdk:serverInfo localInfo:localInfo];
    });
}

+ (void)initMaxSdk:(NSDictionary * _Nonnull)serverInfo localInfo:(NSDictionary *)localInfo {
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kATAdapterCustomInfoPlacementModelKey];
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kATAdapterCustomInfoUnitGroupModelKey];
    
    // Create the initialization configuration
    ALSdkInitializationConfiguration *initConfig = [ALSdkInitializationConfiguration configurationWithSdkKey:serverInfo[@"sdk_key"] builderBlock:^(ALSdkInitializationConfigurationBuilder *builder) {
        builder.mediationProvider = ALMediationProviderMAX;
    }];
    
    [ALSdk shared].settings.userIdentifier = unitGroupModel.content[@"userID"];
    [AlexMaxBaseManager setSdkSettings:[ALSdk shared].settings placementModel:placementModel];
    
    if ([self whetherCallApplovinInitAPI]) {
        [self callApplovinInitApi:serverInfo localInfo:localInfo unitGroupModel:unitGroupModel];
    } else {
        [self callMaxInitApi:serverInfo unitGroupModel:unitGroupModel initConfig:initConfig];
    }
}

+ (void)callMaxInitApi:(NSDictionary * _Nonnull)serverInfo unitGroupModel:(ATUnitGroupModel *)unitGroupModel initConfig:(ALSdkInitializationConfiguration *)initConfig {
    // Initialize the SDK with the configuration
    [[ALSdk shared] initializeWithConfiguration:initConfig completionHandler:^(ALSdkConfiguration *sdkConfig) {
        [self completeInitBlock];
    }];
}

+ (void)callApplovinInitApi:(NSDictionary * _Nonnull)serverInfo localInfo:(NSDictionary *)localInfo unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    NSMutableDictionary *info = serverInfo.mutableCopy;
    info[@"sdkkey"] = unitGroupModel.content[@"sdk_key"] ? unitGroupModel.content[@"sdk_key"] : @"";
    [info addEntriesFromDictionary:localInfo];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Class clazz = NSClassFromString(@"ATApplovinBaseManager");
    SEL initSelector = NSSelectorFromString(@"initWithExtraInfo:applovinInitFinishBlock:");

    if (clazz && [clazz respondsToSelector:initSelector]) {
        void (^initFinishCompletion)(void) = ^(void) {
            [self completeInitBlock];
        };
        
        [clazz performSelector:initSelector withObject:info withObject:initFinishCompletion];
    }
#pragma clang diagnostic pop
}

+ (void)completeInitBlock {
    [AlexMaxBaseManager sharedManager].isInitSucceed = YES;
    [[AlexMaxBaseManager sharedManager].blockArray enumerateObjectsUsingBlock:^(ATMaxInitFinishBlock finishBlock, NSUInteger idx, BOOL * _Nonnull stop) {
        finishBlock();
    }];
    [[AlexMaxBaseManager sharedManager].blockArray removeAllObjects];
}

+ (BOOL)whetherCallApplovinInitAPI {
    if (NSClassFromString(@"ATApplovinBaseManager") != nil) {
        return YES;
    }
    return NO;
}

#pragma mark - 隐私权限
+ (void)setPersonalizedStateWithUnitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    // privacy setting
    BOOL state = [[ATAPI sharedInstance] getPersonalizedAdState] == ATNonpersonalizedAdStateType ? YES : NO;
    if (state) {
        [ALPrivacySettings setHasUserConsent:NO];
    } else {
        [ALPrivacySettings setHasUserConsent:YES];
    }
}

#pragma mark - 动态出价
+ (void)setSdkSettings:(ALSdkSettings *)sdkSettings placementModel:(ATPlacementModel *)placementModel {
    __block NSString *adUnitIds=@"";
    __block NSString *adFormats=@"";
    [placementModel.dynamicHBAdUnitIds enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *formatStr = nil;
        switch ([key integerValue]) {
            case ATAdFormatNative:
                formatStr = [NSString stringWithFormat:@"%@", MAAdFormat.native.label];
                break;
            case ATAdFormatRewardedVideo:
                formatStr = [NSString stringWithFormat:@"%@", MAAdFormat.rewarded.label];
                break;
            case ATAdFormatBanner:
                formatStr = [NSString stringWithFormat:@"%@", MAAdFormat.banner.label];
                break;
            case ATAdFormatInterstitial:
                formatStr = [NSString stringWithFormat:@"%@", MAAdFormat.interstitial.label];
                break;
            case ATAdFormatSplash:
                formatStr = [NSString stringWithFormat:@"%@", MAAdFormat.appOpen.label];
                break;
                
            default:
                break;
        }
        
        NSString *idsStr = [obj componentsJoinedByString:@","];
        if (adUnitIds.length==0) {
            adUnitIds = idsStr;
        } else {
            adUnitIds = [NSString stringWithFormat:@"%@,%@",adUnitIds,idsStr];
        }
        
        if (adFormats.length==0) {
            adFormats = formatStr;
        } else {
            adFormats = [NSString stringWithFormat:@"%@,%@",adFormats,formatStr];
        }
    }];
    
    // 关闭预缓存
    [sdkSettings setExtraParameterForKey:@"disable_b2b_ad_unit_ids" value :adUnitIds];
    // 禁用自动重试
    [sdkSettings setExtraParameterForKey:@"disable_auto_retry_ad_formats" value: adFormats];
}

#pragma mark - other
+ (NSString *)getMaxFormat:(MAAd *)maxAd {
    NSString *maxFormat = @"";
    if (maxAd.format == MAAdFormat.interstitial) {
        maxFormat = @"INTER";
    } else if (maxAd.format == MAAdFormat.rewarded) {
        maxFormat = @"REWARDED";
    } else if (maxAd.format == MAAdFormat.banner) {
        maxFormat = @"BANNER";
    } else if (maxAd.format == MAAdFormat.native) {
        maxFormat = @"NATIVE";
    } else if (maxAd.format == MAAdFormat.mrec) {
        maxFormat = @"MREC";
    } else if (maxAd.format == MAAdFormat.leader) {
        maxFormat = @"LEADER";
    } else if (maxAd.format == MAAdFormat.rewardedInterstitial) {
        maxFormat = @"REWARDED_INTER";
    }
    return maxFormat;
}

@end

