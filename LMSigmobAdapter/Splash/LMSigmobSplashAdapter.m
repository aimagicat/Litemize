//
//  LMSigmobSplashAdapter.m
//  LitemobSDK
//
//  Sigmob 开屏广告 Adapter 实现
//

#import "LMSigmobSplashAdapter.h"
#import "../LMSigmobAdapterLog.h"
#import <LitemobSDK/LMAdSDK.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMSplashAd.h>

@interface LMSigmobSplashAdapter () <LMSplashAdDelegate>

@property(nonatomic, weak) id<AWMCustomSplashAdapterBridge> bridge;

/// 当前加载的开屏广告实例
@property(nonatomic, strong, nullable) LMSplashAd *splashAd;

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *placementId;

/// 底部视图（如果有）
@property(nonatomic, strong, nullable) UIView *bottomView;

@end

@implementation LMSigmobSplashAdapter

#pragma mark - AWMCustomSplashAdapter Protocol Implementation

- (instancetype)initWithBridge:(id<AWMCustomSplashAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    // 返回广告是否准备好
    return self.splashAd != nil && self.splashAd.isLoaded;
}

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"Splash loadAdWithPlacementId: %@, parameter: %@", placementId, parameter);

    if (!placementId || placementId.length == 0) {
        LMSigmobLog(@"⚠️ Splash loadAdWithPlacementId: placementId 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobSplashAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"placementId 为空"}];
        // 通知 ToBid SDK 加载失败
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAd:didLoadFailWithError:ext:)]) {
            [self.bridge splashAd:self didLoadFailWithError:error ext:@{}];
        }
        return;
    }

    self.placementId = placementId;
    self.hasCalledLoadSuccess = NO;
    self.hasCalledLoadFailed = NO;

    // 从 parameter 中获取额外参数
    UIView *customBottomView = nil;
    __block CGSize expectSize = CGSizeZero;
    NSInteger tolerateTimeout = 3; // 默认超时时间

    if (parameter && parameter.extra) {
        // 获取自定义底部视图
        customBottomView = [parameter.extra objectForKey:AWMAdLoadingParamSPCustomBottomView];
        self.bottomView = customBottomView;

        // 获取期望尺寸
        NSValue *sizeValue = [parameter.extra objectForKey:AWMAdLoadingParamSPExpectSize];
        if (sizeValue) {
            expectSize = [sizeValue CGSizeValue];
        }

        // 获取超时时间
        NSNumber *timeoutNumber = [parameter.extra objectForKey:AWMAdLoadingParamSPTolerateTimeout];
        if (timeoutNumber) {
            tolerateTimeout = [timeoutNumber integerValue];
        }
    }

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        // 如果没有指定尺寸，使用屏幕尺寸
        if (expectSize.width * expectSize.height == 0) {
            UIViewController *viewController = [self.bridge viewControllerForPresentingModalView];
            UIView *supView =
                viewController.navigationController ? viewController.navigationController.view : viewController.view;
            CGFloat bottomHeight = customBottomView ? CGRectGetHeight(customBottomView.frame) : 0;
            expectSize = CGSizeMake(supView.frame.size.width, supView.frame.size.height - bottomHeight);
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:placementId type:LMAdSlotTypeSplash];
        // 设置期望的图片尺寸
        slot.imgSize = expectSize;

        // 创建开屏广告实例
        self.splashAd = [[LMSplashAd alloc] initWithSlot:slot];
        // 设置代理为 self，用于接收广告回调
        self.splashAd.delegate = self;

        // 如果有底部视图，设置底部视图
        if (customBottomView) {
            self.splashAd.bottomLogoView = customBottomView;
        }

        // 开始加载广告
        [self.splashAd loadAd];
    });
}

