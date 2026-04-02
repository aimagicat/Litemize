//
//  LMTakuBannerDelegate.h
//  LitemobSDK
//
//  Taku/AnyThink 横幅广告代理
//  用于处理 LitemobSDK 横幅广告的回调，并转换为 AnyThink SDK 的回调
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMBannerAd.h>

NS_ASSUME_NONNULL_BEGIN

@class ATBannerAdStatusBridge;

/// Taku/AnyThink 横幅广告代理
/// 遵循 LMBannerAdDelegate 协议，处理 LitemobSDK 的回调并转换为 AnyThink SDK 的回调
@interface LMTakuBannerDelegate : NSObject <LMBannerAdDelegate>

/// AnyThink SDK 的广告状态桥接对象
/// 用于将 LitemobSDK 的回调转换为 AnyThink SDK 的回调
@property(nonatomic, strong) ATBannerAdStatusBridge *adStatusBridge;

@end

NS_ASSUME_NONNULL_END
