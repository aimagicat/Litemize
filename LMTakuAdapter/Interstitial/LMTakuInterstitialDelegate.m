//
//  LMTakuInterstitialDelegate.m
//  LitemobSDK
//
//  Taku/AnyThink 插屏广告代理实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuInterstitialDelegate.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "../Base/LMTakuBaseAdapter.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMInterstitialAd.h>

@implementation LMTakuInterstitialDelegate

#pragma mark - LMInterstitialAdDelegate

/// 广告加载成功
/// @param ad 插屏广告实例
- (void)lm_interstitialAdDidLoad:(LMInterstitialAd *)ad {
    LMTakuLog(@"Interstitial", @"广告加载成功: %@", ad);

    // 通过 LitemobSDK 获取广告价格（用于 C2S 竞价）
    // 注意：LitemobSDK 的 getEcpm 返回单位已经是"分"，直接使用
    NSString *priceStr = [ad getEcpm];

    // 使用统一的 C2S 竞价信息生成方法
    NSDictionary *infoDic = [LMTakuBaseAdapter getC2SInfo:priceStr];

    // 通知 AnyThink SDK 插屏广告加载成功，并传递 C2S 价格信息
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnInterstitialAdLoadedExtra:)]) {
        LMTakuLog(@"Interstitial", @"调用 atOnInterstitialAdLoadedExtra:, infoDic = %@", infoDic);
        [self.adStatusBridge atOnInterstitialAdLoadedExtra:infoDic];
    } else {
        LMTakuLog(@"Interstitial", @"⚠️ adStatusBridge 为空或未实现 atOnInterstitialAdLoadedExtra:");
    }
}

/// 广告加载失败
/// @param ad 插屏广告实例
/// @param error 错误信息
- (void)lm_interstitialAd:(LMInterstitialAd *)ad didFailWithError:(NSError *)error {
    LMTakuLog(@"Interstitial", @"广告加载失败: %@, error = %@", ad, error);
    // 通知 AnyThink SDK 广告加载失败
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
        LMTakuLog(@"Interstitial", @"调用 atOnAdLoadFailed:, error = %@", error);
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    } else {
        LMTakuLog(@"Interstitial", @"⚠️ adStatusBridge 为空或未实现 atOnAdLoadFailed:adExtra:");
    }
}

/// 广告即将展示
/// @param ad 插屏广告实例
- (void)lm_interstitialAdWillVisible:(LMInterstitialAd *)ad {
    LMTakuLog(@"Interstitial", @"广告即将展示: %@", ad);
    // 通知 AnyThink SDK 广告展示成功
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShow:)]) {
        LMTakuLog(@"Interstitial", @"调用 atOnAdShow:");
        [self.adStatusBridge atOnAdShow:nil];
    } else {
        LMTakuLog(@"Interstitial", @"⚠️ adStatusBridge 为空或未实现 atOnAdShow:");
    }
}

/// 广告被点击
/// @param ad 插屏广告实例
- (void)lm_interstitialAdDidClick:(LMInterstitialAd *)ad {
    LMTakuLog(@"Interstitial", @"广告被点击: %@", ad);
    // 通知 AnyThink SDK 广告被点击
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdClick:)]) {
        LMTakuLog(@"Interstitial", @"调用 atOnAdClick:");
        [self.adStatusBridge atOnAdClick:nil];
    } else {
        LMTakuLog(@"Interstitial", @"⚠️ adStatusBridge 为空或未实现 atOnAdClick:");
    }
}

/// 广告已关闭
/// @param ad 插屏广告实例
- (void)lm_interstitialAdDidClose:(LMInterstitialAd *)ad {
    LMTakuLog(@"Interstitial", @"广告已关闭: %@", ad);
    // 通知 AnyThink SDK 广告已关闭
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdClosed:)]) {
        LMTakuLog(@"Interstitial", @"调用 atOnAdClosed:");
        [self.adStatusBridge atOnAdClosed:nil];
    } else {
        LMTakuLog(@"Interstitial", @"⚠️ adStatusBridge 为空或未实现 atOnAdClosed:");
    }
}

// 释放资源
- (void)dealloc {
    self.adStatusBridge = nil;
    LMTakuLog(@"Interstitial", @"LMTakuInterstitialDelegate dealloc");
}
@end
