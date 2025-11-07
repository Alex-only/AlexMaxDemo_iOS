
#import "AlexMaxNativeAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxBiddingRequest.h"
#import "AlexMaxC2SBiddingRequestManager.h"
#import "AlexMaxNativeCustomEvent.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxNativeRenderer.h"
#import "AlexMaxNativeLoader.h"
#import "AlexMaxNativeDelegate.h"

@interface AlexMaxNativeAdapter()
@property(nonatomic, strong) MANativeAdLoader *maxNativeAdLoader;
@property(nonatomic, strong) AlexMaxNativeCustomEvent *customEvent;
@property (nonatomic, strong) AlexMaxNativeDelegate *maxNativeDelegate;
@end

@implementation AlexMaxNativeAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

- (void)callbackLoadFailedWithError:(NSError *)error localInfo:(NSDictionary *)localInfo serverInfo:(NSDictionary *)serverInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    self.customEvent = [[AlexMaxNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    self.customEvent.requestCompletionBlock = completion;
    [self.customEvent trackNativeAdLoadFailed:error];
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if ([AlexMaxBaseManager isLimitCOPPA]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin SDK 13.0.0 or higher does not support child users.", NSLocalizedFailureReasonErrorKey:@"1011"}];
        [self callbackLoadFailedWithError:error localInfo:localInfo serverInfo:serverInfo completion:completion];
        return;
    }
    
    self.customEvent = [[AlexMaxNativeCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
    self.customEvent.requestCompletionBlock = completion;
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kATAdapterCustomInfoUnitGroupModelKey];
    

    if (unitGroupModel.unitGroupType == ATUnitGroupTypeC2S) {
        AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:serverInfo[@"unit_id"]];
        self.maxNativeDelegate = request.nativeNewCustomEvent;
    } else {
        self.maxNativeDelegate = [[AlexMaxNativeDelegate alloc] init];
    }
    self.maxNativeDelegate.serverInfo = serverInfo;
    self.maxNativeDelegate.delegate = self.customEvent;
    AlexMaxNativeLoader *nativeLoader = [[AlexMaxNativeLoader alloc]init];
    [nativeLoader loadNativeWithCustomEven:self.maxNativeDelegate serverInfo:serverInfo localInfo:localInfo];
    self.customEvent.protectLifeCycleObject = nativeLoader;
    
    
//    [AlexMaxBaseManager initWithCustomInfo:serverInfo localInfo:localInfo maxInitFinishBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
//            if (bidId) {
//                AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:serverInfo[@"unit_id"]];
//                if (!request) {
//                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin Native ad request is nil", NSLocalizedFailureReasonErrorKey:@"1011"}];
//                    [self callbackLoadFailedWithError:error localInfo:localInfo serverInfo:serverInfo completion:completion];
//                    return;
//                }
//                
//                self.customEvent = (AlexMaxNativeCustomEvent *)request.customEvent;
//                self.customEvent.requestCompletionBlock = completion;
//                
//                ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
//                self.customEvent.maxAd = bidInfo.customObject;
//                if (request.customObject) {
//                    self.maxNativeAdLoader = request.customObject;
//                    self.customEvent.maxNativeAdLoader = self.maxNativeAdLoader;
//                    [self.customEvent maxNativeRenderWithMaAd:request.customObject nativeAdView:request.nativeAds.firstObject];
//                }
//                // remove requestItem
//                [[AlexMAXNetworkC2STool sharedInstance] removeRequestItemWithUnitID:serverInfo[@"unit_id"]];
//            } else {
//                self.customEvent = [[AlexMaxNativeCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
//                self.customEvent.requestCompletionBlock = completion;
//                self.maxNativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:serverInfo[@"unit_id"] sdk:[ALSdk shared]];
//                
//                NSLog(@"MAX--unit_id:%@--sdk_key:%@",serverInfo[@"unit_id"],serverInfo[@"sdk_key"]);
//                self.customEvent.maxNativeAdLoader = self.maxNativeAdLoader;
//                self.maxNativeAdLoader.nativeAdDelegate = self.customEvent;
//                self.maxNativeAdLoader.revenueDelegate = self.customEvent;
//                [self.maxNativeAdLoader loadAd];
//            }
//        });
//    }];
}

+ (Class)rendererClass {
    return [AlexMaxNativeRenderer class];
}

#pragma mark - C2S
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    if ([AlexMaxBaseManager isLimitCOPPA]) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin SDK 13.0.0 or higher does not support child users.", NSLocalizedFailureReasonErrorKey:@"1011"}]);
        }
        return;
    }
    
    AlexMaxNativeDelegate *maxNativeDelegate = [[AlexMaxNativeDelegate alloc] init];
    maxNativeDelegate.serverInfo = info;

//    AlexMaxNativeCustomEvent *customEvent = [[AlexMaxNativeCustomEvent alloc]initWithInfo:info localInfo:info];
    
    maxNativeDelegate.isC2SBiding = YES;
    maxNativeDelegate.networkAdvertisingID = unitGroupModel.content[@"unit_id"];
    
    AlexMaxBiddingRequest *maxRequest = [AlexMaxBiddingRequest new];
    maxRequest.nativeNewCustomEvent = maxNativeDelegate;
    maxRequest.unitGroup = unitGroupModel;
    maxRequest.placementID = placementModel.placementID;
    maxRequest.bidCompletion = completion;
    maxRequest.unitID = unitGroupModel.content[@"unit_id"];
    maxRequest.extraInfo = info;
    maxRequest.adType = ATAdFormatNative;
    [[AlexMaxC2SBiddingRequestManager sharedInstance] startWithRequestItem:maxRequest];
}

@end
