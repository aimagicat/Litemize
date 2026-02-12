//
//  LMTakuRewardedVideoDelegate.m
//  LitemobSDK
//
//  Taku/AnyThink 激励视频广告代理实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuRewardedVideoDelegate.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "../Base/LMTakuBaseAdapter.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMRewardedVideoAd.h>

@implementation LMTakuRewardedVideoDelegate

#pragma mark - LMRewardedVideoAdDelegate

/// 广告加载成功
/// @param rewardedAd 激励视频广告实例
- (void)lm_rewardedVideoAdDidLoad:(LMRewardedVideoAd *)rewardedAd {
    LMTakuLog(@"RewardedVideo", @"广告加载成功: %@", rewardedAd);

    // 通过 LitemobSDK 获取广告价格（用于 C2S 竞价）
    // 注意：LitemobSDK 的 getEcpm 返回单位已经是"分"，直接使用
    NSString *priceStr = [rewardedAd getEcpm];

    // 使用统一的 C2S 竞价信息生成方法
    NSDictionary *infoDic = [LMTakuBaseAdapter getC2SInfo:priceStr];

    // 通知 AnyThink SDK 激励视频广告加载成功，并传递 C2S 价格信息
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnRewardedAdLoadedExtra:)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnRewardedAdLoadedExtra:, infoDic = %@", infoDic);
        [self.adStatusBridge atOnRewardedAdLoadedExtra:infoDic];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnRewardedAdLoadedExtra:");
    }
}

/// 广告加载失败
/// @param rewardedAd 激励视频广告实例
/// @param error 错误信息
- (void)lm_rewardedVideoAd:(LMRewardedVideoAd *)rewardedAd didFailWithError:(NSError *)error {
    LMTakuLog(@"RewardedVideo", @"广告加载失败: %@, error = %@", rewardedAd, error);
    // 通知 AnyThink SDK 广告加载失败
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnAdLoadFailed:, error = %@", error);
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnAdLoadFailed:adExtra:");
    }
}

/// 广告即将展示
/// @param rewardedAd 激励视频广告实例
- (void)lm_rewardedVideoAdWillVisible:(LMRewardedVideoAd *)rewardedAd {
    LMTakuLog(@"RewardedVideo", @"广告即将展示: %@", rewardedAd);
    // 通知 AnyThink SDK 广告展示成功
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShow:)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnAdShow:");
        [self.adStatusBridge atOnAdShow:nil];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnAdShow:");
    }

    // 通知 AnyThink SDK 视频开始播放
    // 激励视频广告展示时即开始播放视频
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdVideoStart:)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnAdVideoStart:");
        [self.adStatusBridge atOnAdVideoStart:nil];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnAdVideoStart:");
    }
}

/// 广告被点击
/// @param rewardedAd 激励视频广告实例
- (void)lm_rewardedVideoAdDidClick:(LMRewardedVideoAd *)rewardedAd {
    LMTakuLog(@"RewardedVideo", @"广告被点击: %@", rewardedAd);
    // 通知 AnyThink SDK 广告被点击
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdClick:)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnAdClick:");
        [self.adStatusBridge atOnAdClick:nil];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnAdClick:");
    }
}

/// 广告已关闭
/// @param rewardedAd 激励视频广告实例
- (void)lm_rewardedVideoAdDidClose:(LMRewardedVideoAd *)rewardedAd {
    LMTakuLog(@"RewardedVideo", @"广告已关闭: %@", rewardedAd);

    // 通知 AnyThink SDK 视频播放结束
    // 广告关闭时，视频播放也应该结束
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdVideoEnd:)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnAdVideoEnd:");
        [self.adStatusBridge atOnAdVideoEnd:nil];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnAdVideoEnd:");
    }

    // 通知 AnyThink SDK 广告已关闭
    // 注意：根据 AnyThink 官方文档，参数应该传 nil，而不是空字典
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdClosed:)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnAdClosed:");
        [self.adStatusBridge atOnAdClosed:nil];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnAdClosed:");
    }
}

/// 触发激励（用户完成观看任务）
/// @param rewardedAd 激励视频广告实例
- (void)lm_rewardedVideoAdDidRewardEffective:(LMRewardedVideoAd *)rewardedAd {
    LMTakuLog(@"RewardedVideo", @"用户获得奖励: %@", rewardedAd);
    // 通知 AnyThink SDK 用户获得奖励
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnRewardedVideoAdRewarded)]) {
        LMTakuLog(@"RewardedVideo", @"调用 atOnRewardedVideoAdRewarded");
        [self.adStatusBridge atOnRewardedVideoAdRewarded];
    } else {
        LMTakuLog(@"RewardedVideo", @"⚠️ adStatusBridge 为空或未实现 atOnRewardedVideoAdRewarded");
    }
}

// 释放资源
- (void)dealloc {
    self.adStatusBridge = nil;
    LMTakuLog(@"RewardedVideo", @"LMTakuRewardedVideoDelegate dealloc");
}

@end
