//
//  AlexMaxNativeAdapter.m
//  AlexMaxAdapter
//
//  Created by GUO PENG on 2025/5/14.
//

#import "AlexMaxNativeAdapter.h"
#import "AlexMaxNativeObject.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface AlexMaxNativeAdapter()<MANativeAdDelegate,MAAdRevenueDelegate>

@property (nonatomic, strong) MANativeAdLoader *maxNativeAdLoader;

@end

@implementation AlexMaxNativeAdapter

- (void)dealloc
{
    [ATAdLogger logMessage:@"AlexMaxNativeAdapter dealloc" type:ATLogTypeExternal];
}

#pragma mark - init
+ (nullable ATBaseMediationAdapter *)getLoadAdAdapter:(nonnull ATAdMediationArgument *)argument
{
    AlexMaxNativeAdapter *adapter = [[AlexMaxNativeAdapter alloc] init];
    return adapter;
}

#pragma mark - load
- (void)loadADWithArgument:(ATAdMediationArgument *)argument
{
    [ATAdLogger logMessage:@"AlexMaxNativeAdapter loadADWithArgument" type:ATLogTypeExternal];
   self.maxNativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:argument.serverContentDic[@"unit_id"] sdk:[ALSdk shared]];
    
    self.maxNativeAdLoader.nativeAdDelegate = self;
    self.maxNativeAdLoader.revenueDelegate = self;
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S && argument.dynamicFloorPrice) {
        [self.maxNativeAdLoader setExtraParameterForKey:@"jC7Fp" value:argument.dynamicFloorPrice];
    }
    [self.maxNativeAdLoader loadAd];
}

- (BOOL)isMaxAdTemplateType
{
    if ([self.argument.serverContentDic[@"unit_type"] integerValue] == AlexMaxNativeRenderTypeTemplate)
    {
        return YES;
    }
    return NO;
}

#pragma mark - 模板
- (void)maxExpressWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView
{
    NSMutableArray *assetArray = [NSMutableArray array];
    AlexMaxNativeObject *maxNativeObject = [[AlexMaxNativeObject alloc] init];
    maxNativeObject.maxNativeAdLoader = self.maxNativeAdLoader;
    maxNativeObject.nativeAdRenderType = ATNativeAdRenderExpress;
    maxNativeObject.templateView = nativeAdView;
    maxNativeObject.nativeExpressAdViewWidth = nativeAdView.frame.size.width;
    maxNativeObject.nativeExpressAdViewHeight = nativeAdView.frame.size.height;
    maxNativeObject.ad = ad;
    [assetArray AT_addObjectVerify:maxNativeObject];
    NSDictionary *extraDic;
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S)
    {
        extraDic = [self getC2SPriceDic:ad];
    }
    [self.adStatusBridge atOnNativeAdLoadedArray:assetArray adExtra:extraDic];
}

#pragma mark - 自渲染
- (void)maxSelfRenderWithMaAd:(MAAd * _Nonnull)ad
{
    NSMutableArray *assetArray = [NSMutableArray array];
    AlexMaxNativeObject *maxNativeObject = [[AlexMaxNativeObject alloc] init];
    maxNativeObject.nativeAdRenderType = ATNativeAdRenderSelfRender;
    maxNativeObject.mediaView = [[UIView alloc] init];
    maxNativeObject.maxNativeAdLoader = self.maxNativeAdLoader;
    maxNativeObject.ad = ad;
    [assetArray AT_addObjectVerify:maxNativeObject];
    NSDictionary *extraDic;
    if (self.adStatusBridge.adapterLoadType == ATAdapterLoadTypeC2S)
    {
        extraDic = [self getC2SPriceDic:ad];
    }
    
    if ([ad isKindOfClass:[MAAd class]]) {
        MANativeAd *nativeAd = ad.nativeAd;
        maxNativeObject.title = nativeAd.title;
        maxNativeObject.mainText = nativeAd.title;
        maxNativeObject.ctaText = nativeAd.callToAction;
        maxNativeObject.rating = nativeAd.starRating;
        maxNativeObject.iconUrl = [nativeAd.icon.URL absoluteString];
    }
    
    [self.adStatusBridge atOnNativeAdLoadedArray:assetArray adExtra:extraDic];
}

#pragma mark -MANativeAdDelegate

- (void)didLoadNativeAd:(nullable MANativeAdView *)nativeAdView forAd:(MAAd *)ad;
{
    NSLog(@"AlexMaxNativeDelegate:didLoadAd---networkName:%@",ad.networkName);
    self.maxAd = ad;
    [self.adStatusBridge setNetworkCustomInfo: [self networkCustomInfo]];
    if (![ATGeneralManage isEmpty:nativeAdView] && [self isMaxAdTemplateType])
    {
        [self maxExpressWithMaAd:ad nativeAdView:nativeAdView];
        return;
    }
    [self maxSelfRenderWithMaAd:ad];
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
    NSError *loadFailError = [self getMaxError:error adUnitIdentifier:adUnitIdentifier];
    NSLog(@"%@",[NSString stringWithFormat:@"AlexMaxNativeDelegate:didFailToLoadNativeAdForAdUnitIdentifier:%@ withError:%@",adUnitIdentifier,loadFailError]);
    [self.adStatusBridge atOnAdLoadFailed:loadFailError adExtra:nil];
}

- (void)didClickNativeAd:(MAAd *)ad
{
    NSLog(@"AlexMaxNativeDelegate:didClickNativeAd---networkName:%@",ad.networkName);
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)didExpireNativeAd:(MAAd *)ad
{
    NSLog(@"AlexMaxNativeDelegate:didExpireNativeAd---networkName:%@",ad.networkName);
}

#pragma mark -MAAdRevenueDelegate

- (void)didPayRevenueForAd:(MAAd *)ad
{
    NSLog(@"AlexMaxNativeDelegate:didPayRevenueForAd::NativeAdImpression---networkName:%@",ad.networkName);
    [self.adStatusBridge atOnAdShow:nil];
}
@end
