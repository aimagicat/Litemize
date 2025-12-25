//
//  LMBUMBannerAdapter.m
//  LitemizeSDK
//
//  穿山甲（BUM）Banner 横幅广告 Adapter 实现
//

#import "LMBUMBannerAdapter.h"
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBannerAd.h>

/// Banner 容器视图，用于监听移除事件
@interface LMBUMBannerContainerView : UIView
@property(nonatomic, weak, nullable) LMBUMBannerAdapter *adapter;
@end

@implementation LMBUMBannerContainerView

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    // 检测视图被移除的情况（superview 为 nil）
    if (!self.superview && self.adapter) {
        NSLog(@"LMBUMBannerAdapter Banner 容器视图被移除，触发释放");
        // 调用 Adapter 的释放方法
        [self.adapter releaseBannerAd];
    }
}

@end

@interface LMBUMBannerAdapter () <LMBannerAdDelegate>

/// 当前加载的 Banner 广告实例
@property(nonatomic, strong, nullable) LMBannerAd *bannerAd;

/// Banner 广告视图容器（用于展示广告）
@property(nonatomic, strong, nullable) UIView *bannerContainerView;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *slotID;

/// 广告尺寸
@property(nonatomic, assign) CGSize adSize;

/// 竞价类型（用于判断是否需要传入 ECPM）
@property(nonatomic, assign) NSInteger biddingType;

/// 释放 Banner 广告资源（当广告视图被移除时调用）
- (void)releaseBannerAd;

@end

@implementation LMBUMBannerAdapter

#pragma mark - Class Loading

/// 类加载时调用（系统自动调用）
+ (void)load {
    NSLog(@"✅ [LMBUMBannerAdapter] LMBUMBannerAdapter 类已加载到系统");
}

#pragma mark - BUMCustomBannerAdapter Protocol Implementation

/// 是否允许在当前广告展示时预加载下一个广告
- (BOOL)enablePreloadWhenCurrentIsDisplay {
    return YES;
}

/// 获取当前广告状态
- (BUMMediatedAdStatus)mediatedAdStatus {
    BUMMediatedAdStatus status = BUMMediatedAdStatusUnknown;
    if (self.bannerAd && self.bannerAd.isLoaded) {
        status.valid = BUMMediatedAdStatusValueSure;
    } else {
        status.valid = BUMMediatedAdStatusValueDeny;
    }
    return status;
}

/// 加载 Banner 广告
/// @param slotID network广告位ID
/// @param adSize 广告尺寸
/// @param parameter 广告请求的参数信息
- (void)loadBannerAdWithSlotID:(nonnull NSString *)slotID andSize:(CGSize)adSize parameter:(nullable NSDictionary *)parameter {
    NSLog(@"LMBUMBannerAdapter loadBannerAdWithSlotID: %@, adSize: %@, parameter: %@", slotID, NSStringFromCGSize(adSize),
          parameter);

    if (!slotID || slotID.length == 0) {
        NSLog(@"⚠️ loadBannerAdWithSlotID: slotID 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMBannerAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slotID 为空"}];
        // 通知融合 SDK 加载失败
        if (self.bridge) {
            [self.bridge bannerAd:self didLoadFailWithError:error ext:@{}];
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
    self.adSize = adSize;
    self.hasCalledLoadSuccess = NO;
    self.hasCalledLoadFailed = NO;

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 先释放上一个 banner 实例（如果存在）
        if (self.bannerAd) {
            NSLog(@"LMBUMBannerAdapter 释放上一个 Banner 广告实例");
            [self releaseBannerAd];
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotID type:LMAdSlotTypeBanner];
        // 设置图片尺寸（Banner 广告尺寸）
        slot.imgSize = adSize;

        // 创建 Banner 广告实例
        self.bannerAd = [[LMBannerAd alloc] initWithSlot:slot];
        // 设置代理为 self，用于接收广告回调
        self.bannerAd.delegate = self;

        // 开始加载广告
        [self.bannerAd loadAd];
    });
}

#pragma mark - LMBannerAdDelegate

