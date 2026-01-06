//
//  LMSigmobBannerAdapter.m
//  LitemizeSDK
//
//  Sigmob Banner 横幅广告 Adapter 实现
//

#import "LMSigmobBannerAdapter.h"
#import "../LMSigmobAdapterLog.h"
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBannerAd.h>

/// Banner 容器视图，用于监听移除事件
@interface LMSigmobBannerContainerView : UIView
@property(nonatomic, weak, nullable) LMSigmobBannerAdapter *adapter;
@end

@implementation LMSigmobBannerContainerView

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    // 检测视图被移除的情况（superview 为 nil）
    if (!self.superview && self.adapter) {
        LMSigmobLog(@"Banner 容器视图被移除，触发释放");
        // 调用 Adapter 的释放方法
        [self.adapter destory];
    }
}

@end

@interface LMSigmobBannerAdapter () <LMBannerAdDelegate>

@property(nonatomic, weak) id<AWMCustomBannerAdapterBridge> bridge;

/// 当前加载的 Banner 广告实例
@property(nonatomic, strong, nullable) LMBannerAd *bannerAd;

/// Banner 广告视图容器（用于展示广告）
@property(nonatomic, strong, nullable) UIView *bannerContainerView;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *placementId;

/// 广告尺寸
@property(nonatomic, assign) CGSize adSize;

@end

@implementation LMSigmobBannerAdapter

#pragma mark - AWMCustomBannerAdapter Protocol Implementation

- (instancetype)initWithBridge:(id<AWMCustomBannerAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    // 返回广告是否准备好
    return self.bannerAd != nil && self.bannerAd.isLoaded;
}

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"Banner loadAdWithPlacementId: %@, parameter: %@", placementId, parameter);

    if (!placementId || placementId.length == 0) {
        LMSigmobLog(@"⚠️ Banner loadAdWithPlacementId: placementId 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobBannerAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"placementId 为空"}];
        // 通知 ToBid SDK 加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(bannerAd:didLoadFailWithError:ext:)]) {
            [self.bridge bannerAd:self didLoadFailWithError:error ext:@{}];
        }
        return;
    }

    self.placementId = placementId;
    self.hasCalledLoadSuccess = NO;
    self.hasCalledLoadFailed = NO;

    // 从 parameter 中获取广告尺寸，默认使用 320x50
    CGSize adSize = CGSizeMake(320, 50);
    if (parameter && parameter.extra) {
        // 尝试从 extra 中获取尺寸
        NSValue *sizeValue = [parameter.extra objectForKey:@"adSize"];
        if (sizeValue) {
            adSize = [sizeValue CGSizeValue];
        }
    }
    self.adSize = adSize;

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 先释放上一个 banner 实例（如果存在）
        if (self.bannerAd) {
            LMSigmobLog(@"Banner 释放上一个 Banner 广告实例");
            [self destory];
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:placementId type:LMAdSlotTypeBanner];
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

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    LMSigmobLog(@"Banner didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：此方法是否触发由 ToBid SDK 决定
    if (result) {
        // 获取竞价价格（如果 result 有 price 属性）
        if ([result respondsToSelector:@selector(price)]) {
            NSNumber *price = [result performSelector:@selector(price)];
            LMSigmobLog(@"Banner 收到竞价结果，价格：%@", price);
        }
        // 可以在这里处理其他竞价相关信息
    }
}

- (void)destory {
    LMSigmobLog(@"Banner destory");

    // 清理资源
    if (self.bannerAd) {
        self.bannerAd.delegate = nil;
        [self.bannerAd close];
        self.bannerAd = nil;
    }
    self.bannerContainerView = nil;
}

#pragma mark - LMBannerAdDelegate

