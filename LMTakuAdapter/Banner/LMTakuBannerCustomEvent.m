//
//  LMTakuBannerCustomEvent.m
//  LitemizeSDK
//
//  Taku/AnyThink Banner 横幅广告 CustomEvent 实现
//

#import "LMTakuBannerCustomEvent.h"
#import <AnyThinkBanner/ATBannerCustomEvent.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMBannerAd.h>

@interface LMTakuBannerCustomEvent () <LMBannerAdDelegate>

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

// 注意：bannerAd 属性已在头文件中声明，这里不需要重复声明

@end

@implementation LMTakuBannerCustomEvent

#pragma mark - LMBannerAdDelegate

/// 广告加载成功
- (void)lm_bannerAdDidLoad:(LMBannerAd *)bannerAd {
    NSLog(@"LMTakuBannerCustomEvent lm_bannerAdDidLoad: %@", bannerAd);
    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 保存 ad 对象引用，用于后续释放
        self.bannerAd = bannerAd;

        [self trackBannerAdLoaded:bannerAd adExtra:nil];
        NSLog(@"LMTakuBannerCustomEvent lm_bannerAdDidLoad: trackBannerAdLoaded");
    }
}

/// 广告加载失败
- (void)lm_bannerAd:(LMBannerAd *)bannerAd didFailWithError:(NSError *)error {
    NSLog(@"LMTakuBannerCustomEvent lm_bannerAd:didFailWithError: %@", error);
    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;
        // 调用 Taku SDK 的加载失败回调
        [self trackBannerAdLoadFailed:error];
    }
}

/// 广告即将展示
- (void)lm_bannerAdWillVisible:(LMBannerAd *)bannerAd {
    NSLog(@"LMTakuBannerCustomEvent lm_bannerAdWillVisible:");
    // Banner 广告没有单独的展示回调，加载成功即表示可以展示
}

/// 广告被点击
- (void)lm_bannerAdDidClick:(LMBannerAd *)bannerAd {
    NSLog(@"LMTakuBannerCustomEvent lm_bannerAdDidClick:");
    // 调用 Taku SDK 的点击回调
    [self trackBannerAdClick];
}

/// 广告关闭
- (void)lm_bannerAdDidClose:(LMBannerAd *)bannerAd {
    NSLog(@"LMTakuBannerCustomEvent lm_bannerAdDidClose:");

    // 调用 Taku SDK 的关闭回调
    // 如果实现了 delegate 的 bannerView:didTapCloseButtonWithPlacementID:extra: 方法，也会被调用
    // 注意：self.bannerView 和 self.banner 是从 ATBannerCustomEvent 基类继承的属性
    if ([self.delegate respondsToSelector:@selector(bannerView:didTapCloseButtonWithPlacementID:extra:)]) {
        NSString *placementID = self.banner.placementModel.placementID ?: @"";
        NSDictionary *extra = [self delegateExtra] ?: @{};
        [self.delegate bannerView:self.bannerView didTapCloseButtonWithPlacementID:placementID extra:extra];
    }

    [self trackBannerAdClosed];

    // 释放 ad 对象：清空 delegate 并释放引用
    if (self.bannerAd) {
        self.bannerAd.delegate = nil;
        self.bannerAd = nil;
    }
}

/// 获取网络单元 ID（用于 Taku SDK）
- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"] ?: @"";
}

@end
