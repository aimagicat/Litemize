//
//  LMTakuBannerDelegate.m
//  LitemobSDK
//
//  Taku/AnyThink 横幅广告代理实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuBannerDelegate.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "../Base/LMTakuBaseAdapter.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMBannerAd.h>

@implementation LMTakuBannerDelegate

#pragma mark - LMBannerAdDelegate

/// 广告加载成功
/// @param bannerAd 横幅广告实例
- (void)lm_bannerAdDidLoad:(LMBannerAd *)bannerAd {
    LMTakuLog(@"Banner", @"广告加载成功: %@", bannerAd);

    // 通过 LitemobSDK 获取广告价格（用于 C2S 竞价）
    // 注意：LitemobSDK 的 getEcpm 返回单位已经是"分"，直接使用
    NSString *priceStr = [bannerAd getEcpm];

    // 获取 Banner 视图
    UIView *bannerView = [bannerAd bannerView];

    // 使用统一的 C2S 竞价信息生成方法
    NSDictionary *infoDic = [LMTakuBaseAdapter getC2SInfo:priceStr];

    // 通知 AnyThink SDK 横幅广告加载成功，并传递 Banner 视图和 C2S 价格信息
    // 注意：横幅广告使用 atOnBannerAdLoadedWithView:adExtra: 方法
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnBannerAdLoadedWithView:adExtra:)]) {
        LMTakuLog(@"Banner", @"调用 atOnBannerAdLoadedWithView:adExtra:, bannerView = %@, infoDic = %@", bannerView, infoDic);
        [self.adStatusBridge atOnBannerAdLoadedWithView:bannerView adExtra:infoDic];
    } else {
        LMTakuLog(@"Banner", @"⚠️ adStatusBridge 为空或未实现 atOnBannerAdLoadedWithView:adExtra:");
    }
}

/// 广告加载失败
/// @param bannerAd 横幅广告实例
/// @param error 错误信息
- (void)lm_bannerAd:(LMBannerAd *)bannerAd didFailWithError:(NSError *)error {
    LMTakuLog(@"Banner", @"广告加载失败: %@, error = %@", bannerAd, error);
    // 通知 AnyThink SDK 广告加载失败
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
        LMTakuLog(@"Banner", @"调用 atOnAdLoadFailed:, error = %@", error);
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    } else {
        LMTakuLog(@"Banner", @"⚠️ adStatusBridge 为空或未实现 atOnAdLoadFailed:adExtra:");
    }
}

/// 广告即将展示
/// @param bannerAd 横幅广告实例
- (void)lm_bannerAdWillVisible:(LMBannerAd *)bannerAd {
    LMTakuLog(@"Banner", @"广告即将展示: %@", bannerAd);
    // 通知 AnyThink SDK 广告展示成功
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShow:)]) {
        LMTakuLog(@"Banner", @"调用 atOnAdShow:");
        [self.adStatusBridge atOnAdShow:nil];
    } else {
        LMTakuLog(@"Banner", @"⚠️ adStatusBridge 为空或未实现 atOnAdShow:");
    }
}

/// 广告被点击
/// @param bannerAd 横幅广告实例
- (void)lm_bannerAdDidClick:(LMBannerAd *)bannerAd {
    LMTakuLog(@"Banner", @"广告被点击: %@", bannerAd);
    // 通知 AnyThink SDK 广告被点击
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdClick:)]) {
        LMTakuLog(@"Banner", @"调用 atOnAdClick:");
        [self.adStatusBridge atOnAdClick:nil];
    } else {
        LMTakuLog(@"Banner", @"⚠️ adStatusBridge 为空或未实现 atOnAdClick:");
    }
}

/// 广告关闭
/// @param bannerAd 横幅广告实例
- (void)lm_bannerAdDidClose:(LMBannerAd *)bannerAd {
    LMTakuLog(@"Banner", @"广告已关闭: %@", bannerAd);
    // 通知 AnyThink SDK 广告已关闭
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdClosed:)]) {
        LMTakuLog(@"Banner", @"调用 atOnAdClosed:");
        [self.adStatusBridge atOnAdClosed:nil];
    } else {
        LMTakuLog(@"Banner", @"⚠️ adStatusBridge 为空或未实现 atOnAdClosed:");
    }
}

// 释放资源
- (void)dealloc {
    self.adStatusBridge = nil;
    LMTakuLog(@"Banner", @"LMTakuBannerDelegate dealloc");
}

@end
