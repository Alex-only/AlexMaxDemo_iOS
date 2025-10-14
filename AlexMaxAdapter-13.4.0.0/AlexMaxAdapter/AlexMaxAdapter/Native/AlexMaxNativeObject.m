//
//  AlexMaxNativeObject.m
//  AlexMaxAdapter
//
//  Created by GUO PENG on 2025/5/14.
//

#import "AlexMaxNativeObject.h"
#import <AnyThinkSDK/AnyThinkSDK.h>

@interface AlexMaxNativeObject()
@property (nonatomic, strong) MANativeAdView *nativeAdView;

@end


@implementation AlexMaxNativeObject

- (void)dealloc
{
    [ATAdLogger logMessage:@"AlexMaxNativeObject dealloc" type:ATLogTypeExternal];
    [self.maxNativeAdLoader destroyAd: self.ad];
}

- (void)setNativeADConfiguration:(ATNativeAdRenderConfig *)configuration {
    
}

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container registerArgument:(ATNativeRegisterArgument *)registerArgument {
    
    if (self.nativeAdRenderType == ATNativeAdRenderSelfRender) {
        
        [self slefRenderClickableViews:clickableViews withContainer:container registerArgument:registerArgument];
    }
    else
    {
        [self.templateView AT_mas_remakeConstraints:^(ATConstraintMaker *make) {
            make.edges.mas_equalTo(container);
        }];
    }
}

#pragma mark - 自渲染
- (void)slefRenderClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container registerArgument:(ATNativeRegisterArgument *)registerArgument {
    
    if (!self.nativeAdView) {
        self.nativeAdView = [self createMaxNativeAdView:registerArgument];
    }
    
    [container insertSubview:self.nativeAdView atIndex:0];
    if (registerArgument.containerView) {
        [self.nativeAdView addSubview:registerArgument.containerView];
        [container bringSubviewToFront:self.nativeAdView];
    }
    
    [self.nativeAdView AT_mas_remakeConstraints:^(ATConstraintMaker *make) {
        make.edges.mas_equalTo(container);
    }];
    
    
    if (registerArgument.titleLabel) {
        self.nativeAdView.titleLabel = registerArgument.titleLabel;
    }
    
    if (registerArgument.ctaLabel) {
        UIButton *ctaBtn = [[UIButton alloc]initWithFrame:registerArgument.ctaLabel.frame];
        ctaBtn.backgroundColor = registerArgument.ctaLabel.backgroundColor;
        ctaBtn.tag = registerArgument.ctaLabel.tag;
        ctaBtn.layer.cornerRadius = registerArgument.ctaLabel.layer.cornerRadius;
        ctaBtn.layer.masksToBounds = registerArgument.ctaLabel.layer.masksToBounds;
        [registerArgument.ctaLabel addSubview:ctaBtn];
        [ctaBtn AT_mas_remakeConstraints:^(ATConstraintMaker *make) {
            make.edges.mas_equalTo(registerArgument.ctaLabel);
        }];
        self.nativeAdView.callToActionButton = ctaBtn;
    }
    
    if (registerArgument.advertiserLabel) {
        self.nativeAdView.advertiserLabel = registerArgument.advertiserLabel;
    }
    
    if (registerArgument.textLabel) {
        self.nativeAdView.bodyLabel = registerArgument.textLabel;
    }
    
    if (registerArgument.iconImageView) {
        self.nativeAdView.iconImageView = registerArgument.iconImageView;
    }
    
    if (registerArgument.domainLabel) {
        self.nativeAdView.optionsContentView = registerArgument.domainLabel;
    }
    
    if (self.mediaView) {
        self.nativeAdView.mediaContentView = self.mediaView;
    }
    
    if (registerArgument.dislikeButton) {
        [container bringSubviewToFront:registerArgument.dislikeButton];
    }
    [self.maxNativeAdLoader renderNativeAdView: self.nativeAdView withAd: self.ad];

    
}

- (MANativeAdView *)createMaxNativeAdView:(ATNativeRegisterArgument *)registerArgument {
    
    MANativeAdView *nativeAdView = [[MANativeAdView alloc]init];
    __weak typeof(self) weakSelf = self;
    MANativeAdViewBinder *binder = [[MANativeAdViewBinder alloc] initWithBuilderBlock:^(MANativeAdViewBinderBuilder *builder) {
        builder.titleLabelTag = registerArgument.titleLabel.tag;
        builder.advertiserLabelTag = registerArgument.advertiserLabel.tag;
        builder.bodyLabelTag = registerArgument.textLabel.tag;
        builder.iconImageViewTag = registerArgument.iconImageView.tag;
        builder.optionsContentViewTag = registerArgument.domainLabel.tag;
        builder.mediaContentViewTag = weakSelf.mediaView.tag;
        builder.callToActionButtonTag = registerArgument.ctaLabel.tag;
        builder.starRatingContentViewTag = registerArgument.ratingLabel.tag;
    }];
    [nativeAdView bindViewsWithAdViewBinder: binder];
    return nativeAdView;
}


@end
