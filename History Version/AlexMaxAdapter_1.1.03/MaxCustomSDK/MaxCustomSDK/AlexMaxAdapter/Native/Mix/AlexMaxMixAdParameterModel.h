//
//  AlexMaxMixAdParameterModel.h
//  MaxCustomSDK
//
//  Created by iOS_ltz on 2025/9/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,AlexMaxMixAdType) {
    AlexMaxMixAdTypeBanner = 1,
    AlexMaxMixAdTypeInterstitial,
    AlexMaxMixAdTypeSpalsh,
};
 
@interface AlexMaxMixAdParameterModel : NSObject

/// 展示广告控制器
@property (nonatomic, assign) UIViewController *showViewController;

/// 可点击视图数组
@property (nonatomic, strong) NSArray *clickableViewArray;

/// 三方network ad 对象
@property (nonatomic, strong) id networkAdObject;

/// 展示广告类型
@property (nonatomic, assign) AlexMaxMixAdType mixAdType;

/// 摇一摇 frame
@property (nonatomic, assign) CGRect shakeFrame;

@end

NS_ASSUME_NONNULL_END
