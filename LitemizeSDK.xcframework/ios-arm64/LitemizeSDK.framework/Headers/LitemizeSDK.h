//
//  LitemizeSDK.h
//  LitemizeSDK
//
//  LitemizeSDK - 轻量级移动广告SDK
//  支持横幅广告、插屏广告、原生广告、激励视频、开屏广告等多种广告形式
//  提供简洁的API接口，易于集成，支持隐私合规配置
//
//  Created by Neko on 2025/11/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for LitemizeSDK.
//! 使用方式：NSLog(@"SDK Version Number: %f", LitemizeSDKVersionNumber);
FOUNDATION_EXPORT double LitemizeSDKVersionNumber;

//! Project version string for LitemizeSDK.
//! 使用方式：NSLog(@"SDK Version String: %s", LitemizeSDKVersionString);
//! 或者通过 [LMAdSDK sdkVersion] 方法获取版本号字符串
FOUNDATION_EXPORT const unsigned char LitemizeSDKVersionString[];

// MARK: - 基础配置类
// 广告位配置、错误定义、日志系统等基础功能
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMError.h>
#import <LitemizeSDK/LMLogger.h>

// MARK: - 基类
// 所有广告类型的基类
#import <LitemizeSDK/LMBaseAd.h>

// MARK: - 数据对象
// 原生广告相关的数据对象（包含 LMNativeAdMaterialObject 和 LMNativeAdDataObject）
#import <LitemizeSDK/LMNativeAdDataObject.h>

// MARK: - 协议
// 原生广告视图协议
#import <LitemizeSDK/LMNativeAdViewProtocol.h>

// MARK: - SDK 入口
// SDK 初始化和全局配置
#import <LitemizeSDK/LMAdSDK.h>
// SDK 配置构建器，支持链式调用设置属性
#import <LitemizeSDK/LMAdSDKConfigBuilder.h>

// MARK: - 广告类型
// 按字母顺序排列的具体广告类型实现
#import <LitemizeSDK/LMBannerAd.h>
#import <LitemizeSDK/LMInterstitialAd.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeExpressAd.h>
#import <LitemizeSDK/LMRewardedVideoAd.h>
#import <LitemizeSDK/LMSplashAd.h>

// MARK: - Debug工具（可选功能）
#if LITE_MOB_CXH_SDK_ENABLE_DEBUG_PANEL
#import <LitemizeSDK/LMDebugLogPanelManager.h>
#import <LitemizeSDK/LMDebugLogPanelView.h>
#endif
