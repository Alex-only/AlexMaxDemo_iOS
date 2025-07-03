

#import "AlexMaxBannerAdapter.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxBannerCustomEvent.h"
#import "AlexMaxBiddingRequest.h"
#import "AlexMaxC2SBiddingRequestManager.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface AlexMaxBannerAdapter ()
@property(nonatomic, strong) MAAdView *adView;
@property(nonatomic, strong) AlexMaxBannerCustomEvent *customEvent;
@end

@implementation AlexMaxBannerAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

- (void)callbackLoadFailedWithError:(NSError *)error localInfo:(NSDictionary *)localInfo serverInfo:(NSDictionary *)serverInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    self.customEvent = [[AlexMaxBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    self.customEvent.requestCompletionBlock = completion;
    [self.customEvent trackBannerAdLoadFailed:error];
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if ([AlexMaxBaseManager isLimitCOPPA]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin SDK 13.0.1 or higher does not support child users.", NSLocalizedFailureReasonErrorKey:@"1011"}];
        [self callbackLoadFailedWithError:error localInfo:localInfo serverInfo:serverInfo completion:completion];
        return;
    }
    
    [AlexMaxBaseManager initWithCustomInfo:serverInfo localInfo:localInfo maxInitFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
            if (bidId) {
                AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:serverInfo[@"unit_id"]];
                if (!request) {
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin Banner ad request is nil", NSLocalizedFailureReasonErrorKey:@"1011"}];
                    [self callbackLoadFailedWithError:error localInfo:localInfo serverInfo:serverInfo completion:completion];
                    return;
                }
                
                self.customEvent = (AlexMaxBannerCustomEvent *)request.customEvent;
                self.customEvent.requestCompletionBlock = completion;
                
                ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
                self.customEvent.maxAd = bidInfo.customObject;
                if (request.customObject) {
                    self.adView = request.customObject;
                    [self.customEvent trackBannerAdLoaded:self.adView adExtra:nil];
                }
                
                // remove requestItem
                [[AlexMAXNetworkC2STool sharedInstance] removeRequestItemWithUnitID:serverInfo[@"unit_id"]];
            } else {
                self.customEvent = [[AlexMaxBannerCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
                self.customEvent.requestCompletionBlock = completion;
                
                MAAdFormat *format = [serverInfo[@"unit_type"] boolValue] ? [MAAdFormat mrec] : [MAAdFormat banner];
                self.adView = [[MAAdView alloc] initWithAdUnitIdentifier:serverInfo[@"unit_id"] adFormat:format sdk:[ALSdk shared]];
                self.adView.delegate = self.customEvent;
                UIView *bannerView = (UIView *)self.adView;
                bannerView.frame = [serverInfo[@"unit_type"] boolValue] ? CGRectMake(0, 0, 300, 250) : CGRectMake(0, 0, 320, 50);
                [self.adView loadAd];
                self.customEvent.adView = self.adView;
            }
        });
    }];
}

#pragma mark - C2S
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    
    if ([AlexMaxBaseManager isLimitCOPPA]) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin SDK 13.0.1 or higher does not support child users.", NSLocalizedFailureReasonErrorKey:@"1011"}]);
        }
        return;
    }
    
    AlexMaxBannerCustomEvent *customEvent = [[AlexMaxBannerCustomEvent alloc]initWithInfo:info localInfo:info];
    customEvent.networkAdvertisingID = unitGroupModel.content[@"unit_id"];
    customEvent.isC2SBiding = YES;
    
    AlexMaxBiddingRequest *maxRequest = [AlexMaxBiddingRequest new];
    maxRequest.customEvent = customEvent;
    maxRequest.unitGroup = unitGroupModel;
    maxRequest.placementID = placementModel.placementID;
    maxRequest.bidCompletion = completion;
    maxRequest.unitID = unitGroupModel.content[@"unit_id"];
    maxRequest.extraInfo = info;
    maxRequest.adType = ATAdFormatBanner;
    [[AlexMaxC2SBiddingRequestManager sharedInstance] startWithRequestItem:maxRequest];
}


@end
