
#import "AlexMaxInterstitialAdapter.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxInterstitialCustomEvent.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import "AlexMaxBiddingRequest.h"
#import "AlexMaxC2SBiddingRequestManager.h"


@interface AlexMaxInterstitialAdapter ()
@property(nonatomic, strong) MAInterstitialAd *interstitialAd;
@property(nonatomic, strong) AlexMaxInterstitialCustomEvent *customEvent;
@property(nonatomic, copy) void (^completionBlock)(NSArray<NSDictionary *> *, NSError *);
@property(nonatomic, strong) NSDictionary *localInfo;
@property(nonatomic, strong) NSDictionary *serverInfo;

@end

@implementation AlexMaxInterstitialAdapter

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ATMaxStartInitSuccessKey object:nil];
}

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [AlexMaxBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    self.localInfo = localInfo;
    self.serverInfo = serverInfo;
    self.completionBlock = completion;
    
    if ([AlexMaxBaseManager sharedManager].isInitSucceed) {
        [self initSuccessStartLoad];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initSuccessStartLoad) name:ATMaxStartInitSuccessKey object:nil];
        [AlexMaxBaseManager initALSDKWithServerInfo:serverInfo];
    }
}

- (void)initSuccessStartLoad {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *bidId = self.serverInfo[kATAdapterCustomInfoBuyeruIdKey];
        AlexMaxBiddingRequest *request = [[AlexNetworkC2STool sharedInstance] getRequestItemWithUnitID:self.serverInfo[@"unit_id"]];
        
        if (bidId && request) {
            
            self.customEvent = (AlexMaxInterstitialCustomEvent *)request.customEvent;
            self.customEvent.requestCompletionBlock = self.completionBlock;
            
            ATBidInfo *bidInfo = (ATBidInfo *)self.serverInfo[kATAdapterCustomInfoBidInfoKey];
            self.customEvent.maxAd = bidInfo.customObject;
            if (request.customObject) {
                self.interstitialAd = request.customObject;
                if (self.interstitialAd.isReady) {
                    [self.customEvent trackInterstitialAdLoaded:self.interstitialAd adExtra:nil];
                } else {
                    [self.interstitialAd loadAd];
                }
            }
            // remove requestItem
            [[AlexNetworkC2STool sharedInstance] removeRequestItemWithUnitID:self.serverInfo[@"unit_id"]];
        } else {
            self.customEvent = [[AlexMaxInterstitialCustomEvent alloc]initWithInfo:self.serverInfo localInfo:self.localInfo];
            self.customEvent.requestCompletionBlock = self.completionBlock;
        
            self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:self.serverInfo[@"unit_id"] sdk:[ALSdk sharedWithKey:self.serverInfo[@"sdk_key"]]];
            self.customEvent.interstitialAd = self.interstitialAd;
            self.interstitialAd.delegate = self.customEvent;
            [self.interstitialAd loadAd];
        }
    });
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    MAInterstitialAd *interstitial = customObject;
    return interstitial.isReady;
}

+ (void)showInterstitial:(ATInterstitial*)interstitial
        inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    
    interstitial.customEvent.delegate = delegate;
    MAInterstitialAd *interstitialAd = interstitial.customObject;
    [interstitialAd showAd];
}

#pragma mark - C2S
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    AlexMaxBiddingRequest *request = [[AlexNetworkC2STool sharedInstance] getRequestItemWithUnitID:info[@"unit_id"]];
    
    if (request.customObject && request.bidCompletion) {
        MAInterstitialAd *interstitialAd = request.customObject;
        if (interstitialAd.isReady) {
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:placementModel.placementID unitGroupUnitID:unitGroupModel.unitID adapterClassString:unitGroupModel.adapterClassString token:unitGroupModel.content[@"unit_id"] price:request.price currencyType:ATBiddingCurrencyTypeUS expirationInterval:unitGroupModel.bidTokenTime customObject:nil];
            request.bidCompletion(bidInfo, nil);
            return;
        }
    }
    AlexMaxInterstitialCustomEvent *customEvent = [[AlexMaxInterstitialCustomEvent alloc]initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    customEvent.networkAdvertisingID = unitGroupModel.content[@"unit_id"];
    
    AlexMaxBiddingRequest *maxRequest = [AlexMaxBiddingRequest new];
    maxRequest.customEvent = customEvent;
    maxRequest.unitGroup = unitGroupModel;
    maxRequest.placementID = placementModel.placementID;
    maxRequest.bidCompletion = completion;
    maxRequest.unitID = unitGroupModel.content[@"unit_id"];
    maxRequest.extraInfo = info;
    maxRequest.adType = ATAdFormatInterstitial;
    [[AlexMaxC2SBiddingRequestManager sharedInstance] startWithRequestItem:maxRequest];
}

@end
