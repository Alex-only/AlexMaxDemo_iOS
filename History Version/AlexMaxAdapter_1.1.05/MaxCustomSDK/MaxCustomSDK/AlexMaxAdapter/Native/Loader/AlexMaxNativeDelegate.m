//
//  AlexMaxNativeDelegate.m
//  AlexMaxAdapter
//
//  Created by GUO PENG on 2025/2/19.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import "AlexMaxNativeDelegate.h"
#import <AnyThinkSDK/ATAdCustomEvent.h>
#import <AnyThinkSDK/ATAdManager.h>
#import "AlexMaxC2SBiddingRequestManager.h"
#import "AlexMaxBaseManager.h"
#import "AlexMaxNativeCustomEvent.h"
#import "AlexMaxTools.h"
#import "AlexMaxMixAdParameterModel.h"
#import <Masonry/Masonry.h>
#import <AnyThinkSDK/ATSelfRenderingMixSplashView.h>
#import <AnyThinkSDK/ATSelfRenderingMixInterstitialView.h>

NSString *const kAlexMAXNativeAssetsExpressAdViewKey = @"max_express_ad_view";

@interface AlexMaxNativeDelegate()

@property (nonatomic, strong) UIView *mediaView;
@end

@implementation AlexMaxNativeDelegate

#pragma mark - MANativeAdDelegate
- (void)didLoadNativeAd:(nullable MANativeAdView *)nativeAdView forAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didLoadAd---networkName:%@",ad.networkName);
    
    if ([self isMaxAdTemplateType]) {
        [self templateDidLoadNativeAd:ad nativeAdView:nativeAdView];
        return;
    }
    [self selfRenderingDidLoadNativeAd:ad];
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    
    NSError *loadFailError = [NSError errorWithDomain:(adUnitIdentifier ?: @"") code:error.code userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:error.message}];
    NSLog(@"%@",[NSString stringWithFormat:@"AlexMaxNativeCustomEvent:didFailToLoadNativeAdForAdUnitIdentifier:%@ withError:%@",adUnitIdentifier,loadFailError]);
    if ([self isMaxAdTemplateType]) {
        [self templateDidFailToLoadAd:adUnitIdentifier error:loadFailError];
        return;
    }
    [self selfRenderingDidFailToLoadAd:adUnitIdentifier error:loadFailError];
}

- (void)didClickNativeAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didClickNativeAd---networkName:%@",ad.networkName);

    if ([self.delegate respondsToSelector:@selector(trackCommendAdClick)]) {
        [self.delegate trackCommendAdClick];
    }
}

- (void)didExpireNativeAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didExpireNativeAd---networkName:%@",ad.networkName);
}

- (void)didPayRevenueForAd:(MAAd *)ad {
    NSLog(@"AlexMaxNativeCustomEvent:didPayRevenueForAd::NativeAdImpression---networkName:%@",ad.networkName);
    if ([self.delegate respondsToSelector:@selector(trackCommendAdShow)]) {
        [self.delegate trackCommendAdShow];
    }
}

#pragma mark - public
- (void)maxNativeRenderWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView {
    
    if ([self isMaxAdTemplateType]) {
        [self maxExpressWithMaAd:ad nativeAdView:nativeAdView];
    } else {
        [self maxSelfRenderWithMaAd:ad];
    }
}

#pragma mark - 自渲染
- (void)selfRenderingDidLoadNativeAd:(MAAd * _Nonnull)ad{
    self.maxAd = ad;
    if (self.isC2SBiding) {
        [self c2sPriceWithAd:ad];
        self.isC2SBiding = NO;
    } else {
        [self maxSelfRenderWithMaAd:ad];
    }
}

