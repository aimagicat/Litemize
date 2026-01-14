//
//  LMSigmobRewardedVideoAdapter.m
//  LitemizeSDK
//
//  Sigmob 激励视频广告 Adapter 实现
//

#import "LMSigmobRewardedVideoAdapter.h"
#import "../LMSigmobAdapterLog.h"
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMRewardedVideoAd.h>

@interface LMSigmobRewardedVideoAdapter () <LMRewardedVideoAdDelegate>

@property(nonatomic, weak) id<AWMCustomRewardedVideoAdapterBridge> bridge;

/// 当前加载的激励视频广告实例
@property(nonatomic, strong, nullable) LMRewardedVideoAd *rewardedVideoAd;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *placementId;

/// 是否已经触发激励（用于在关闭时判断是否需要通知激励成功）
@property(nonatomic, assign) BOOL hasRewarded;

@end

@implementation LMSigmobRewardedVideoAdapter

#pragma mark - AWMCustomRewardedVideoAdapter Protocol Implementation

- (instancetype)initWithBridge:(id<AWMCustomRewardedVideoAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    // 返回广告是否准备好
    return self.rewardedVideoAd != nil && self.rewardedVideoAd.isLoaded;
}

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"RewardedVideo loadAdWithPlacementId: %@, parameter: %@", placementId, parameter);

    if (!placementId || placementId.length == 0) {
        LMSigmobLog(@"⚠️ RewardedVideo loadAdWithPlacementId: placementId 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobRewardedVideoAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"placementId 为空"}];
        // 通知 ToBid SDK 加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAd:didLoadFailWithError:ext:)]) {
            [self.bridge rewardedVideoAd:self didLoadFailWithError:error ext:@{}];
        }
        return;
    }

    self.placementId = placementId;
    self.hasCalledLoadSuccess = NO;
    self.hasCalledLoadFailed = NO;
    self.hasRewarded = NO;

    // 从 parameter 中获取用户 ID（如果有）
    NSString *userId = nil;
    if (parameter && parameter.extra) {
        userId = [parameter.extra objectForKey:@"userID"];
    }

    // 如果 parameter 中有 adRequest，也可以从 adRequest 中获取 userId
    if (!userId && self.bridge && [self.bridge respondsToSelector:@selector(adRequest)]) {
        WindMillAdRequest *request = [self.bridge adRequest];
        if (request && request.userId) {
            userId = request.userId;
        }
    }

    // 设置用户 ID（如果存在）
    if (userId && userId.length > 0) {
        [LMAdSDK config:^(LMAdSDKConfigBuilder *builder) {
            builder.userId = userId;
        }];
    }

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 先释放上一个广告实例（如果存在）
        if (self.rewardedVideoAd) {
            LMSigmobLog(@"RewardedVideo 释放上一个激励视频广告实例");
            [self destory];
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:placementId type:LMAdSlotTypeRewardedVideo];

        // 创建激励视频广告实例
        self.rewardedVideoAd = [[LMRewardedVideoAd alloc] initWithSlot:slot];
        // 设置代理为 self，用于接收广告回调
        self.rewardedVideoAd.delegate = self;

        // 开始加载广告
        [self.rewardedVideoAd loadAd];
    });
}

- (BOOL)showAdFromRootViewController:(UIViewController *)viewController parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"RewardedVideo showAdFromRootViewController: %@, parameter: %@", viewController, parameter);

    if (!self.rewardedVideoAd) {
        LMSigmobLog(@"⚠️ RewardedVideo showAdFromRootViewController: rewardedVideoAd 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobRewardedVideoAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告对象不存在"}];
        // 通知 ToBid SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAdDidShowFailed:error:)]) {
            [self.bridge rewardedVideoAdDidShowFailed:self error:error];
        }
        return NO;
    }

    if (!viewController) {
        LMSigmobLog(@"⚠️ RewardedVideo showAdFromRootViewController: viewController 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobRewardedVideoAdapter"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey : @"viewController 为空"}];
        // 通知 ToBid SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAdDidShowFailed:error:)]) {
            [self.bridge rewardedVideoAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 检查广告是否已加载
    if (!self.rewardedVideoAd.isLoaded) {
        LMSigmobLog(@"⚠️ RewardedVideo showAdFromRootViewController: 广告尚未加载完成");
        NSError *error = [NSError errorWithDomain:@"LMSigmobRewardedVideoAdapter"
                                             code:-4
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成"}];
        // 通知 ToBid SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAdDidShowFailed:error:)]) {
            [self.bridge rewardedVideoAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 展示广告
    [self.rewardedVideoAd showFromViewController:viewController];
    return YES;
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    LMSigmobLog(@"RewardedVideo didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：此方法是否触发由 ToBid SDK 决定
    if (result) {
        // 获取竞价价格（如果 result 有 price 属性）
        if ([result respondsToSelector:@selector(price)]) {
            NSNumber *price = [result performSelector:@selector(price)];
            LMSigmobLog(@"RewardedVideo 收到竞价结果，价格：%@", price);
        }
        // 可以在这里处理其他竞价相关信息
    }
}

- (void)destory {
    LMSigmobLog(@"RewardedVideo destory");

    // 清理资源
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd.delegate = nil;
        self.rewardedVideoAd = nil;
    }
    self.hasRewarded = NO;
}

#pragma mark - LMRewardedVideoAdDelegate

/// 广告加载成功
- (void)lm_rewardedVideoAdDidLoad:(LMRewardedVideoAd *)rewardedAd {
    LMSigmobLog(@"RewardedVideo lm_rewardedVideoAdDidLoad: %@", rewardedAd);

    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 获取 eCPM（用于客户端竞价）
        NSString *ecpm = [rewardedAd getEcpm];
        NSDictionary *ext = @{};
        if (ecpm && ecpm.length > 0) {
            // 单位分
            NSString *ecpmString = [NSString stringWithFormat:@"%.2f", ecpm.floatValue / 1000.0];
            ext = @{AWMMediaAdLoadingExtECPM : ecpmString};
            LMSigmobLog(@"RewardedVideo 客户端竞价，ECPM: %@", ecpm);
        }

        // 通知 ToBid SDK 广告数据返回（用于客户端竞价）
        if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAd:didAdServerResponseWithExt:)]) {
            [self.bridge rewardedVideoAd:self didAdServerResponseWithExt:ext];
        }

        // 通知 ToBid SDK 广告加载成功
        if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAdDidLoad:)]) {
            [self.bridge rewardedVideoAdDidLoad:self];
        }
    }
}

