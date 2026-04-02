//
//  LMTakuRewardedVideoAdapter.m
//  LitemobSDK
//
//  Taku/AnyThink 激励视频广告适配器实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuRewardedVideoAdapter.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "LMTakuRewardedVideoDelegate.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMRewardedVideoAd.h>
#import <UIKit/UIKit.h>

@interface LMTakuRewardedVideoAdapter ()

/// 激励视频广告代理对象，用于处理 LitemobSDK 的回调并转换为 AnyThink SDK 的回调
@property(nonatomic, strong, nullable) LMTakuRewardedVideoDelegate *rewardedVideoDelegate;

/// LitemobSDK 的激励视频广告对象
@property(nonatomic, strong, nullable) LMRewardedVideoAd *rewardedVideoAd;

@end

@implementation LMTakuRewardedVideoAdapter

#pragma mark - Lazy Properties

/// 懒加载激励视频广告代理对象
- (LMTakuRewardedVideoDelegate *)rewardedVideoDelegate {
    if (_rewardedVideoDelegate == nil) {
        _rewardedVideoDelegate = [[LMTakuRewardedVideoDelegate alloc] init];
        // 设置 AnyThink SDK 的广告状态桥接对象
        _rewardedVideoDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _rewardedVideoDelegate;
}

#pragma mark - Ad Load

/// 加载激励视频广告
/// @param argument 包含服务器下发和本地配置的参数
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    // 从 argument 对象中获取必要的加载信息
    NSDictionary *serverContentDic = argument.serverContentDic ?: @{};
    NSDictionary *localInfoDic = argument.localInfoDic ?: @{};

    // 获取广告位 ID（slot_id）
    NSString *slotId = serverContentDic[@"slot_id"];

    // 参数校验
    if (!slotId || slotId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LMTakuRewardedVideoAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slot_id 不能为空，请在后台配置 slot_id 参数"}];
        // 通知 AnyThink SDK 加载失败
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }

    // 在主线程创建并加载广告
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        // 先释放上一个激励视频广告实例（如果存在）
        if (strongSelf.rewardedVideoAd) {
            strongSelf.rewardedVideoAd.delegate = nil;
            strongSelf.rewardedVideoAd = nil;
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeRewardedVideo];

        // 创建激励视频广告实例
        strongSelf.rewardedVideoAd = [[LMRewardedVideoAd alloc] initWithSlot:slot];
        // 设置代理为 rewardedVideoDelegate，用于接收广告回调
        strongSelf.rewardedVideoAd.delegate = strongSelf.rewardedVideoDelegate;

        // 开始加载广告
        [strongSelf.rewardedVideoAd loadAd];
    });
}

#pragma mark - Ad Show

/// 展示激励视频广告
/// @param viewController 展示广告时传入的 UIViewController
- (void)showRewardedVideoInViewController:(UIViewController *)viewController {
    // 参数校验
    if (!viewController) {
        NSError *error = [NSError errorWithDomain:@"LMTakuRewardedVideoAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"viewController 不能为空"}];
        // 通知 AnyThink SDK 展示失败
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShowFailed:extra:)]) {
            [self.adStatusBridge atOnAdShowFailed:error extra:nil];
        }
        return;
    }

    // 检查广告是否已加载且有效
    if (!self.rewardedVideoAd || !self.rewardedVideoAd.isLoaded || !self.rewardedVideoAd.isAdValid) {
        NSError *error = [NSError errorWithDomain:@"LMTakuRewardedVideoAdapter"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成或已过期"}];
        // 通知 AnyThink SDK 展示失败
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShowFailed:extra:)]) {
            [self.adStatusBridge atOnAdShowFailed:error extra:nil];
        }
        return;
    }

    // 展示广告
    [self.rewardedVideoAd showFromViewController:viewController];
}

#pragma mark - Ad Ready

/// 检查激励视频广告是否准备就绪
/// @param info 广告信息字典
/// @return YES 表示广告已准备就绪，NO 表示未准备就绪
- (BOOL)adReadyRewardedWithInfo:(NSDictionary *)info {
    // 检查广告是否已加载且有效
    return self.rewardedVideoAd != nil && self.rewardedVideoAd.isLoaded && self.rewardedVideoAd.isAdValid;
}

#pragma mark - Dealloc

- (void)dealloc {
    LMTakuLog(@"RewardedVideo", @"LMTakuRewardedVideoAdapter dealloc");
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd.delegate = nil;
        [self.rewardedVideoAd close];
        self.rewardedVideoAd = nil;
    }
    self.rewardedVideoDelegate = nil;
}

@end
