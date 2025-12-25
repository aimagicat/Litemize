//
//  LMBUMRewardedVideoAdapter.m
//  LitemizeSDK
//
//  穿山甲（BUM）激励视频广告 Adapter 实现
//

#import "LMBUMRewardedVideoAdapter.h"
#include <Foundation/NSObjCRuntime.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMRewardedVideoAd.h>

@interface LMBUMRewardedVideoAdapter () <LMRewardedVideoAdDelegate>

/// 当前加载的激励视频广告实例
@property(nonatomic, strong, nullable) LMRewardedVideoAd *rewardedVideoAd;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *slotID;

/// 竞价类型（用于判断是否需要传入 ECPM）
@property(nonatomic, assign) NSInteger biddingType;

@end

@implementation LMBUMRewardedVideoAdapter

#pragma mark - Class Loading

/// 类加载时调用（系统自动调用）
+ (void)load {
    NSLog(@"✅ [LMBUMRewardedVideoAdapter] LMBUMRewardedVideoAdapter 类已加载到系统");
}

#pragma mark - BUMCustomRewardedVideoAdapter Protocol Implementation

/// 是否允许在当前广告展示时预加载下一个广告
- (BOOL)enablePreloadWhenCurrentIsDisplay {
    return YES;
}

/// 获取当前广告状态
- (BUMMediatedAdStatus)mediatedAdStatus {
    BUMMediatedAdStatus status = BUMMediatedAdStatusUnknown;
    if (self.rewardedVideoAd && self.rewardedVideoAd.isLoaded) {
        status.valid = BUMMediatedAdStatusValueSure;
    } else {
        status.valid = BUMMediatedAdStatusValueDeny;
    }
    return status;
}

/// 加载激励视频广告
/// @param slotID network广告位ID
/// @param parameter 广告请求的参数信息（包含用户ID、奖励名称、奖励数量等）
- (void)loadRewardedVideoAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
    NSLog(@"LMBUMRewardedVideoAdapter loadRewardedVideoAdWithSlotID: %@, parameter: %@", slotID, parameter);

    if (!slotID || slotID.length == 0) {
        NSLog(@"⚠️ loadRewardedVideoAdWithSlotID: slotID 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMRewardedVideoAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slotID 为空"}];
        // 通知融合 SDK 加载失败
        if (self.bridge) {
            [self.bridge rewardedVideoAd:self didLoadFailWithError:error ext:@{}];
        }
        return;
    }
    // 只从 parameter[@"extra"] 字段（JSON字符串）中解析 userID
    NSString *userId = @"";
    if ([parameter[@"extra"] isKindOfClass:[NSString class]]) {
        NSString *extraJson = parameter[@"extra"];
        NSData *jsonData = [extraJson dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            NSError *jsonError = nil;
            NSDictionary *extraDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
            if ([extraDict isKindOfClass:[NSDictionary class]] && [extraDict[@"userID"] isKindOfClass:[NSString class]]) {
                userId = extraDict[@"userID"] ?: @"";
            }
        }
    }
    if (userId && userId.length > 0) {
        [LMAdSDK config:^(LMAdSDKConfigBuilder *builder) {
            builder.userId = userId;
        }];
    }
    // 获取竞价类型
    NSInteger biddingType = 0;
    if (parameter && parameter[BUMAdLoadingParamBiddingType]) {
        biddingType = [parameter[BUMAdLoadingParamBiddingType] integerValue];
    }
    self.biddingType = biddingType;

    self.slotID = slotID;
    self.hasCalledLoadSuccess = NO;
    self.hasCalledLoadFailed = NO;

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotID type:LMAdSlotTypeRewardedVideo];

        // 创建激励视频广告实例
        self.rewardedVideoAd = [[LMRewardedVideoAd alloc] initWithSlot:slot];
        // 设置代理为 self，用于接收广告回调
        self.rewardedVideoAd.delegate = self;

        // 开始加载广告
        [self.rewardedVideoAd loadAd];
    });
}

