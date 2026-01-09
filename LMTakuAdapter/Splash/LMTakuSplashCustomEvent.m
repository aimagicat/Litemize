//
//  LMTakuSplashCustomEvent.m
//  LitemizeSDK
//
//  Taku/AnyThink 开屏广告 CustomEvent 实现
//

#import "LMTakuSplashCustomEvent.h"
#import <AnyThinkSplash/ATSplashCustomEvent.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMSplashAd.h>

@interface LMTakuSplashCustomEvent () <LMSplashAdDelegate>

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 当前的开屏广告实例（用于在关闭时释放）
@property(nonatomic, strong, nullable) LMSplashAd *splashAd;

@end

@implementation LMTakuSplashCustomEvent

#pragma mark - LMSplashAdDelegate

/// 广告加载成功
- (void)lm_splashAdDidLoad:(LMSplashAd *)splashAd {
    NSLog(@"LMTakuSplashCustomEvent lm_splashAdDidLoad: %@", splashAd);
    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 保存 ad 对象引用，用于后续释放
        self.splashAd = splashAd;

        // 调用 Taku SDK 的加载成功回调
        [self trackSplashAdLoaded:splashAd];
        NSLog(@"LMTakuSplashCustomEvent lm_splashAdDidLoad: trackSplashAdLoaded");
    }
}

/// 广告加载失败
- (void)lm_splashAd:(LMSplashAd *)splashAd didFailWithError:(NSError *)error {
    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;
        // 调用 Taku SDK 的加载失败回调
        [self trackSplashAdLoadFailed:error];
    }
}

/// 广告即将展示
- (void)lm_splashAdWillVisible:(LMSplashAd *)splashAd {
    // 调用 Taku SDK 的展示回调
    [self trackSplashAdShow];
}

/// 广告被点击
- (void)lm_splashAdDidClick:(LMSplashAd *)splashAd {
    // 调用 Taku SDK 的点击回调
    [self trackSplashAdClick];
}

/// 广告已关闭
- (void)lm_splashAdDidClose:(LMSplashAd *)splashAd {
    // 调用 Taku SDK 的关闭回调
    [self trackSplashAdClosed:nil];
    // 释放 ad 对象：清空 delegate 并释放引用
    if (self.splashAd) {
        self.splashAd.delegate = nil;
        self.splashAd = nil;
    }
}

/// 获取网络单元 ID（用于 Taku SDK）
- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"] ?: @"";
}

@end