/// 广告加载失败
- (void)lm_rewardedVideoAd:(LMRewardedVideoAd *)rewardedAd didFailWithError:(NSError *)error {
    LMSigmobLog(@"RewardedVideo lm_rewardedVideoAd:didFailWithError: %@", error);

    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;

        // 通知 ToBid SDK 广告加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAd:didLoadFailWithError:ext:)]) {
            [self.bridge rewardedVideoAd:self didLoadFailWithError:error ext:@{}];
        }

        // 清理资源
        [self destory];
    }
}

/// 广告即将展示
- (void)lm_rewardedVideoAdWillVisible:(LMRewardedVideoAd *)rewardedAd {
    LMSigmobLog(@"RewardedVideo lm_rewardedVideoAdWillVisible: %@", rewardedAd);

    // 通知 ToBid SDK 广告即将展示
    if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAdDidVisible:)]) {
        [self.bridge rewardedVideoAdDidVisible:self];
    }
}

/// 广告被点击
- (void)lm_rewardedVideoAdDidClick:(LMRewardedVideoAd *)rewardedAd {
    LMSigmobLog(@"RewardedVideo lm_rewardedVideoAdDidClick: %@", rewardedAd);

    // 通知 ToBid SDK 广告被点击
    if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAdDidClick:)]) {
        [self.bridge rewardedVideoAdDidClick:self];
    }
}

/// 广告已关闭
- (void)lm_rewardedVideoAdDidClose:(LMRewardedVideoAd *)rewardedAd {
    LMSigmobLog(@"RewardedVideo lm_rewardedVideoAdDidClose: %@", rewardedAd);

    // 通知 ToBid SDK 广告已关闭
    if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAdDidClose:)]) {
        [self.bridge rewardedVideoAdDidClose:self];
    }

    // 清理资源
    [self destory];
}

/// 触发激励（用户完成观看任务）
- (void)lm_rewardedVideoAdDidRewardEffective:(LMRewardedVideoAd *)rewardedAd {
    LMSigmobLog(@"RewardedVideo lm_rewardedVideoAdDidRewardEffective: %@", rewardedAd);

    // 标记已触发激励
    self.hasRewarded = YES;

    // 通知 ToBid SDK 激励成功
    // 注意：WindMillRewardInfo 需要从 rewardedAd 中获取相关信息
    // 如果 LitemizeSDK 没有提供奖励信息，可以创建一个默认的 WindMillRewardInfo
    if (self.bridge && [self.bridge respondsToSelector:@selector(rewardedVideoAd:didRewardSuccessWithInfo:)]) {
        // 创建奖励信息（根据实际需求调整）
        WindMillRewardInfo *rewardInfo = [[WindMillRewardInfo alloc] init];
        rewardInfo.userId = [LMAdSDK userId];
        rewardInfo.isCompeltedView = rewardedAd.isServerReward;
        // 如果 rewardedAd 有奖励相关信息，可以在这里设置
        // rewardInfo.rewardName = @"";
        // rewardInfo.rewardAmount = @(0);
        [self.bridge rewardedVideoAd:self didRewardSuccessWithInfo:rewardInfo];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    LMSigmobLog(@"RewardedVideo dealloc");

    // 确保清理资源
    [self destory];
}

@end