- (void)maxSelfRenderWithMaAd:(MAAd * _Nonnull)ad {
    
    NSMutableArray<NSDictionary*>* assetArray = [NSMutableArray<NSDictionary*> array];
    NSMutableDictionary *assetDic = [NSMutableDictionary dictionary];
    
    [assetDic setValue:self.maxNativeAdLoader forKey:kATAdAssetsCustomObjectKey];
    [assetDic setValue:self forKey:kATAdAssetsDelegateObjKey];
    [assetDic setValue:self.delegate forKey:kATAdAssetsCustomEventKey];
    [assetDic setValue:self forKey:kATAdAssetsNativeCustomEventKey];
    [assetDic setValue:@(0) forKey:kATNativeADAssetsIsExpressAdKey];
    
    if ([ad isKindOfClass:[MAAd class]]) {
        MANativeAd *nativeAd = ad.nativeAd;
        [AlexMaxTools Alex_setDict:assetDic value:nativeAd.title key:kATNativeADAssetsMainTitleKey];
        [AlexMaxTools Alex_setDict:assetDic value:nativeAd.body key:kATNativeADAssetsMainTextKey];
        [AlexMaxTools Alex_setDict:assetDic value:nativeAd.callToAction key:kATNativeADAssetsCTATextKey];
        [AlexMaxTools Alex_setDict:assetDic value:nativeAd.starRating key:kATNativeADAssetsRatingKey];
        [AlexMaxTools Alex_setDict:assetDic value:[nativeAd.icon.URL absoluteString] key:kATNativeADAssetsImageURLKey];
    }
    [assetArray addObject:assetDic];
    NSLog(@"AlexMaxNativeCustomEvent--MAX:%@",assetDic);
//    [self trackNativeAdLoaded:assetArray];
    
    if ([self.delegate respondsToSelector:@selector(trackCommendAdLoaded:)]) {
        [self.delegate trackCommendAdLoaded:assetArray];
    }
    
}
- (void)selfRenderingDidFailToLoadAd:(NSString * _Nonnull)adUnitIdentifier error:(NSError * _Nonnull)error {

    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:error key:kATSDKFailedToLoadNativeADMsg unitID:self.networkAdvertisingID];
    } else {
        if ([self.delegate respondsToSelector:@selector(trackCommendAdLoadFailed:error:)]) {
            [self.delegate trackCommendAdLoadFailed:nil error:error];
        }
//        [self trackNativeAdLoadFailed:error];
    }
}


