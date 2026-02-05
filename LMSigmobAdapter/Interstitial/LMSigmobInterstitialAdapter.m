//
//  LMSigmobInterstitialAdapter.m
//  LitemobSDK
//
//  Sigmob 插屏广告 Adapter 实现
//

#import "LMSigmobInterstitialAdapter.h"
#import "../LMSigmobAdapterLog.h"
#import <LitemobSDK/LMAdSDK.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMInterstitialAd.h>

@interface LMSigmobInterstitialAdapter () <LMInterstitialAdDelegate>

@property(nonatomic, weak) id<AWMCustomInterstitialAdapterBridge> bridge;

/// 当前加载的插屏广告实例
@property(nonatomic, strong, nullable) LMInterstitialAd *interstitialAd;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *placementId;

@end

@implementation LMSigmobInterstitialAdapter

#pragma mark - AWMCustomInterstitialAdapter Protocol Implementation

- (instancetype)initWithBridge:(id<AWMCustomInterstitialAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    // 返回广告是否准备好
    return self.interstitialAd != nil && self.interstitialAd.isLoaded && self.interstitialAd.isAdValid;
}

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"Interstitial loadAdWithPlacementId: %@, parameter: %@", placementId, parameter);

    if (!placementId || placementId.length == 0) {
        LMSigmobLog(@"⚠️ Interstitial loadAdWithPlacementId: placementId 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobInterstitialAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"placementId 为空"}];
        // 通知 ToBid SDK 加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAd:didLoadFailWithError:ext:)]) {
            [self.bridge interstitialAd:self didLoadFailWithError:error ext:@{}];
        }
        return;
    }

    self.placementId = placementId;
    self.hasCalledLoadSuccess = NO;
    self.hasCalledLoadFailed = NO;

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 先释放上一个广告实例（如果存在）
        if (self.interstitialAd) {
            LMSigmobLog(@"Interstitial 释放上一个插屏广告实例");
            [self destory];
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:placementId type:LMAdSlotTypeInterstitial];
        // 设置图片尺寸（插屏广告通常是全屏或半屏）
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        slot.imgSize = screenSize;

        // 创建插屏广告实例
        self.interstitialAd = [[LMInterstitialAd alloc] initWithSlot:slot];
        // 设置代理为 self，用于接收广告回调
        self.interstitialAd.delegate = self;

        // 开始加载广告
        [self.interstitialAd loadAd];
    });
}

- (BOOL)showAdFromRootViewController:(UIViewController *)viewController parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"Interstitial showAdFromRootViewController: %@, parameter: %@", viewController, parameter);

    if (!self.interstitialAd) {
        LMSigmobLog(@"⚠️ Interstitial showAdFromRootViewController: interstitialAd 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobInterstitialAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告对象不存在"}];
        // 通知 ToBid SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidShowFailed:error:)]) {
            [self.bridge interstitialAdDidShowFailed:self error:error];
        }
        return NO;
    }

    if (!viewController) {
        LMSigmobLog(@"⚠️ Interstitial showAdFromRootViewController: viewController 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobInterstitialAdapter"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey : @"viewController 为空"}];
        // 通知 ToBid SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidShowFailed:error:)]) {
            [self.bridge interstitialAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 检查广告是否已加载且有效
    if (!self.interstitialAd.isLoaded || !self.interstitialAd.isAdValid) {
        LMSigmobLog(@"⚠️ Interstitial showAdFromRootViewController: 广告尚未加载完成或已过期");
        NSError *error = [NSError errorWithDomain:@"LMSigmobInterstitialAdapter"
                                             code:-4
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成或已过期"}];
        // 通知 ToBid SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidShowFailed:error:)]) {
            [self.bridge interstitialAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 展示广告
    [self.interstitialAd showFromViewController:viewController];
    return YES;
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    LMSigmobLog(@"Interstitial didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：此方法是否触发由 ToBid SDK 决定
    if (result) {
        // 获取竞价价格（如果 result 有 price 属性）
        if ([result respondsToSelector:@selector(price)]) {
            NSNumber *price = [result performSelector:@selector(price)];
            LMSigmobLog(@"Interstitial 收到竞价结果，价格：%@", price);
        }
        // 可以在这里处理其他竞价相关信息
    }
}

- (void)destory {
    LMSigmobLog(@"Interstitial destory");

    // 清理资源
    if (self.interstitialAd) {
        self.interstitialAd.delegate = nil;
        self.interstitialAd = nil;
    }
}

#pragma mark - LMInterstitialAdDelegate

/// 广告加载成功
- (void)lm_interstitialAdDidLoad:(LMInterstitialAd *)ad {
    LMSigmobLog(@"Interstitial lm_interstitialAdDidLoad: %@", ad);

    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 获取 eCPM（用于客户端竞价）
        // 注意：LitemobSDK 的 getEcpm 返回单位已经是"分"，直接使用
        NSString *ecpm = [ad getEcpm];
        NSDictionary *ext = @{};
        if (ecpm && ecpm.length > 0) {
            ext = @{AWMMediaAdLoadingExtECPM : ecpm};
            LMSigmobLog(@"Interstitial 客户端竞价，ECPM: %@分", ecpm);
        }

        // 通知 ToBid SDK 广告数据返回（用于客户端竞价）
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAd:didAdServerResponseWithExt:)]) {
            [self.bridge interstitialAd:self didAdServerResponseWithExt:ext];
        }

        // 通知 ToBid SDK 广告加载成功
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidLoad:)]) {
            [self.bridge interstitialAdDidLoad:self];
        }
    }
}

/// 广告加载失败
- (void)lm_interstitialAd:(LMInterstitialAd *)ad didFailWithError:(NSError *)error {
    LMSigmobLog(@"Interstitial lm_interstitialAd:didFailWithError: %@", error);

    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;

        // 通知 ToBid SDK 广告加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAd:didLoadFailWithError:ext:)]) {
            [self.bridge interstitialAd:self didLoadFailWithError:error ext:@{}];
        }

        // 清理资源
        [self destory];
    }
}

/// 广告即将展示
- (void)lm_interstitialAdWillVisible:(LMInterstitialAd *)ad {
    LMSigmobLog(@"Interstitial lm_interstitialAdWillVisible: %@", ad);

    // 通知 ToBid SDK 广告即将展示
    if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidVisible:)]) {
        [self.bridge interstitialAdDidVisible:self];
    }
}

/// 广告被点击
- (void)lm_interstitialAdDidClick:(LMInterstitialAd *)ad {
    LMSigmobLog(@"Interstitial lm_interstitialAdDidClick: %@", ad);

    // 通知 ToBid SDK 广告被点击
    if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidClick:)]) {
        [self.bridge interstitialAdDidClick:self];
    }
}

/// 广告已关闭
- (void)lm_interstitialAdDidClose:(LMInterstitialAd *)ad {
    LMSigmobLog(@"Interstitial lm_interstitialAdDidClose: %@", ad);

    // 通知 ToBid SDK 广告已关闭
    if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidClose:)]) {
        [self.bridge interstitialAdDidClose:self];
    }

    // 清理资源
    [self destory];
}

#pragma mark - Dealloc

- (void)dealloc {
    LMSigmobLog(@"Interstitial dealloc");

    // 确保清理资源
    [self destory];
}

@end