/// 广告加载成功
- (void)lm_bannerAdDidLoad:(LMBannerAd *)bannerAd {
    LMSigmobLog(@"Banner lm_bannerAdDidLoad: %@", bannerAd);

    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 获取 eCPM（用于客户端竞价）
        NSString *ecpm = [bannerAd getEcpm];
        NSDictionary *ext = @{};
        if (ecpm && ecpm.length > 0) {
            ext = @{@"price" : ecpm, @"currency" : @"CNY"};
            LMSigmobLog(@"Banner 客户端竞价，ECPM: %@", ecpm);
        }

        // 创建容器视图用于展示 Banner 广告
        LMSigmobBannerContainerView *containerView =
            [[LMSigmobBannerContainerView alloc] initWithFrame:CGRectMake(0, 0, self.adSize.width, self.adSize.height)];
        containerView.backgroundColor = [UIColor clearColor];
        containerView.adapter = self;
        self.bannerContainerView = containerView;

        // 通知 ToBid SDK 广告数据返回（用于客户端竞价）
        if (self.bridge && [self.bridge respondsToSelector:@selector(bannerAd:didAdServerResponse:ext:)]) {
            [self.bridge bannerAd:self didAdServerResponse:containerView ext:ext];
        }

        // 通知 ToBid SDK 广告加载成功，传入容器视图
        if (self.bridge && [self.bridge respondsToSelector:@selector(bannerAd:didLoad:)]) {
            [self.bridge bannerAd:self didLoad:containerView];
        }

        // 展示广告到容器视图
        [bannerAd showInView:containerView];
    }
}

/// 广告加载失败
- (void)lm_bannerAd:(LMBannerAd *)bannerAd didFailWithError:(NSError *)error {
    LMSigmobLog(@"Banner lm_bannerAd:didFailWithError: %@", error);

    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;

        // 通知 ToBid SDK 广告加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(bannerAd:didLoadFailWithError:ext:)]) {
            [self.bridge bannerAd:self didLoadFailWithError:error ext:@{}];
        }

        // 清理资源
        [self destory];
    }
}

/// 广告即将展示
- (void)lm_bannerAdWillVisible:(LMBannerAd *)bannerAd {
    LMSigmobLog(@"Banner lm_bannerAdWillVisible: %@", bannerAd);

    // 通知 ToBid SDK 广告已可见
    if (self.bridge && self.bannerContainerView &&
        [self.bridge respondsToSelector:@selector(bannerAdDidBecomeVisible:bannerView:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"LMSigmobBannerAdapter bannerAdDidBecomeVisible: %@ %@", self.bannerContainerView,
                  self.bannerContainerView.superview);
            [self.bridge bannerAdDidBecomeVisible:self bannerView:self.bannerContainerView];
        });
    }
}

/// 广告被点击
- (void)lm_bannerAdDidClick:(LMBannerAd *)bannerAd {
    LMSigmobLog(@"Banner lm_bannerAdDidClick: %@", bannerAd);

    // 通知 ToBid SDK 广告被点击
    if (self.bridge && self.bannerContainerView) {
        if ([self.bridge respondsToSelector:@selector(bannerAdDidClick:bannerView:)]) {
            [self.bridge bannerAdDidClick:self bannerView:self.bannerContainerView];
        }
        // 通知 ToBid SDK 广告将展示全屏内容
        if ([self.bridge respondsToSelector:@selector(bannerAdWillPresentFullScreenModal:bannerView:)]) {
            [self.bridge bannerAdWillPresentFullScreenModal:self bannerView:self.bannerContainerView];
        }
    }
}

/// 广告关闭
- (void)lm_bannerAdDidClose:(LMBannerAd *)bannerAd {
    LMSigmobLog(@"Banner lm_bannerAdDidClose: %@", bannerAd);

    // 通知 ToBid SDK 广告已关闭
    if (self.bridge && self.bannerContainerView && [self.bridge respondsToSelector:@selector(bannerAdDidClosed:bannerView:)]) {
        [self.bridge bannerAdDidClosed:self bannerView:self.bannerContainerView];
    }

    // 清理资源
    [self destory];
}

#pragma mark - Dealloc

- (void)dealloc {
    LMSigmobLog(@"Banner dealloc");

    // 确保清理资源
    [self destory];
}

@end
