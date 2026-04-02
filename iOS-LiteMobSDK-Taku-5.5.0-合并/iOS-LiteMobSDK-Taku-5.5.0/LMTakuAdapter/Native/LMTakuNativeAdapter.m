//
//  LMTakuNativeAdapter.m
//  LitemobSDK
//
//  Taku/AnyThink 原生（信息流）广告适配器实现
//
//  Created by Neko on 2026/01/28.
//

//  注意：此文件名必须与后台配置的自定义平台类名保持一致

#import "LMTakuNativeAdapter.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "LMTakuNativeDelegate.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <LitemobSDK/LMAdSlot.h>
#import <LitemobSDK/LMNativeAd.h>
#import <UIKit/UIKit.h>

@interface LMTakuNativeAdapter ()

/// 原生广告代理对象，用于处理 LitemobSDK 的回调并转换为 AnyThink SDK 的回调
@property(nonatomic, strong, nullable) LMTakuNativeDelegate *nativeDelegate;

/// LitemobSDK 的自渲染原生广告对象
@property(nonatomic, strong, nullable) LMNativeAd *nativeAd;

@end

@implementation LMTakuNativeAdapter

#pragma mark - Lazy

/// 懒加载原生广告代理对象
- (LMTakuNativeDelegate *)nativeDelegate {
    if (_nativeDelegate == nil) {
        _nativeDelegate = [[LMTakuNativeDelegate alloc] init];
        // 设置 AnyThink SDK 的广告状态桥接对象
        _nativeDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _nativeDelegate;
}

#pragma mark - ATBaseNativeAdapterProtocol

/// 加载原生广告
/// @param argument 包含服务器下发和本地配置的参数
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverContentDic = argument.serverContentDic ?: @{};

    // 获取广告位 ID（slot_id）
    NSString *slotId = serverContentDic[@"slot_id"];

    // 参数校验
    if (!slotId || slotId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LMTakuNativeAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slot_id 不能为空，请在后台配置 slot_id 参数"}];
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }

    // 获取原生广告渲染尺寸（从 localInfoDic 或 argument.nativeAdSize 中获取）
    CGSize nativeSize = CGSizeZero;
    id sizeValue = argument.localInfoDic[kATExtraInfoNativeAdSizeKey];
    if ([sizeValue respondsToSelector:@selector(CGSizeValue)]) {
        nativeSize = [sizeValue CGSizeValue];
    } else if (argument.nativeSize.width > 0 && argument.nativeSize.height > 0) {
        nativeSize = argument.nativeSize;
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        // 释放旧的原生广告实例
        if (strongSelf.nativeAd) {
            strongSelf.nativeAd.delegate = nil;
            [strongSelf.nativeAd close];
            strongSelf.nativeAd = nil;
        }

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeNative];
        if (nativeSize.width > 0 && nativeSize.height > 0) {
            slot.imgSize = nativeSize;
        }

        // 创建自渲染原生广告实例
        strongSelf.nativeAd = [[LMNativeAd alloc] initWithSlot:slot];
        if (!strongSelf.nativeAd) {
            LMTakuLog(@"Native", @"创建 LMNativeAd 失败");
            NSError *error = [NSError errorWithDomain:@"LMTakuNativeAdapter"
                                                 code:-2
                                             userInfo:@{NSLocalizedDescriptionKey : @"创建自渲染原生广告实例失败"}];
            if (strongSelf.adStatusBridge &&
                [strongSelf.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
                [strongSelf.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
            }
            return;
        }

        // 绑定代理与 mediation 参数
        strongSelf.nativeAd.delegate = strongSelf.nativeDelegate;
        strongSelf.nativeDelegate.adMediationArgument = argument;

        // 开始加载广告
        [strongSelf.nativeAd loadAd];
    });
}

#pragma mark - Dealloc

- (void)dealloc {
    LMTakuLog(@"Native", @"LMTakuNativeAdapter dealloc");
    if (self.nativeAd) {
        self.nativeAd.delegate = nil;
        [self.nativeAd close];
    }
    self.nativeAd = nil;
    self.nativeDelegate = nil;
}

@end
