

#import "AlexMaxInitAdapter.h"
#import "AlexMaxSafeThreadArray.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AppLovinSDK/ALSdkConfiguration.h>

@interface AlexMaxInitAdapter()

@property (nonatomic, strong) ATAdInitArgument *adInitArgument;

@end

@implementation AlexMaxInitAdapter



#pragma mark - 初始化
- (void)initWithInitArgument:(ATAdInitArgument *)adInitArgument {

    self.adInitArgument = adInitArgument;
    if (self.isLimitCOPPA) {
        [self notificationNetworkInitFail:[NSError errorWithDomain:@"AppLovin SDK 13.0.0 or higher does not support child users." code:1011 userInfo:@{}]];
        return;
    }
    
    if (ATGeneralManage.hasSetMute)
    {
        [ALSdk shared].settings.muted  = [ATSDKGlobalSetting sharedManager].isMute;
        [ATAdLogger logMessage:[NSString stringWithFormat:@"[ATAdapter][MAX] set Ad mute:%@", [ATSDKGlobalSetting sharedManager].isMute?@"YES":@"NO"] type:ATLogTypeInternal];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [AlexMaxInitAdapter setPersonalizedStateWithAdInitArgument:adInitArgument];

        ALSdkSettings *sdkSettings = [ALSdk shared].settings;
        [AlexMaxInitAdapter setSdkSettings:sdkSettings adInitArgument:adInitArgument];
        [weakSelf initMaxSdk];
    });
}



- (void)initMaxSdk {
   
    
    // Create the initialization configuration
    ALSdkInitializationConfiguration *initConfig = [ALSdkInitializationConfiguration configurationWithSdkKey:self.adInitArgument.serverContentDic[@"sdk_key"] builderBlock:^(ALSdkInitializationConfigurationBuilder *builder) {
        builder.mediationProvider = ALMediationProviderMAX;
    }];
    
    if(self.adInitArgument.localInfoDic[kATAdLoadingExtraUserIDKey] != nil)
    {
        [ALSdk shared].settings.userIdentifier = self.adInitArgument.localInfoDic[kATAdLoadingExtraUserIDKey];
    }
    else
    {
        [ALSdk shared].settings.userIdentifier = self.adInitArgument.serverContentDic[@"userID"];
    }
    
    if ([self whetherCallApplovinInitAPI]) {
        [self callApplovinInitApi];
    } else {
        [self callMaxInitApiConfig:initConfig];
    }
}

- (void)callMaxInitApiConfig:(ALSdkInitializationConfiguration *)initConfig {
    // Initialize the SDK with the configuration
    __weak typeof(self) weakSelf = self;
    [[ALSdk shared] initializeWithConfiguration:initConfig completionHandler:^(ALSdkConfiguration *sdkConfig) {
        [weakSelf notificationNetworkInitSuccess];
    }];
}

- (BOOL)isLimitCOPPA {
    
    if (self.adInitArgument.complyWithCOPPA && [ALSdk versionCode] > 13000000) {
        return YES;
    }
    return NO;
}

- (void)callApplovinInitApi {
    NSMutableDictionary *info = [self.adInitArgument.serverContentDic mutableCopy];
    [info addEntriesFromDictionary:self.adInitArgument.localInfoDic];
    info[@"sdkkey"] = self.adInitArgument.serverContentDic[@"sdk_key"] ? self.adInitArgument.serverContentDic[@"sdk_key"] : @"";
    self.adInitArgument.serverContentDic = info;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Class clazz = NSClassFromString(@"ATApplovinInitManage");
    SEL initSelector = NSSelectorFromString(@"initApplovinWithArgument:finishBlock:");
    if (clazz && [clazz respondsToSelector:initSelector])
    {
        __weak typeof(self) weakSelf = self;
        void (^initFinishCompletion)(void) = ^(void) {
            __typeof__(self) strongSelf = weakSelf;
            if(strongSelf)
            {
                [strongSelf notificationNetworkInitSuccess];
            }
        };
        [clazz performSelector:initSelector withObject:self.adInitArgument withObject:initFinishCompletion];
    }
#pragma clang diagnostic pop
}


- (BOOL)whetherCallApplovinInitAPI {
    if (NSClassFromString(@"ATApplovinInitManage") != nil) {
        return YES;
    }
    return NO;
}

#pragma mark - 隐私权限
+ (void)setPersonalizedStateWithAdInitArgument:(ATAdInitArgument *)adInitArgument {
    // privacy setting
    BOOL state = adInitArgument.personalizedAdState == ATNonpersonalizedAdStateType ? YES : NO;
    if (state) {
        [ALPrivacySettings setHasUserConsent:NO];
    } else {
        [ALPrivacySettings setHasUserConsent:YES];
    }
}

#pragma mark - 动态出价
+ (void)setSdkSettings:(ALSdkSettings *)sdkSettings adInitArgument:(ATAdInitArgument *)adInitArgument {
    __block NSString *adUnitIds=@"";
    __block NSString *adFormats=@"";
    
    NSDictionary *dynamicHBAdUnitIds = adInitArgument.extraDic[@"ATDynamicHBAdUnitIdsKey"];
    [dynamicHBAdUnitIds enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
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

