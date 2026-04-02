//
//  LMTakuSplashDelegate.h
//  LitemobSDK
//
//  Taku/AnyThink 开屏广告代理
//  用于处理 LitemobSDK 开屏广告的回调，并转换为 AnyThink SDK 的回调
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMSplashAd.h>

NS_ASSUME_NONNULL_BEGIN

@class ATSplashAdStatusBridge;

/// Taku/AnyThink 开屏广告代理
/// 遵循 LMSplashAdDelegate 协议，处理 LitemobSDK 的回调并转换为 AnyThink SDK 的回调
@interface LMTakuSplashDelegate : NSObject <LMSplashAdDelegate>

/// AnyThink SDK 的广告状态桥接对象
/// 用于将 LitemobSDK 的回调转换为 AnyThink SDK 的回调
@property(nonatomic, strong) ATSplashAdStatusBridge *adStatusBridge;

@end

NS_ASSUME_NONNULL_END
