//
//  AlexMaxNativeLoader.m
//  AnyThinkMaxAdapter
//
//  Created by GUO PENG on 2025/2/19.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import "AlexMaxNativeLoader.h"
#import "AlexMaxBaseManager.h" 
#import "AlexMAXNetworkC2STool.h"
#import "AlexMaxBiddingRequest.h"
#import "AlexMaxNativeCustomEvent.h"


@interface AlexMaxNativeLoader()

@property (nonatomic, strong) MANativeAdLoader *maxNativeAdLoader;

@property (nonatomic, strong) AlexMaxNativeDelegate  *nativeDelegate;

@end


@implementation AlexMaxNativeLoader

- (void)loadNativeWithCustomEven:(AlexMaxNativeDelegate *)nativeDelegate serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    
    self.nativeDelegate = nativeDelegate;
    
    [AlexMaxBaseManager initWithCustomInfo:serverInfo localInfo:localInfo maxInitFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
            if (bidId) {
                AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:serverInfo[@"unit_id"]];
                if (!request) {
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AppLovin Native ad request is nil", NSLocalizedFailureReasonErrorKey:@"1011"}];
                    [self callbackLoadFailedWithError:error localInfo:localInfo serverInfo:serverInfo ];
                    return;
                }
                                
                ATBidInfo *bidInfo = (ATBidInfo *)serverInfo[kATAdapterCustomInfoBidInfoKey];
                self.nativeDelegate.maxAd = bidInfo.customObject;
                
                if (request.customObject) {
                    self.nativeDelegate.maxNativeAdLoader = request.customObject;
                    [self.nativeDelegate maxNativeRenderWithMaAd:request.nativeMaxAd nativeAdView:request.nativeAds.firstObject];
                }
                // remove requestItem
                [[AlexMAXNetworkC2STool sharedInstance] removeRequestItemWithUnitID:serverInfo[@"unit_id"]];
            } else {
                self.maxNativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:serverInfo[@"unit_id"] sdk:[ALSdk shared]];
                NSLog(@"MAX--unit_id:%@--sdk_key:%@",serverInfo[@"unit_id"],serverInfo[@"sdk_key"]);
                self.nativeDelegate.maxNativeAdLoader = self.maxNativeAdLoader;
                self.maxNativeAdLoader.nativeAdDelegate = nativeDelegate;
                self.maxNativeAdLoader.revenueDelegate = nativeDelegate;
                [self.maxNativeAdLoader loadAd];
            }
        });
    }];
}

- (void)callbackLoadFailedWithError:(NSError *)error localInfo:(NSDictionary *)localInfo serverInfo:(NSDictionary *)serverInfo {
    
    if ([self.nativeDelegate.delegate respondsToSelector:@selector(trackCommendAdLoadFailed:error:)]) {
        [self.nativeDelegate.delegate trackCommendAdLoadFailed:nil error:error];
    }
    
//    self.customEvent = [[AlexMaxNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
//    self.customEvent.requestCompletionBlock = completion;
//    [self.customEvent trackNativeAdLoadFailed:error];
}
@end