- (void)showSplashAdInWindow:(UIWindow *)window parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"Splash showSplashAdInWindow: %@, parameter: %@", window, parameter);

    if (!self.splashAd) {
        LMSigmobLog(@"⚠️ Splash showSplashAdInWindow: splashAd 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobSplashAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告对象不存在"}];
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidShowFailed:error:)]) {
            [self.bridge splashAdDidShowFailed:self error:error];
        }
        return;
    }

    if (!window) {
        LMSigmobLog(@"⚠️ Splash showSplashAdInWindow: window 为空");
        NSError *error = [NSError errorWithDomain:@"LMSigmobSplashAdapter"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey : @"window 为空"}];
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidShowFailed:error:)]) {
            [self.bridge splashAdDidShowFailed:self error:error];
        }
        return;
    }

    // 检查广告是否已加载
    if (!self.splashAd.isLoaded) {
        LMSigmobLog(@"⚠️ Splash showSplashAdInWindow: 广告尚未加载完成");
        NSError *error = [NSError errorWithDomain:@"LMSigmobSplashAdapter"
                                             code:-4
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成"}];
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidShowFailed:error:)]) {
            [self.bridge splashAdDidShowFailed:self error:error];
        }
        return;
    }

    // 展示广告
    [self.splashAd showInWindow:window];
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    LMSigmobLog(@"Splash didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：此方法是否触发由 ToBid SDK 决定
    if (result) {
        // 获取竞价价格（如果 result 有 price 属性）
        if ([result respondsToSelector:@selector(price)]) {
            NSNumber *price = [result performSelector:@selector(price)];
            LMSigmobLog(@"Splash 收到竞价结果，价格：%@", price);
        }
        // 可以在这里处理其他竞价相关信息
    }
}

- (void)destory {
    LMSigmobLog(@"Splash destory");

    // 清理资源
    if (self.splashAd) {
        self.splashAd.delegate = nil;
        self.splashAd = nil;
    }
    self.bottomView = nil;
}

#pragma mark - LMSplashAdDelegate

/// 广告加载成功
- (void)lm_splashAdDidLoad:(LMSplashAd *)splashAd {
    LMSigmobLog(@"Splash lm_splashAdDidLoad: %@", splashAd);

    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        // 获取 eCPM（用于客户端竞价）
        // 注意：LitemobSDK 的 getEcpm 返回单位已经是"分"，直接使用
        NSString *ecpm = [splashAd getEcpm];
        NSDictionary *ext = @{};
        if (ecpm && ecpm.length > 0) {
            ext = @{AWMMediaAdLoadingExtECPM : ecpm};
            LMSigmobLog(@"Splash 客户端竞价，ECPM: %@分", ecpm);
        }

        // 通知 ToBid SDK 广告加载成功
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAd:didAdServerResponseWithExt:)]) {
            [self.bridge splashAd:self didAdServerResponseWithExt:ext];
        }
        if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidLoad:)]) {
            [self.bridge splashAdDidLoad:self];
        }
    }
}

/// 广告加载失败
- (void)lm_splashAd:(LMSplashAd *)splashAd didFailWithError:(NSError *)error {
    LMSigmobLog(@"Splash lm_splashAd:didFailWithError: %@", error);

    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;

        // 通知 ToBid SDK 广告加载失败
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
    LMSigmobLog(@"Splash lm_splashAdWillVisible: %@", splashAd);

    // 通知 ToBid SDK 广告即将展示
    if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdWillVisible:)]) {
        [self.bridge splashAdWillVisible:self];
    }
}

/// 广告被点击
- (void)lm_splashAdDidClick:(LMSplashAd *)splashAd {
    LMSigmobLog(@"Splash lm_splashAdDidClick: %@", splashAd);

    // 通知 ToBid SDK 广告被点击
    if (self.bridge) {
        if ([self.bridge respondsToSelector:@selector(splashAdDidClick:)]) {
            [self.bridge splashAdDidClick:self];
        }
        // 通知 ToBid SDK 广告将展示全屏内容
        if ([self.bridge respondsToSelector:@selector(splashAdWillPresentFullScreenModal:)]) {
            [self.bridge splashAdWillPresentFullScreenModal:self];
        }
    }
}

/// 广告已关闭
- (void)lm_splashAdDidClose:(LMSplashAd *)splashAd {
    LMSigmobLog(@"Splash lm_splashAdDidClose: %@", splashAd);

    // 通知 ToBid SDK 广告已关闭
    if (self.bridge && [self.bridge respondsToSelector:@selector(splashAdDidClose:)]) {
        [self.bridge splashAdDidClose:self];
    }

    // 清理资源
    self.splashAd.delegate = nil;
    self.splashAd = nil;
    self.bottomView = nil;
}

#pragma mark - Dealloc

- (void)dealloc {
    LMSigmobLog(@"Splash dealloc");

    // 确保清理资源
    if (self.splashAd) {
        self.splashAd.delegate = nil;
        self.splashAd = nil;
    }
    self.bottomView = nil;
}

@end
