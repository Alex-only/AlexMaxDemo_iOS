

#import "AlexMaxSplashAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxBiddingRequest.h"
#import "AlexMaxC2SBiddingRequestManager.h"
#import "AlexMaxSplashCustomEvent.h"
#import "AlexMaxBaseManager.h"

@interface AlexMaxSplashAdapter()
@property (nonatomic, strong) MAAppOpenAd *splashAd;
@property(nonatomic, strong) AlexMaxSplashCustomEvent *customEvent;
@end

@implementation AlexMaxSplashAdapter

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
                self.customEvent = (AlexMaxSplashCustomEvent *)request.customEvent;
                self.customEvent.requestCompletionBlock = completion;
                
                ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
                self.customEvent.maxAd = bidInfo.customObject;
                if (request.customObject) {
                    self.splashAd = request.customObject;
                    if (self.splashAd.isReady) {
                        [self.customEvent trackSplashAdLoaded:self.splashAd];
                    } else {
                        [self.splashAd loadAd];
                    }
                }
                self.splashAd = request.customObject;
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
    return splashAd.isReady;
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    MAAppOpenAd *splashAd = splash.customObject;
    [splashAd showAd];
}

#pragma mark - C2S
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
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
