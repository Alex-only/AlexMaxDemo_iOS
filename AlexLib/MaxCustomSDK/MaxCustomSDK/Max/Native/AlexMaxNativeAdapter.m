
#import "AlexMaxNativeAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxBiddingRequest.h"
#import "AlexMaxC2SBiddingRequestManager.h"
#import "AlexMaxNativeCustomEvent.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxNativeRenderer.h"

@interface AlexMaxNativeAdapter()
@property(nonatomic, strong) MANativeAdLoader *maxNativeAdLoader;
@property(nonatomic, strong) AlexMaxNativeCustomEvent *customEvent;
@end

@implementation AlexMaxNativeAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    [AlexMaxBaseManager initWithCustomInfo:serverInfo localInfo:localInfo maxInitFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
            AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:serverInfo[@"unit_id"]];
            
            if (bidId && request) {
                self.customEvent = (AlexMaxNativeCustomEvent *)request.customEvent;
                self.customEvent.requestCompletionBlock = completion;
                
                ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
                self.customEvent.maxAd = bidInfo.customObject;
                if (request.customObject) {
                    self.maxNativeAdLoader = request.customObject;
                    self.customEvent.maxNativeAdLoader = self.maxNativeAdLoader;
                    [self.customEvent maxNativeRenderWithMaAd:request.customObject nativeAdView:request.nativeAds.firstObject];
                }
                // remove requestItem
                [[AlexMAXNetworkC2STool sharedInstance] removeRequestItemWithUnitID:serverInfo[@"unit_id"]];
                
            } else {
                self.customEvent = [[AlexMaxNativeCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
                self.customEvent.requestCompletionBlock = completion;
                self.maxNativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:serverInfo[@"unit_id"] sdk:[ALSdk shared]];
                
                NSLog(@"MAX--unit_id:%@--sdk_key:%@",serverInfo[@"unit_id"],serverInfo[@"sdk_key"]);
                self.customEvent.maxNativeAdLoader = self.maxNativeAdLoader;
                self.maxNativeAdLoader.nativeAdDelegate = self.customEvent;
                self.maxNativeAdLoader.revenueDelegate = self.customEvent;
                [self.maxNativeAdLoader loadAd];
            }
        });
    }];
}

+ (Class)rendererClass {
    return [AlexMaxNativeRenderer class];
}

#pragma mark - C2S
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    AlexMaxNativeCustomEvent *customEvent = [[AlexMaxNativeCustomEvent alloc]initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    customEvent.networkAdvertisingID = unitGroupModel.content[@"unit_id"];
    
    AlexMaxBiddingRequest *maxRequest = [AlexMaxBiddingRequest new];
    maxRequest.customEvent = customEvent;
    maxRequest.unitGroup = unitGroupModel;
    maxRequest.placementID = placementModel.placementID;
    maxRequest.bidCompletion = completion;
    maxRequest.unitID = unitGroupModel.content[@"unit_id"];
    maxRequest.extraInfo = info;
    maxRequest.adType = ATAdFormatNative;
    [[AlexMaxC2SBiddingRequestManager sharedInstance] startWithRequestItem:maxRequest];
}

@end