/// 广告加载成功
- (void)lm_bannerAdDidLoad:(LMBannerAd *)bannerAd {
    NSLog(@"LMBUMBannerAdapter lm_bannerAdDidLoad: %@", bannerAd);

    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 判断是否为客户端竞价
        // 如果是客户端竞价，需要在 ext 中传入 ECPM
        NSDictionary *ext = @{};
        if (self.biddingType == BUMBiddingTypeClient) {
            // 使用基础类的 getEcpm 方法获取 eCPM
            NSString *ecpm = [bannerAd getEcpm];
            ext = @{BUMMediaAdLoadingExtECPM : ecpm ?: @""};
            NSLog(@"LMBUMBannerAdapter 客户端竞价，ECPM: %@", ecpm);
        }

        // 创建容器视图用于展示 Banner 广告
        // Banner 广告需要通过 showInView: 方法展示，但这里先创建一个临时容器
        // 实际的展示会在 BUM SDK 调用时进行
        LMBUMBannerContainerView *containerView =
            [[LMBUMBannerContainerView alloc] initWithFrame:CGRectMake(0, 0, self.adSize.width, self.adSize.height)];
        containerView.backgroundColor = [UIColor clearColor];
        containerView.adapter = self;
        self.bannerContainerView = containerView;

        // 展示广告到容器视图
        [bannerAd showInView:containerView];

        // 通知融合 SDK 广告加载成功，传入容器视图
        if (self.bridge) {
            [self.bridge bannerAd:self didLoad:containerView ext:ext];
        }
    }
}

/// 广告加载失败
- (void)lm_bannerAd:(LMBannerAd *)bannerAd didFailWithError:(NSError *)error {
    NSLog(@"LMBUMBannerAdapter lm_bannerAd:didFailWithError: %@", error);

    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;

        // 通知融合 SDK 广告加载失败
        if (self.bridge) {
            [self.bridge bannerAd:self didLoadFailWithError:error ext:@{}];
        }

        // 清理资源
        [self releaseBannerAd];
    }
}

/// 广告即将展示
- (void)lm_bannerAdWillVisible:(LMBannerAd *)bannerAd {
    NSLog(@"LMBUMBannerAdapter lm_bannerAdWillVisible: %@", bannerAd);

    // 通知融合 SDK 广告已可见
    if (self.bridge && self.bannerContainerView) {
        [self.bridge bannerAdDidBecomeVisible:self bannerView:self.bannerContainerView];
    }
}

/// 广告被点击
- (void)lm_bannerAdDidClick:(LMBannerAd *)bannerAd {
    NSLog(@"LMBUMBannerAdapter lm_bannerAdDidClick: %@", bannerAd);

    // 通知融合 SDK 广告被点击
    if (self.bridge && self.bannerContainerView) {
        [self.bridge bannerAdDidClick:self bannerView:self.bannerContainerView];
        // 通知融合 SDK 广告将展示全屏内容
        [self.bridge bannerAdWillPresentFullScreenModal:self bannerView:self.bannerContainerView];
    }
}

/// 广告关闭
- (void)lm_bannerAdDidClose:(LMBannerAd *)bannerAd {
    NSLog(@"LMBUMBannerAdapter lm_bannerAdDidClose: %@", bannerAd);

    // 通知融合 SDK 广告已关闭
    if (self.bridge && self.bannerContainerView) {
        [self.bridge bannerAd:self bannerView:self.bannerContainerView didClosedWithDislikeWithReason:nil];
    }

    // 清理资源
    [self releaseBannerAd];
}

#pragma mark - Private Methods

/// 释放 Banner 广告资源（当广告视图被移除时调用）
- (void)releaseBannerAd {
    NSLog(@"LMBUMBannerAdapter releaseBannerAd 释放 Banner 广告资源");

    // 释放 banner 实例
    if (self.bannerAd) {
        // 先移除代理，避免回调
        self.bannerAd.delegate = nil;
        // 调用 close 方法清理资源（会触发关闭回调并清理视图）
        [self.bannerAd close];
        self.bannerAd = nil;
    }

    // 清理容器视图引用
    self.bannerContainerView = nil;
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"LMBUMBannerAdapter dealloc");

    // 确保清理资源
    [self releaseBannerAd];
}

@end
