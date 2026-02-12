//
//  LMTakuNativeDelegate.h
//  LitemobSDK
//
//  Taku/AnyThink 原生广告代理
//  负责接收 LitemobSDK LMNativeAd 回调，并转换为 AnyThink 原生广告事件
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMNativeAd.h>
#import <LitemobSDK/LMNativeAdDataObject.h>

NS_ASSUME_NONNULL_BEGIN

@class ATNativeAdStatusBridge;

/// Taku/AnyThink 原生广告代理
/// 遵循 LMNativeAdDelegate 协议，将 LitemobSDK 的原生广告事件上报给 AnyThink
@interface LMTakuNativeDelegate : NSObject <LMNativeAdDelegate>

/// AnyThink SDK 的广告状态桥接对象
/// 用于将 LitemobSDK 的回调转换为 AnyThink SDK 的回调
@property(nonatomic, strong) ATNativeAdStatusBridge *adStatusBridge;

/// 当前加载使用的 mediation 参数（包含服务端与本地配置）
@property(nonatomic, strong) ATAdMediationArgument *adMediationArgument;

@end

NS_ASSUME_NONNULL_END
