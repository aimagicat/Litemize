//
//  LMBUMInterstitialAdapter.m
//  LitemobSDK
//
//  穿山甲（BUM）插屏广告 Adapter 实现
//

#import "LMBUMInterstitialAdapter.h"
#import <LitemobSDK/LMAdSDK.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMInterstitialAd.h>

@interface LMBUMInterstitialAdapter () <LMInterstitialAdDelegate>

/// 当前加载的插屏广告实例
@property(nonatomic, strong, nullable) LMInterstitialAd *interstitialAd;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 是否已经调用过失败回调（用于避免重复调用，类似示例代码中的 didCallbackFailed）
@property(nonatomic, assign) BOOL didCallbackFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *slotID;

/// 竞价类型（用于判断是否需要传入 ECPM）
@property(nonatomic, assign) NSInteger biddingType;

@end

@implementation LMBUMInterstitialAdapter

#pragma mark - Class Loading

#pragma mark - BUMCustomInterstitialAdapter Protocol Implementation

/// 是否允许在当前广告展示时预加载下一个广告
- (BOOL)enablePreloadWhenCurrentIsDisplay {
    return YES;
}

/// 获取当前广告状态
- (BUMMediatedAdStatus)mediatedAdStatus {
    BUMMediatedAdStatus status = BUMMediatedAdStatusUnknown;
    if (self.interstitialAd && self.interstitialAd.isLoaded && self.interstitialAd.isAdValid) {
        status.valid = BUMMediatedAdStatusValueSure;
    } else {
        status.valid = BUMMediatedAdStatusValueDeny;
    }
    return status;
}

/// 加载插屏广告
/// @param slotID network广告位ID
/// @param size 广告尺寸
/// @param parameter 广告请求的参数信息
- (void)loadInterstitialAdWithSlotID:(nonnull NSString *)slotID andSize:(CGSize)size parameter:(nonnull NSDictionary *)parameter {
    NSLog(@"LMBUMInterstitialAdapter loadInterstitialAdWithSlotID: %@, size: %@, parameter: %@", slotID, NSStringFromCGSize(size),
          parameter);

    if (!slotID || slotID.length == 0) {
        NSLog(@"⚠️ loadInterstitialAdWithSlotID: slotID 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMInterstitialAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slotID 为空"}];
        // 通知融合 SDK 加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAd:didLoadFailWithError:ext:)]) {
            [self.bridge interstitialAd:self didLoadFailWithError:error ext:@{}];
        }
        return;
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
    self.didCallbackFailed = NO;

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotID type:LMAdSlotTypeInterstitial];
        // 设置图片尺寸（插屏广告通常是全屏或半屏）
        slot.imgSize = size.width > 0 && size.height > 0 ? size : [UIScreen mainScreen].bounds.size;

        // 创建插屏广告实例
        self.interstitialAd = [[LMInterstitialAd alloc] initWithSlot:slot];
        // 设置代理为 self，用于接收广告回调
        self.interstitialAd.delegate = self;

        // 开始加载广告
        [self.interstitialAd loadAd];
    });
}

/// 展示插屏广告
/// @param viewController 广告展示的根视图控制器
/// @param parameter 预留参数
- (BOOL)showAdFromRootViewController:(UIViewController *_Nonnull)viewController parameter:(nonnull NSDictionary *)parameter {
    NSLog(@"LMBUMInterstitialAdapter showAdFromRootViewController: %@, parameter: %@", viewController, parameter);

    if (!self.interstitialAd) {
        NSLog(@"⚠️ showAdFromRootViewController: interstitialAd 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMInterstitialAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告对象不存在"}];
        // 通知融合 SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidShowFailed:error:)]) {
            [self.bridge interstitialAdDidShowFailed:self error:error];
        }
        return NO;
    }

    if (!viewController) {
        NSLog(@"⚠️ showAdFromRootViewController: viewController 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMInterstitialAdapter"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey : @"viewController 为空"}];
        // 通知融合 SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidShowFailed:error:)]) {
            [self.bridge interstitialAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 检查广告是否已加载且有效
    if (!self.interstitialAd.isLoaded || !self.interstitialAd.isAdValid) {
        NSLog(@"⚠️ showAdFromRootViewController: 广告尚未加载完成或已过期");
        NSError *error = [NSError errorWithDomain:@"LMBUMInterstitialAdapter"
                                             code:-4
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成或已过期"}];
        // 通知融合 SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidShowFailed:error:)]) {
            [self.bridge interstitialAdDidShowFailed:self error:error];
        }
        return NO;
    }

    // 展示广告
    [self.interstitialAd showFromViewController:viewController];
    return YES;
}