/// 展示激励视频广告
/// @param viewController 广告展示的根视图控制器
/// @param parameter 预留参数
- (BOOL)showAdFromRootViewController:(UIViewController *_Nonnull)viewController parameter:(NSDictionary *)parameter {
    NSLog(@"LMBUMRewardedVideoAdapter showAdFromRootViewController: %@, parameter: %@", viewController, parameter);

    if (!self.rewardedVideoAd) {
        NSLog(@"⚠️ showAdFromRootViewController: rewardedVideoAd 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMRewardedVideoAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告对象不存在"}];
        // 通知融合 SDK 展示失败
        if (self.bridge) {
            [self.bridge rewardedVideoAdDidShowFailed:self error:error];
        }
        return NO;
    }

    if (!viewController) {
        NSLog(@"⚠️ showAdFromRootViewController: viewController 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMRewardedVideoAdapter"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey : @"viewController 为空"}];
        // 通知融合 SDK 展示失败
        if (self.bridge) {
            [self.bridge rewardedVideoAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 检查广告是否已加载
    if (!self.rewardedVideoAd.isLoaded) {
        NSLog(@"⚠️ showAdFromRootViewController: 广告尚未加载完成");
        NSError *error = [NSError errorWithDomain:@"LMBUMRewardedVideoAdapter"
                                             code:-4
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成"}];
        // 通知融合 SDK 展示失败
        if (self.bridge) {
            [self.bridge rewardedVideoAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 展示广告
    [self.rewardedVideoAd showFromViewController:viewController];
    return YES;
}
- (void)didReceiveBidResult:(BUMMediaBidResult *)result {
    NSLog(@"LMBUMRewardedVideoAdapter didReceiveBidResult: %@", result);
}

#pragma mark - LMRewardedVideoAdDelegate

/// 广告加载成功
- (void)lm_rewardedVideoAdDidLoad:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMBUMRewardedVideoAdapter lm_rewardedVideoAdDidLoad: %@", rewardedAd);

    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 判断是否为客户端竞价
        // 如果是客户端竞价，需要在 ext 中传入 ECPM
        NSDictionary *ext = @{};
        if (self.biddingType == BUMBiddingTypeClient) {
            // 使用基础类的 getEcpm 方法获取 eCPM
            NSString *ecpm = [rewardedAd getEcpm];
            ext = @{BUMMediaAdLoadingExtECPM : ecpm ?: @""};
            NSLog(@"LMBUMRewardedVideoAdapter 客户端竞价，ECPM: %@", ecpm);
        }

        // 通知融合 SDK 广告加载成功
        if (self.bridge) {
            [self.bridge rewardedVideoAd:self didLoadWithExt:ext];
            // 通知融合 SDK 视频加载成功（广告加载成功通常意味着视频也准备好了）
            [self.bridge rewardedVideoAdVideoDidLoad:self];
        }
    }
}

/// 广告加载失败
- (void)lm_rewardedVideoAd:(LMRewardedVideoAd *)rewardedAd didFailWithError:(NSError *)error {
    NSLog(@"LMBUMRewardedVideoAdapter lm_rewardedVideoAd:didFailWithError: %@", error);

    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;

        // 通知融合 SDK 广告加载失败
        if (self.bridge) {
            [self.bridge rewardedVideoAd:self didLoadFailWithError:error ext:@{}];
        }

        // 清理资源
        self.rewardedVideoAd.delegate = nil;
        self.rewardedVideoAd = nil;
    }
}

/// 广告即将展示
- (void)lm_rewardedVideoAdWillVisible:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMBUMRewardedVideoAdapter lm_rewardedVideoAdWillVisible: %@", rewardedAd);

    // 通知融合 SDK 广告即将展示
    if (self.bridge) {
        // 通知融合 SDK 广告已展示（LitemizeSDK 没有单独的 DidVisible 回调，在 WillVisible 时一并通知）
        [self.bridge rewardedVideoAdDidVisible:self];
    }
}

/// 广告被点击
- (void)lm_rewardedVideoAdDidClick:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMBUMRewardedVideoAdapter lm_rewardedVideoAdDidClick: %@", rewardedAd);

    // 通知融合 SDK 广告被点击
    if (self.bridge) {
        [self.bridge rewardedVideoAdDidClick:self];
        // 通知融合 SDK 广告将展示全屏内容
        [self.bridge rewardedVideoAdWillPresentFullScreenModel:self];
    }
}

/// 广告已关闭
- (void)lm_rewardedVideoAdDidClose:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMBUMRewardedVideoAdapter lm_rewardedVideoAdDidClose: %@", rewardedAd);

    // 通知融合 SDK 广告已关闭
    if (self.bridge) {
        [self.bridge rewardedVideoAdDidClose:self];
    }

    // 清理资源
    self.rewardedVideoAd.delegate = nil;
    self.rewardedVideoAd = nil;
}

/// 触发激励（用户完成观看任务）
- (void)lm_rewardedVideoAdDidRewardEffective:(LMRewardedVideoAd *)rewardedAd {
    NSLog(@"LMBUMRewardedVideoAdapter lm_rewardedVideoAdDidRewardEffective: %@", rewardedAd);

    // 通知融合 SDK 服务器奖励验证成功
    // 注意：LitemizeSDK 的奖励验证逻辑在内部处理，这里直接通知验证成功
    if (self.bridge) {
        [self.bridge rewardedVideoAd:self
            didServerRewardSuccessWithInfo:^(BUMAdapterRewardAdInfo *_Nonnull info) {
                // 设置奖励验证状态为已验证
                info.verify = YES;
            }];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"LMBUMRewardedVideoAdapter dealloc");

    // 确保清理资源
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd.delegate = nil;
        self.rewardedVideoAd = nil;
    }
}

@end
