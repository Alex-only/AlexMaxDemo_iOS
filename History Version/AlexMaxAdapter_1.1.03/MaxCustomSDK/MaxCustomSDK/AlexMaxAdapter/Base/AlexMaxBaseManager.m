

#import "AlexMaxBaseManager.h"
#import "AlexMaxSafeThreadArray.h"
#import "AlexMaxTools.h"

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import <AppLovinSDK/ALSdkConfiguration.h>

#define AlexDisableb2bAdUnitIdsKey @"disable_b2b_ad_unit_ids"

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
    if ([self isLimitCOPPA]) {
        if (maxInitFinishBlock) {
            maxInitFinishBlock();
        }
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setCommonSetting:serverInfo localInfo:localInfo];
        
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

+ (void)setCommonSetting:(NSDictionary * _Nonnull)serverInfo localInfo:(NSDictionary *)localInfo {
    ATUnitGroupModel *unitGroupModel = (ATUnitGroupModel*)serverInfo[kATAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kATAdapterCustomInfoPlacementModelKey];
    
    [AlexMaxBaseManager setPersonalizedStateWithUnitGroupModel:unitGroupModel];
    [AlexMaxBaseManager offMaxPrecacheWithUnitGroupModel:unitGroupModel];
    
    NSNumber * hasSetMuteNumber = [[ATSDKGlobalSetting sharedManager] valueForKey:@"hasSetMute"];
    
    if ([hasSetMuteNumber boolValue]) {
        [ALSdk shared].settings.muted  = [ATSDKGlobalSetting sharedManager].isMute;
        NSLog(@"%@",[NSString stringWithFormat:@"[AlexMaxAdapter][MAX] set Ad mute:%@", [ATSDKGlobalSetting sharedManager].isMute?@"YES":@"NO"]);
    }
    
    if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
        [ALSdk shared].settings.userIdentifier = localInfo[kATAdLoadingExtraUserIDKey];
    } else {
        [ALSdk shared].settings.userIdentifier = unitGroupModel.content[@"userID"];
    }
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
    
//    [AlexMaxBaseManager setSdkSettings:[ALSdk shared].settings placementModel:placementModel];
    
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

+ (BOOL)isLimitCOPPA {
    
    if ([ATAppSettingManager sharedManager].complyWithCOPPA && [ALSdk versionCode] > 13000000) {
        return YES;
    }
    return NO;
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

+ (void)offMaxPrecacheWithUnitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    NSString *unitString = unitGroupModel.content[@"unit_id"];
    @try {
        @synchronized (self) {
            if (unitString.length <= 0) {
                return;
            }
             
            NSDictionary *customExtDic = [AlexMaxTools AlexMax_convertToDictionary:unitGroupModel.customExtString];
            BOOL isPermitPreCache = [customExtDic[AlexAutoLoadSWKey] integerValue] == 2 ? NO : YES;
            
            ALSdkSettings *sdkSettings = [ALSdk shared].settings;
            NSString *extraString = sdkSettings.extraParameters[AlexDisableb2bAdUnitIdsKey];
             
            BOOL isConfigured = [extraString containsString:unitString];
             
            if (!isConfigured && isPermitPreCache) {
            }
 
            if (isConfigured && !isPermitPreCache) {
                return;
            }
             
            if (isConfigured && isPermitPreCache) {
                NSMutableArray *components = [[extraString componentsSeparatedByString:@","] mutableCopy];
                [components removeObject:unitString];
                NSString *resultString = [components componentsJoinedByString:@","];
                [sdkSettings setExtraParameterForKey:AlexDisableb2bAdUnitIdsKey value :resultString];
                return;
            }
 
            if (!isConfigured && !isPermitPreCache) {
                if (extraString.length <= 0) {
                    extraString = unitString;
                } else {
                    extraString = [NSString stringWithFormat:@"%@,%@",extraString,unitString];
                }
                if (extraString.length) {
                    [sdkSettings setExtraParameterForKey:AlexDisableb2bAdUnitIdsKey value :extraString];
                }
            }
        }
    } @catch (NSException *exception) {
    } @finally {
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