/// 收到竞价结果信息时可能触发
/// 在此处理Client Bidding的结果回调
/// @param result 竞价结果模型
- (void)didReceiveBidResult:(BUMMediaBidResult *)result {
    NSLog(@"LMBUMInterstitialAdapter didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：此方法是否触发由 `-[BUAdSlot.mediation bidNotify]` 结果决定
    if (result) {
        // 获取竞价价格（如果 result 有 bidPrice 属性）
        if ([result respondsToSelector:@selector(bidPrice)]) {
            NSInteger bidPrice = [result performSelector:@selector(bidPrice)];
            NSLog(@"收到竞价结果，价格：%ld", (long)bidPrice);
        }
        // 可以在这里处理其他竞价相关信息
    }
}

#pragma mark - LMInterstitialAdDelegate

/// 广告加载成功
- (void)lm_interstitialAdDidLoad:(LMInterstitialAd *)ad {
    NSLog(@"LMBUMInterstitialAdapter lm_interstitialAdDidLoad: %@", ad);

    // 注意：LitemobSDK 的插屏广告加载成功即表示广告已准备好
    // 根据 BUM 的协议，需要在渲染成功时回调，但 LitemobSDK 没有单独的渲染成功回调
    // 所以在加载成功时即视为渲染成功，返回 ECPM
    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 判断是否为客户端竞价
        // 如果是客户端竞价，需要在 ext 中传入 ECPM
        NSDictionary *ext = @{};
        if (self.biddingType == BUMBiddingTypeClient) {
            // 使用基础类的 getEcpm 方法获取 eCPM
            NSString *ecpm = [ad getEcpm];
            ext = @{BUMMediaAdLoadingExtECPM : ecpm ?: @""};
            NSLog(@"LMBUMInterstitialAdapter 客户端竞价，ECPM: %@", ecpm);
        }

        // 通知融合 SDK 广告加载成功（在渲染成功时调用）
        if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAd:didLoadWithExt:)]) {
            [self.bridge interstitialAd:self didLoadWithExt:ext];
        }
    }
}

/// 广告加载失败
- (void)lm_interstitialAd:(LMInterstitialAd *)ad didFailWithError:(NSError *)error {
    NSLog(@"LMBUMInterstitialAdapter lm_interstitialAd:didFailWithError: %@", error);

    if (self.didCallbackFailed)
        return;
    self.didCallbackFailed = YES;
    self.hasCalledLoadFailed = YES;

    // 通知融合 SDK 广告加载失败
    if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAd:didLoadFailWithError:ext:)]) {
        [self.bridge interstitialAd:self didLoadFailWithError:error ext:@{}];
    }

    // 清理资源
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
}

/// 广告即将展示
- (void)lm_interstitialAdWillVisible:(LMInterstitialAd *)ad {
    NSLog(@"LMBUMInterstitialAdapter lm_interstitialAdWillVisible: %@", ad);

    // 通知融合 SDK 广告已展示（LitemobSDK 没有单独的 DidVisible 回调，在 WillVisible 时一并通知）
    if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidVisible:)]) {
        [self.bridge interstitialAdDidVisible:self];
    }
}

/// 广告被点击
- (void)lm_interstitialAdDidClick:(LMInterstitialAd *)ad {
    NSLog(@"LMBUMInterstitialAdapter lm_interstitialAdDidClick: %@", ad);

    // 通知融合 SDK 广告被点击
    if (self.bridge) {
        if ([self.bridge respondsToSelector:@selector(interstitialAdDidClick:)]) {
            [self.bridge interstitialAdDidClick:self];
        }
        // 通知融合 SDK 广告将展示全屏内容（可选回调）
        if ([self.bridge respondsToSelector:@selector(interstitialAdWillPresentFullScreenModal:)]) {
            [self.bridge interstitialAdWillPresentFullScreenModal:self];
        }
    }
}

/// 广告已关闭
- (void)lm_interstitialAdDidClose:(LMInterstitialAd *)ad {
    NSLog(@"LMBUMInterstitialAdapter lm_interstitialAdDidClose: %@", ad);

    // 通知融合 SDK 广告已关闭
    if (self.bridge && [self.bridge respondsToSelector:@selector(interstitialAdDidClose:)]) {
        [self.bridge interstitialAdDidClose:self];
    }

    // 清理资源
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"LMBUMInterstitialAdapter dealloc");

    // 确保清理资源
    if (self.interstitialAd) {
        self.interstitialAd.delegate = nil;
        self.interstitialAd = nil;
    }
}

@end
