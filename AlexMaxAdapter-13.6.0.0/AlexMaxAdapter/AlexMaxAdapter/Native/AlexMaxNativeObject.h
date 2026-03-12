//
//  AlexMaxNativeObject.h
//  AlexMaxAdapter
//
//  Created by GUO PENG on 2025/5/14.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxNativeObject : ATCustomNetworkNativeAd

@property (nonatomic, strong) MANativeAdLoader *maxNativeAdLoader;

@property (nonatomic, strong) MAAd *ad;

@end

NS_ASSUME_NONNULL_END
