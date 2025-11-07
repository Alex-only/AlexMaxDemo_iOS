//
//  AlexMaxCommendAdDelegate.h
//  MaxCustomSDK
//
//  Created by iOS_ltz on 2025/9/22.
//

#ifndef AlexMaxCommendAdDelegate_h
#define AlexMaxCommendAdDelegate_h

@protocol AlexMaxCommendAdDelegate <NSObject>

- (void)trackCommendAdShow;
- (void)trackCommendAdClick;

@optional

/// 广告关闭回调,带参数
- (void)trackCommendAdCloseWithExtraDic:(NSDictionary *_Nullable)extraDic;
/// 广告即将关闭回调
- (void)trackCommendAdWillCloseWithExtraDic:(NSDictionary *_Nullable)extraDic;

/// 详情页即将展示回调
- (void)trackCommendAdDetailWillShow;

/// 详情页关闭回调
- (void)trackCommendAdDetailClose;

/// 落地页关闭
- (void)trackCommendAdLPClose:(NSDictionary *_Nullable)extraDic;;

/// 原生广告 加载成功回调
- (void)trackCommendAdLoaded:(NSArray<NSDictionary*> *_Nullable)assets;
/// 原生广告 加载失败回调
- (void)trackCommendAdLoadFailed:(NSArray<NSDictionary*> *_Nullable)assets error:(NSError *_Nullable)error;

/// 展示失败回调
- (void)trackCommendAdShowFailed:(NSError *_Nullable)error;
/// 展示成功回调
- (void)trackCommendAdShowWithExtraDic:(NSDictionary *_Nullable)extraDic;

/// 加载成功回调
- (void)trackCommendNonNaitveAdLoaded:(id _Nullable)interstitiaAd;
/// 加载失败回调
- (void)trackCommendNonNativeAdLoadFailedWithError:(NSError *_Nullable)error;

/// 广告视频开始播放回调
- (void)trackCommendAdVideoStart;
/// 广告视频开始播放结束回调
- (void)trackCommendAdVideoEnd;
/// 广告视频开始播放失败回调
- (void)trackCommendAdFailToPlayVideo:(NSError *_Nullable)error;

/// 广告激励下发回调
- (void)trackCommendAdRewardedVideoAdRewarded:(NSDictionary *_Nullable)extraDic;

/// 开屏倒计时回调
- (void)trackNativeSplashAdCountdownTime:(NSInteger)time;

/// 横幅广告加载成功回调
- (void)trackCommendBannerAdLoaded:(id _Nullable)bannerView;

/// 广告元素材加载成功,不回调成功
- (void)trackCommendMetaAdDataLoaded;
/// 广告元素材加载成功,通过策略控制是否回调成功
- (void)trackCommendMetaDataLoadSuccess:(id _Nullable)mataAdData extraDic:(NSDictionary * _Nullable)extraDic;
/// 广告渲染成功,通过策略控制是否回调成功
- (void)trackCommendAdRenderSuccess:(id _Nullable)mataAdData adExtra:(NSDictionary *_Nullable)extraDic;

/// CustomInfo参数回调
- (void)trackCommendCustomInfo:(NSDictionary *_Nullable)customInfoDic;

/// 开屏打开 ConversionVC
- (void)trackCommendSplashAdDidOpenConversionVC:(NSDictionary * _Nullable)extraDic;

/// 开屏 ZoomOutViewClick
- (void)trackCommendSplashAdZoomOutViewClick:(NSDictionary * _Nullable)extraDic;

/// 开屏 ZoomOutViewClosed
- (void)trackCommendSplashAdZoomOutViewClosed:(NSDictionary * _Nullable)extraDic;

/// 移除开屏缓存 AD
- (void)trackCommendSplashAdRemoveAd:(NSDictionary * _Nullable)extraDic;

@end

#endif /* AlexMaxCommendAdDelegate_h */