#pragma mark - 模板
- (void)templateDidLoadNativeAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView {
    self.maxAd = ad;
    
    if (self.isC2SBiding) {
        AlexMaxBiddingRequest *request = [[AlexMAXNetworkC2STool sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:nativeAdView];
        request.nativeAds = array;
        [self c2sPriceWithAd:ad];
        self.isC2SBiding = NO;
    }else{
        [self maxExpressWithMaAd:ad nativeAdView:nativeAdView];
    }
}

- (void)templateDidFailToLoadAd:(NSString * _Nonnull)adUnitIdentifier error:(NSError * _Nonnull)error {
    
    if (self.isC2SBiding) {
        [AlexMaxC2SBiddingRequestManager disposeLoadFailCall:error key:kATSDKFailedToLoadNativeADMsg unitID:self.networkAdvertisingID];
    }else{
        if ([self.delegate respondsToSelector:@selector(trackCommendAdLoadFailed:error:)]) {
            [self.delegate trackCommendAdLoadFailed:nil error:error];
        }
//        [self trackNativeAdLoadFailed:error];
    }
}

- (void)maxExpressWithMaAd:(MAAd * _Nonnull)ad nativeAdView:(MANativeAdView * _Nullable)nativeAdView {
    
    if (!nativeAdView) {
        NSLog(@"AlexMaxNativeCustomEvent:nativeAdView is nil,use maxSelfRenderWithMaAd");
        [self maxSelfRenderWithMaAd:ad];
        return;
    }
    
    NSMutableArray<NSDictionary*>* assetArray = [NSMutableArray<NSDictionary*> array];
    
    NSMutableDictionary *assetDic = [NSMutableDictionary dictionary];
    [assetDic setValue:self.delegate forKey:kATAdAssetsCustomEventKey];
    [assetDic setValue:self forKey:kATAdAssetsNativeCustomEventKey];
    [assetDic setValue:self forKey:kATAdAssetsDelegateObjKey];
    [assetDic setValue:self.maxNativeAdLoader forKey:kATAdAssetsCustomObjectKey];
    [assetDic setValue:nativeAdView forKey:kAlexMAXNativeAssetsExpressAdViewKey];
    [assetDic setValue:@(1) forKey:kATNativeADAssetsIsExpressAdKey];
    [assetDic setValue:[NSString stringWithFormat:@"%lf",nativeAdView.frame.size.width] forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
    [assetDic setValue:[NSString stringWithFormat:@"%lf",nativeAdView.frame.size.height] forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
    
    [assetArray addObject:assetDic];
    
    if ([self.delegate respondsToSelector:@selector(trackCommendAdLoaded:)]) {
        [self.delegate trackCommendAdLoaded:assetArray];
    }
//    [self trackNativeAdLoaded:assetArray];
}

#pragma mark - native splash
- (void)nativeSplashTrackSplashAdCountdownTime:(NSInteger)skipTime {
    if ([self.delegate respondsToSelector:@selector(trackNativeSplashAdCountdownTime:)]) {
        [self.delegate trackNativeSplashAdCountdownTime:skipTime];
    }
}

- (void)registerNetWorkClickEventWithParameter:(AlexMaxMixAdParameterModel *)mixAdParameterModel {
    if (mixAdParameterModel.mixAdType == AlexMaxMixAdTypeSpalsh) {
        [self registerClickEventWithController:mixAdParameterModel.showViewController];
    }
}
- (UIView *)getNetWorkMediaViewWithParameter:(AlexMaxMixAdParameterModel *)mixAdParameterModel {
    if (mixAdParameterModel.mixAdType == AlexMaxMixAdTypeSpalsh) {
        self.mediaView = [[UIView alloc]init];
        return self.mediaView ;
    }
    return nil;
}

- (void)registerClickEventWithController:(UIViewController *)controller {
 
    MANativeAdView *nativeAdView = [self createMaxNativeAdView:controller];
    
    UIView * currentSplashView = [controller valueForKey:@"currentSplashView"];
    
    if (currentSplashView && [currentSplashView isKindOfClass:[UIView class]]) {
        [currentSplashView.superview addSubview:nativeAdView];
    }else {
        NSLog(@"[AlexMaxAdapter registerClickEventWithController: currentSplashView get error]");
        return;
    }
     
    UILabel *titleLabel;
    UILabel *textLabel;
    UIImageView *iconImageView;
    UIView *mediaView = self.mediaView;
    UILabel *domainLabel;
    UIButton *ctaButton;
    UILabel *sponsorLabel;
      
    if ([NSStringFromClass(controller.class) isEqualToString:@"ATNativeSplashViewController"]) {
    
        UIView * mixSplashView = [controller valueForKey:@"mixSplashView"];
        
        if (mixSplashView && [mixSplashView isKindOfClass:[UIView class]]) {
             
            titleLabel = [mixSplashView valueForKey:@"titleLabel"];
            textLabel = [mixSplashView valueForKey:@"textLabel"];
            iconImageView = [mixSplashView valueForKey:@"iconImageView"];
            domainLabel = [mixSplashView valueForKey:@"domainLabel"];
            ctaButton = [mixSplashView valueForKey:@"ctaButton"];
            sponsorLabel = [mixSplashView valueForKey:@"sponsorLabel"];
        }
    }
    
    if ([NSStringFromClass(controller.class) isEqualToString:@"ATSelfRenderingMixSplashViewController"]) {
     
        UIViewController *selfRenderingMixSplashViewController = controller;
        
        NSObject * selfRenderingMixSplashModel = [selfRenderingMixSplashViewController valueForKey:@"selfRenderingMixSplashModel"];
        
        titleLabel = [selfRenderingMixSplashModel valueForKey:@"titleLabel"];
        textLabel = [selfRenderingMixSplashModel valueForKey:@"textLabel"];
        iconImageView = [selfRenderingMixSplashModel valueForKey:@"iconImageView"];
        domainLabel = [selfRenderingMixSplashModel valueForKey:@"domainLabel"];
        
        UILabel *ctaLabel = [selfRenderingMixSplashModel valueForKey:@"ctaLabel"];
        if (ctaLabel && [ctaLabel isKindOfClass:[UILabel class]]) {
            ctaButton = [[UIButton alloc]initWithFrame:ctaLabel.frame];
            ctaButton.backgroundColor = ctaLabel.backgroundColor;
            ctaButton.tag = ctaLabel.tag;
            ctaButton.layer.cornerRadius = ctaLabel.layer.cornerRadius;
            ctaButton.layer.masksToBounds = ctaLabel.layer.masksToBounds;
            [ctaLabel.superview addSubview:ctaButton];
            ctaLabel.hidden = YES;
        }
    }
      
    nativeAdView.frame = currentSplashView.bounds;
    
    nativeAdView.backgroundColor = [UIColor redColor];
    currentSplashView.backgroundColor = [UIColor greenColor];
      
    [currentSplashView removeFromSuperview];
    [nativeAdView addSubview:currentSplashView];
    
    [currentSplashView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(nativeAdView);
    }];

    nativeAdView.titleLabel = titleLabel;
    nativeAdView.callToActionButton = ctaButton;
    nativeAdView.bodyLabel = textLabel;
    nativeAdView.advertiserLabel = sponsorLabel;
    nativeAdView.iconImageView = iconImageView;
    nativeAdView.optionsContentView = domainLabel;
    nativeAdView.mediaContentView = mediaView;
    [self.maxNativeAdLoader renderNativeAdView:nativeAdView withAd:self.maxAd];
}

- (void)dealloc {
    NSLog(@"AlexMaxNativeCustomEvent-----dealloc");
    if (self.maxAd) {
        [self.maxNativeAdLoader destroyAd: self.maxAd];
    }
}

//ATNativeSplashViewController
- (MANativeAdView *)createMaxNativeAdView:(UIViewController *)controller {
    
    MANativeAdView *nativeAdView = [[MANativeAdView alloc]init];
    
    UILabel *titleLabel;
    UILabel *textLabel;
    UIImageView *iconImageView;
    UIView *mediaView = self.mediaView;
    UILabel *domainLabel;
    UIImageView *mainImageView;
    UIView *ctaButton;
    UILabel *sponsorLabel;
      
    if ([NSStringFromClass(controller.class) isEqualToString:@"ATNativeSplashViewController"]) {
        
        UIView * mixSplashView = [controller valueForKey:@"mixSplashView"];
        
        if (mixSplashView) {
            titleLabel = [mixSplashView valueForKey:@"titleLabel"];
            textLabel = [mixSplashView valueForKey:@"textLabel"];
            iconImageView = [mixSplashView valueForKey:@"iconImageView"];
            domainLabel = [mixSplashView valueForKey:@"domainLabel"];
            ctaButton = [mixSplashView valueForKey:@"ctaButton"];
            sponsorLabel = [mixSplashView valueForKey:@"sponsorLabel"];
        }
    }
     
    if ([NSStringFromClass(controller.class) isEqualToString:@"ATSelfRenderingMixSplashViewController"]) {
        
        UIViewController *selfRenderingMixSplashViewController = controller;
        
        NSObject * selfRenderingMixSplashModel = [selfRenderingMixSplashViewController valueForKey:@"selfRenderingMixSplashModel"];
        
        if (selfRenderingMixSplashModel) {
            titleLabel = [selfRenderingMixSplashModel valueForKey:@"titleLabel"];
            textLabel = [selfRenderingMixSplashModel valueForKey:@"textLabel"];
            iconImageView = [selfRenderingMixSplashModel valueForKey:@"iconImageView"];
            domainLabel = [selfRenderingMixSplashModel valueForKey:@"domainLabel"];
            ctaButton = [selfRenderingMixSplashModel valueForKey:@"ctaLabel"];
        }
    }
    
    titleLabel.tag = 02201001;
    textLabel.tag = 02201002;
    iconImageView.tag = 02201003;
    mediaView.tag = 02201004;
    domainLabel.tag = 02201005;
//    mainImageView.tag = 02201006;
    ctaButton.tag = 02201007;
    sponsorLabel.tag = 0222123;
    MANativeAdViewBinder *binder = [[MANativeAdViewBinder alloc] initWithBuilderBlock:^(MANativeAdViewBinderBuilder *builder) {
        builder.titleLabelTag = titleLabel.tag;
        builder.bodyLabelTag = textLabel.tag;
        builder.iconImageViewTag = iconImageView.tag ;
        builder.mediaContentViewTag = mediaView.tag;
        builder.optionsContentViewTag = domainLabel.tag;
        builder.callToActionButtonTag =  ctaButton.tag;
        builder.advertiserLabelTag = sponsorLabel.tag ;
    }];
    [nativeAdView bindViewsWithAdViewBinder: binder];
    return nativeAdView;
}

#pragma mark - set
- (void)setMaxAd:(MAAd *)maxAd {
    _maxAd = maxAd;
    [self _maxNativeCustomEvent].maxAd = maxAd;
}
- (void)setMaxNativeAdLoader:(id)maxNativeAdLoader {
    _maxNativeAdLoader = maxNativeAdLoader;
    [self _maxNativeCustomEvent].maxNativeAdLoader = maxNativeAdLoader;
}

- (AlexMaxNativeCustomEvent *)_maxNativeCustomEvent {
    if ([self.delegate isMemberOfClass:[AlexMaxNativeCustomEvent class]]) {
        return self.delegate;
    }
    return nil;
}

#pragma mark - other
- (void)c2sPriceWithAd:(MAAd * _Nonnull)ad {
    NSString *price = [NSString stringWithFormat:@"%f",ad.revenue * 1000];
    [AlexMaxC2SBiddingRequestManager disposeLoadSuccessCall:price customObject:ad unitID:self.networkAdvertisingID];
}
- (BOOL)isMaxAdTemplateType {
    
    if ([self.serverInfo[@"unit_type"] integerValue] == AlexMaxNativeRenderTypeTemplate) {
        return YES;
    }
    return NO;
}
@end
