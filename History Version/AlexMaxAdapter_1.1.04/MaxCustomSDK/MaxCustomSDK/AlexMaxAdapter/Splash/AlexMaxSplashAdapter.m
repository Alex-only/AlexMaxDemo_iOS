

#import "AlexMaxSplashAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxBiddingRequest.h"
#import "AlexMaxC2SBiddingRequestManager.h"
#import "AlexMaxSplashCustomEvent.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxNativeLoader.h"
#import "AlexMaxNativeAdapter.h"

@interface AlexMaxSplashAdapter()
@property (nonatomic, strong) MAAppOpenAd *splashAd;
@property(nonatomic, strong) AlexMaxSplashCustomEvent *customEvent;
@property (atomic, copy) void(^requestCompletionBlock)( NSArray<NSDictionary *> * _Nullable assets,  NSError * _Nullable error);

@end

@implementation AlexMaxSplashAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

- (void)callbackLoadFailedWithError:(NSError *)error localInfo:(NSDictionary *)localInfo serverInfo:(NSDictionary *)serverInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    self.customEvent = [[AlexMaxSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    self.customEvent.requestCompletionBlock = completion;
    [self.customEvent trackSplashAdLoadFailed:error];
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if ([AlexMaxBaseManager isLimitCOPPA]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin SDK 13.0.0 or higher does not support child users.", NSLocalizedFailureReasonErrorKey:@"1011"}];
        [self callbackLoadFailedWithError:error localInfo:localInfo serverInfo:serverInfo completion:completion];
        return;
    }
    
    self.requestCompletionBlock = completion;
    
    NSNumber *adtype = serverInfo[@"ad_type"];
    if (adtype && [adtype integerValue] == 0) {
        
        self.customEvent = [[AlexMaxSplashCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kATAdapterCustomInfoUnitGroupModelKey];
       
        AlexMaxNativeDelegate *maxNativeDelegate = [[AlexMaxNativeDelegate alloc] init];

        if (unitGroupModel.unitGroupType == ATUnitGroupTypeC2S) {
            AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:serverInfo[@"unit_id"]];
            maxNativeDelegate = request.nativeNewCustomEvent;
        }
        maxNativeDelegate.delegate = self.customEvent;
        maxNativeDelegate.serverInfo = serverInfo;
        
        AlexMaxNativeLoader *nativeLoader = [[AlexMaxNativeLoader alloc] init];
        [nativeLoader loadNativeWithCustomEven:maxNativeDelegate serverInfo:serverInfo localInfo:localInfo];
        self.customEvent.protectLifeCycleObject = nativeLoader;
        return;
    }
    
    [AlexMaxBaseManager initWithCustomInfo:serverInfo localInfo:localInfo maxInitFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
            if (bidId) {
                AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:serverInfo[@"unit_id"]];
                if (!request) {
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin Splash ad request is nil", NSLocalizedFailureReasonErrorKey:@"1011"}];
                    [self callbackLoadFailedWithError:error localInfo:localInfo serverInfo:serverInfo completion:completion];
                    return;
                }
                
                self.customEvent = (AlexMaxSplashCustomEvent *)request.customEvent;
                self.customEvent.requestCompletionBlock = completion;
                
                ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
                self.customEvent.maxAd = bidInfo.customObject;
                if (request.customObject) {
                    self.splashAd = request.customObject;
                    if (self.splashAd.isReady) {
                        [self.customEvent trackSplashAdLoaded:self.splashAd];
                    } else {
                        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin Splash ad is not ready", NSLocalizedFailureReasonErrorKey:@"1011"}];
                        [self.customEvent trackSplashAdLoadFailed:error];
                    }
                }
                // remove requestItem
                [[AlexMAXNetworkC2STool sharedInstance] removeRequestItemWithUnitID:serverInfo[@"unit_id"]];
            } else {
                self.customEvent = [[AlexMaxSplashCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
                self.customEvent.requestCompletionBlock = completion;
                
                self.splashAd = [[MAAppOpenAd alloc] initWithAdUnitIdentifier:serverInfo[@"unit_id"] sdk:[ALSdk shared]];
                self.customEvent.splashAd = self.splashAd;
                self.splashAd.delegate = self.customEvent;
                [self.splashAd loadAd];
            }
        });
    }];
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    MAAppOpenAd *splashAd = customObject;
    if ([splashAd respondsToSelector:@selector(isReady)]) {
        return splashAd.isReady;
    }
    return splashAd;
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    MAAppOpenAd *splashAd = splash.customObject;
    [splashAd showAd];
}

#pragma mark - C2S
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    
    if ([AlexMaxBaseManager isLimitCOPPA]) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin SDK 13.0.0 or higher does not support child users.", NSLocalizedFailureReasonErrorKey:@"1011"}]);
        }
        return;
    }
    
    ATUnitGroupJointAdType adtype = unitGroupModel.jointAdType;
    if (adtype == ATUnitGroupJointAdNativeType) {
        [AlexMaxNativeAdapter bidRequestWithPlacementModel:placementModel unitGroupModel:unitGroupModel info:info completion:completion];
        return;
    }
    
    AlexMaxSplashCustomEvent *customEvent = [[AlexMaxSplashCustomEvent alloc]initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    customEvent.networkAdvertisingID = unitGroupModel.content[@"unit_id"];
    
    AlexMaxBiddingRequest *maxRequest = [AlexMaxBiddingRequest new];
    maxRequest.customEvent = customEvent;
    maxRequest.unitGroup = unitGroupModel;
    maxRequest.placementID = placementModel.placementID;
    maxRequest.bidCompletion = completion;
    maxRequest.unitID = unitGroupModel.content[@"unit_id"];
    maxRequest.extraInfo = info;
    maxRequest.adType = ATAdFormatSplash;
    [[AlexMaxC2SBiddingRequestManager sharedInstance] startWithRequestItem:maxRequest];
}

@end
