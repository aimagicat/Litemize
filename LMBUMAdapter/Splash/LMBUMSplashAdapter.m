//
//  LMBUMSplashAdapter.m
//  LitemobSDK
//
//  穿山甲（BUM）开屏广告 Adapter 实现
//

#import "LMBUMSplashAdapter.h"
#import <LitemobSDK/LMAdSDK.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMSplashAd.h>

// 如果项目中有穿山甲 SDK，取消下面的注释并导入相应的头文件
// #import <BUAdSDK/BUAdSDK.h>
// #import <BUMSplashAd/BUMCustomSplashAdapter.h>

@interface LMBUMSplashAdapter () <LMSplashAdDelegate>

/// 当前加载的开屏广告实例
@property(nonatomic, strong, nullable) LMSplashAd *splashAd;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *slotID;

/// 竞价类型（用于判断是否需要传入 ECPM）
@property(nonatomic, assign) NSInteger biddingType;

@end

@implementation LMBUMSplashAdapter

#pragma mark - Class Loading

#pragma mark - BUMCustomSplashAdapter Protocol Implementation

/// 加载开屏广告
/// @param slotID network广告位ID
/// @param parameter 广告请求的参数信息
- (void)loadSplashAdWithSlotID:(NSString *)slotID andParameter:(NSDictionary *)parameter {
    NSLog(@"LMBUMSplashAdapter loadSplashAdWithSlotID: %@, parameter: %@", slotID, parameter);

    if (!slotID || slotID.length == 0) {
        NSLog(@"⚠️ loadSplashAdWithSlotID: slotID 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMSplashAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slotID 为空"}];
        // 通知融合 SDK 加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAd:didLoadFailWithError:ext:)]) {
            [self.bridge splashAd:self didLoadFailWithError:error ext:@{}];
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

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotID type:LMAdSlotTypeSplash];
        // 设置期望的图片尺寸（开屏广告通常是全屏）
        slot.imgSize = [UIScreen mainScreen].bounds.size;

        // 创建开屏广告实例
        self.splashAd = [[LMSplashAd alloc] initWithSlot:slot];
        // 设置代理为 self，用于接收广告回调
        self.splashAd.delegate = self;

        // 开始加载广告
        [self.splashAd loadAd];
    });
}

/// 展示开屏广告
/// @param window 广告展示页面
/// @param parameter 预留参数
- (void)showSplashAdInWindow:(UIWindow *)window parameter:(NSDictionary *)parameter {
    NSLog(@"LMBUMSplashAdapter showSplashAdInWindow: %@, parameter: %@", window, parameter);

    if (!self.splashAd) {
        NSLog(@"⚠️ showSplashAdInWindow: splashAd 为空");
        return;
    }

    if (!window) {
        NSLog(@"⚠️ showSplashAdInWindow: window 为空");
        return;
    }

    // 检查广告是否已加载
    if (!self.splashAd.isLoaded) {
        NSLog(@"⚠️ showSplashAdInWindow: 广告尚未加载完成");
        NSError *error = [NSError errorWithDomain:@"LMBUMSplashAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成"}];
        // 通知融合 SDK 展示失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidShowFailed:error:)]) {
            [self.bridge splashAdDidShowFailed:self error:error];
        }
        return;
    }

    // 展示广告
    [self.splashAd showInWindow:window];
}

/// 广告关闭实现，在外部使用开发者调用destoryAd时触发
- (void)dismissSplashAd {
    NSLog(@"LMBUMSplashAdapter dismissSplashAd");

    // 清理资源
    if (self.splashAd) {
        self.splashAd.delegate = nil;
        self.splashAd = nil;
    }

    // 通知融合 SDK 广告已关闭
    if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidClose:)]) {
        [self.bridge splashAdDidClose:self];
    }
}

/// 收到竞价结果信息时可能触发
/// 在此处理Client Bidding的结果回调
/// @param result 竞价结果模型
- (void)didReceiveBidResult:(BUMMediaBidResult *)result {
    NSLog(@"LMBUMSplashAdapter didReceiveBidResult: %@", result);

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

#pragma mark - LMSplashAdDelegate

/// 广告加载成功
- (void)lm_splashAdDidLoad:(LMSplashAd *)splashAd {
    NSLog(@"LMBUMSplashAdapter lm_splashAdDidLoad: %@", splashAd);

    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 判断是否为客户端竞价
        // 如果是客户端竞价，需要在 ext 中传入 ECPM
        NSDictionary *ext = @{};
        if (self.biddingType == BUMBiddingTypeClient) {
            // 使用基础类的 getEcpm 方法获取 eCPM
            NSString *ecpm = [splashAd getEcpm];
            ext = @{BUMMediaAdLoadingExtECPM : ecpm};
            NSLog(@"LMBUMSplashAdapter 客户端竞价，ECPM: %@", ecpm);
        }

        // 通知融合 SDK 广告加载成功
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAd:didLoadWithExt:)]) {
            [self.bridge splashAd:self didLoadWithExt:ext];
        }
    }
}

/// 广告加载失败
- (void)lm_splashAd:(LMSplashAd *)splashAd didFailWithError:(NSError *)error {
    NSLog(@"LMBUMSplashAdapter lm_splashAd:didFailWithError: %@", error);

    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;

        // 通知融合 SDK 广告加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAd:didLoadFailWithError:ext:)]) {
            [self.bridge splashAd:self didLoadFailWithError:error ext:@{}];
        }

        // 清理资源
        self.splashAd.delegate = nil;
        self.splashAd = nil;
    }
}

/// 广告即将展示
- (void)lm_splashAdWillVisible:(LMSplashAd *)splashAd {
    NSLog(@"LMBUMSplashAdapter lm_splashAdWillVisible: %@", splashAd);

    // 通知融合 SDK 广告展示成功
    if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdWillVisible:)]) {
        [self.bridge splashAdWillVisible:self];
    }
}

/// 广告被点击
- (void)lm_splashAdDidClick:(LMSplashAd *)splashAd {
    NSLog(@"LMBUMSplashAdapter lm_splashAdDidClick: %@", splashAd);

    // 通知融合 SDK 广告被点击
    if (self.bridge) {
        if ([self.bridge respondsToSelector:@selector(splashAdDidClick:)]) {
            [self.bridge splashAdDidClick:self];
        }
        // 通知融合 SDK 广告将展示全屏内容
        if ([self.bridge respondsToSelector:@selector(splashAdWillPresentFullScreenModal:)]) {
            [self.bridge splashAdWillPresentFullScreenModal:self];
        }
    }
}

/// 广告已关闭
- (void)lm_splashAdDidClose:(LMSplashAd *)splashAd {
    NSLog(@"LMBUMSplashAdapter lm_splashAdDidClose: %@", splashAd);

    // 通知融合 SDK 广告已关闭
    if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidClose:)]) {
        [self.bridge splashAdDidClose:self];
    }

    // 清理资源
    self.splashAd.delegate = nil;
    self.splashAd = nil;
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"LMBUMSplashAdapter dealloc");

    // 确保清理资源
    if (self.splashAd) {
        self.splashAd.delegate = nil;
        self.splashAd = nil;
    }
}

@end
