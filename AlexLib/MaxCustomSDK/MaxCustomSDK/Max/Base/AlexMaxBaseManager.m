

#import "AlexMaxBaseManager.h"
#import "AlexMaxSafeThreadArray.h"
#import "AlexMaxTools.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
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


+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo maxInitFinishBlock:(nonnull ATMaxInitFinishBlock)maxInitFinishBlock {
    
    if ([self isLimitCOPPA]) {
        if (maxInitFinishBlock) {
            maxInitFinishBlock();
        }
        return;
    }
    
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
 
+ (void)setPersonalizedStateWithUnitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    // privacy setting
    BOOL state = [[ATAPI sharedInstance] getPersonalizedAdState] == ATNonpersonalizedAdStateType ? YES : NO;
    if (state) {
        [ALPrivacySettings setHasUserConsent:NO];
    } else {
        [ALPrivacySettings setHasUserConsent:YES];
    }
}
 
+ (void)offMaxPrecacheWithUnit:(NSString *)unitString unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    
    @try {
        @synchronized (self) {
            if(unitString.length <= 0) {
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
                if (extraString.length){
                    [sdkSettings setExtraParameterForKey:AlexDisableb2bAdUnitIdsKey value :extraString];
                }
            }
        }
    } @catch (NSException *exception) {
    } @finally {
    }
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

