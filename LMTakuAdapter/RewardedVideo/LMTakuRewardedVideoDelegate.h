//
//  LMTakuRewardedVideoDelegate.h
//  LitemobSDK
//
//  Taku/AnyThink 激励视频广告代理
//  用于处理 LitemobSDK 激励视频广告的回调，并转换为 AnyThink SDK 的回调
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMRewardedVideoAd.h>

NS_ASSUME_NONNULL_BEGIN

@class ATRewardedAdStatusBridge;

/// Taku/AnyThink 激励视频广告代理
/// 遵循 LMRewardedVideoAdDelegate 协议，处理 LitemobSDK 的回调并转换为 AnyThink SDK 的回调
@interface LMTakuRewardedVideoDelegate : NSObject <LMRewardedVideoAdDelegate>

/// AnyThink SDK 的广告状态桥接对象
/// 用于将 LitemobSDK 的回调转换为 AnyThink SDK 的回调
@property(nonatomic, strong) ATRewardedAdStatusBridge *adStatusBridge;

@end

NS_ASSUME_NONNULL_END
