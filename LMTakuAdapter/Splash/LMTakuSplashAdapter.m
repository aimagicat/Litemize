//
//  LMTakuSplashAdapter.m
//  LitemobSDK
//
//  Taku/AnyThink 开屏广告适配器实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuSplashAdapter.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "LMTakuSplashDelegate.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMSplashAd.h>
#import <UIKit/UIKit.h>

@interface LMTakuSplashAdapter ()

/// 开屏广告代理对象，用于处理 LitemobSDK 的回调并转换为 AnyThink SDK 的回调
@property(nonatomic, strong, nullable) LMTakuSplashDelegate *splashDelegate;

/// LitemobSDK 的开屏广告对象
@property(nonatomic, strong, nullable) LMSplashAd *splashAd;

@end

@implementation LMTakuSplashAdapter

#pragma mark - Lazy Properties

/// 懒加载开屏广告代理对象
- (LMTakuSplashDelegate *)splashDelegate {
    if (_splashDelegate == nil) {
        _splashDelegate = [[LMTakuSplashDelegate alloc] init];
        // 设置 AnyThink SDK 的广告状态桥接对象
        _splashDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _splashDelegate;
}

#pragma mark - Ad Load

/// 加载开屏广告
/// @param argument 包含服务器下发和本地配置的参数
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    // 从 argument 对象中获取必要的加载信息
    NSDictionary *serverContentDic = argument.serverContentDic ?: @{};
    NSDictionary *localInfoDic = argument.localInfoDic ?: @{};

    // 获取广告位 ID（slot_id）
    NSString *slotId = serverContentDic[@"slot_id"];

    // 参数校验
    if (!slotId || slotId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LMTakuSplashAdapter"
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

        // 先释放上一个开屏广告实例（如果存在）
        if (strongSelf.splashAd) {
            strongSelf.splashAd.delegate = nil;
            strongSelf.splashAd = nil;
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeSplash];

        // 创建开屏广告实例
        strongSelf.splashAd = [[LMSplashAd alloc] initWithSlot:slot];
        // 设置代理为 splashDelegate，用于接收广告回调
        strongSelf.splashAd.delegate = strongSelf.splashDelegate;

        // 开始加载广告
        [strongSelf.splashAd loadAd];
    });
}

#pragma mark - Ad Show

/// 展示开屏广告
/// @param window 展示广告的窗口
/// @param viewController 展示广告时传入的 UIViewController
/// @param parameter 展示参数（可选）
- (void)showSplashAdInWindow:(UIWindow *)window
            inViewController:(UIViewController *)viewController
                   parameter:(NSDictionary *)parameter {
    LMTakuLog(@"Splash", @"showSplashAdInWindow: %@, inViewController: %@, parameter: %@", window, viewController, parameter);

    // 参数校验
    if (!window) {
        NSError *error = [NSError errorWithDomain:@"LMTakuSplashAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"window 不能为空"}];
        // 通知 AnyThink SDK 展示失败
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShowFailed:extra:)]) {
            [self.adStatusBridge atOnAdShowFailed:error extra:nil];
        }
        return;
    }

    // 检查广告是否已加载且有效
    if (!self.splashAd || !self.splashAd.isLoaded || !self.splashAd.isAdValid) {
        NSError *error = [NSError errorWithDomain:@"LMTakuSplashAdapter"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告尚未加载完成或已过期"}];
        // 通知 AnyThink SDK 展示失败
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShowFailed:extra:)]) {
            [self.adStatusBridge atOnAdShowFailed:error extra:nil];
        }
        return;
    }

    // 展示广告（开屏广告使用 showInWindow: 方法）
    [self.splashAd showInWindow:window];
}

#pragma mark - Ad Ready

/// 检查开屏广告是否准备就绪
/// @param info 广告信息字典
/// @return YES 表示广告已准备就绪，NO 表示未准备就绪
- (BOOL)adReadySplashWithInfo:(NSDictionary *)info {
    // 检查广告是否已加载且有效
    return self.splashAd != nil && self.splashAd.isLoaded && self.splashAd.isAdValid;
}

#pragma mark - Dealloc

- (void)dealloc {
    LMTakuLog(@"Splash", @"LMTakuSplashAdapter dealloc");
    if (self.splashAd) {
        self.splashAd.delegate = nil;
        [self.splashAd close];
        self.splashAd = nil;
    }
    self.splashDelegate = nil;
}

@end
