
//
//  LMTakuBannerAdapter.m
//  LitemobSDK
//
//  Taku/AnyThink 横幅广告适配器实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuBannerAdapter.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "LMTakuBannerDelegate.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMBannerAd.h>
#import <UIKit/UIKit.h>

@interface LMTakuBannerAdapter ()

/// 横幅广告代理对象，用于处理 LitemobSDK 的回调并转换为 AnyThink SDK 的回调
@property(nonatomic, strong, nullable) LMTakuBannerDelegate *bannerDelegate;

/// LitemobSDK 的横幅广告对象
@property(nonatomic, strong, nullable) LMBannerAd *bannerAd;

@end

@implementation LMTakuBannerAdapter

#pragma mark - Lazy Properties

/// 懒加载横幅广告代理对象
- (LMTakuBannerDelegate *)bannerDelegate {
    if (_bannerDelegate == nil) {
        _bannerDelegate = [[LMTakuBannerDelegate alloc] init];
        // 设置 AnyThink SDK 的广告状态桥接对象
        _bannerDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _bannerDelegate;
}

#pragma mark - Ad Load

/// 加载横幅广告
/// @param argument 包含服务器下发和本地配置的参数
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    // 从 argument 对象中获取必要的加载信息
    NSDictionary *serverContentDic = argument.serverContentDic ?: @{};
    NSDictionary *localInfoDic = argument.localInfoDic ?: @{};

    // 获取广告位 ID（slot_id）
    NSString *slotId = serverContentDic[@"slot_id"];

    // 参数校验
    if (!slotId || slotId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LMTakuBannerAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slot_id 不能为空，请在后台配置 slot_id 参数"}];
        // 通知 AnyThink SDK 加载失败
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }

    // 获取 Banner 尺寸（从 argument 中获取，如果没有则使用默认值 320x50）
    CGSize bannerSize = CGSizeMake(320, 50);
    if (argument.bannerSize.width > 0 && argument.bannerSize.height > 0) {
        bannerSize = argument.bannerSize;
    }

    // 在主线程创建并加载广告
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        // 先释放上一个横幅广告实例（如果存在）
        if (strongSelf.bannerAd) {
            strongSelf.bannerAd.delegate = nil;
            [strongSelf.bannerAd close];
            strongSelf.bannerAd = nil;
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeBanner];
        // 设置图片尺寸（Banner 广告尺寸）
        slot.imgSize = bannerSize;

        // 创建横幅广告实例
        strongSelf.bannerAd = [[LMBannerAd alloc] initWithSlot:slot];
        // 设置代理为 bannerDelegate，用于接收广告回调
        strongSelf.bannerAd.delegate = strongSelf.bannerDelegate;

        // 开始加载广告
        [strongSelf.bannerAd loadAd];
    });
}

#pragma mark - Dealloc

- (void)dealloc {
    LMTakuLog(@"Banner", @"LMTakuBannerAdapter dealloc");
    if (self.bannerAd) {
        self.bannerAd.delegate = nil;
        [self.bannerAd close];
    }
    self.bannerDelegate = nil;
    self.bannerAd = nil;
}

@end
