//
//  LMTakuRewardedVideoCustomEvent.m
//  LitemizeSDK
//
//  Taku/AnyThink 激励视频广告 CustomEvent 实现
//

#import "LMTakuRewardedVideoCustomEvent.h"
#import <AnyThinkRewardedVideo/ATRewardedVideoCustomEvent.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMRewardedVideoAd.h>

@interface LMTakuRewardedVideoCustomEvent () <LMRewardedVideoAdDelegate>

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 当前的激励视频广告实例（用于在关闭时释放）
@property(nonatomic, strong, nullable) LMRewardedVideoAd *rewardedVideoAd;

/// 是否已经发放奖励（用于在关闭时判断）
@property(nonatomic, assign) BOOL rewardGranted;

@end

@implementation LMTakuRewardedVideoCustomEvent

#pragma mark - LMRewardedVideoAdDelegate

/// 广告加载成功
- (void)lm_rewardedVideoAdDidLoad:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMTakuRewardedVideoCustomEvent lm_rewardedVideoAdDidLoad: %@", rewardedAd);
    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 保存 ad 对象引用，用于后续释放
        self.rewardedVideoAd = rewardedAd;

        // 调用 Taku SDK 的加载成功回调
        [self trackRewardedVideoAdLoaded:rewardedAd adExtra:nil];
        NSLog(@"LMTakuRewardedVideoCustomEvent lm_rewardedVideoAdDidLoad: trackRewardedVideoAdLoaded");
    }
}

/// 广告加载失败
- (void)lm_rewardedVideoAd:(LMRewardedVideoAd *)rewardedAd didFailWithError:(NSError *)error {
    NSLog(@"LMTakuRewardedVideoCustomEvent lm_rewardedVideoAd:didFailWithError: %@", error);
    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;
        // 调用 Taku SDK 的加载失败回调
        [self trackRewardedVideoAdLoadFailed:error];
    }
}

/// 广告即将展示
- (void)lm_rewardedVideoAdWillVisible:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMTakuRewardedVideoCustomEvent lm_rewardedVideoAdWillVisible:");
    // 调用 Taku SDK 的展示回调
    [self trackRewardedVideoAdShow];
    // 激励视频广告展示时即开始播放，所以同时调用视频开始播放回调
    [self trackRewardedVideoAdVideoStart];
}

/// 广告被点击
- (void)lm_rewardedVideoAdDidClick:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMTakuRewardedVideoCustomEvent lm_rewardedVideoAdDidClick:");
    // 调用 Taku SDK 的点击回调
    [self trackRewardedVideoAdClick];
}

/// 广告已关闭
- (void)lm_rewardedVideoAdDidClose:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMTakuRewardedVideoCustomEvent lm_rewardedVideoAdDidClose:");
    // 调用 Taku SDK 的关闭回调，传入是否发放奖励
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];

    // 释放 ad 对象：清空 delegate 并释放引用
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd.delegate = nil;
        self.rewardedVideoAd = nil;
    }

    // 重置奖励状态
    self.rewardGranted = NO;
}

/// 触发激励（用户完成观看任务）
- (void)lm_rewardedVideoAdDidRewardEffective:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMTakuRewardedVideoCustomEvent lm_rewardedVideoAdDidRewardEffective:");
    // 设置奖励已发放
    self.rewardGranted = YES;
    // 调用 Taku SDK 的奖励回调
    [self trackRewardedVideoAdRewarded];
}

/// 获取网络单元 ID（用于 Taku SDK）
- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"] ?: @"";
}

@end
