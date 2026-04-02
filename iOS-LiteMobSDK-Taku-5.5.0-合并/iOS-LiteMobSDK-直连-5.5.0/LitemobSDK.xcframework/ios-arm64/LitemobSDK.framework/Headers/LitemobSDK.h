//
//  LitemobSDK.h
//  LitemobSDK
//
//  LitemobSDK - 轻量级移动广告SDK
//  支持横幅广告、插屏广告、原生广告、激励视频、开屏广告等多种广告形式
//  提供简洁的API接口，易于集成，支持隐私合规配置
//
//  Created by Neko on 2025/11/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// MARK: - 基础配置类
// 广告位配置、错误定义、日志系统等基础功能
#import <LitemobSDK/LMError.h>
#import <LitemobSDK/LMLogger.h>

// MARK: - 数据对象
// 原生广告相关的数据对象（包含 LMNativeAdMaterialObject 和 LMNativeAdDataObject）
#import <LitemobSDK/LMNativeAdDataObject.h>

// MARK: - SDK 入口
// SDK 初始化和全局配置
#import <LitemobSDK/LMAdSDK.h>
// SDK 配置构建器，支持链式调用设置属性
#import <LitemobSDK/LMAdSDKConfigBuilder.h>

// MARK: - 广告类型
// 按字母顺序排列的具体广告类型实现
#import <LitemobSDK/LMBannerAd.h>
#import <LitemobSDK/LMInterstitialAd.h>
#import <LitemobSDK/LMNativeAd.h>
#import <LitemobSDK/LMNativeExpressAd.h>
#import <LitemobSDK/LMRewardedVideoAd.h>
#import <LitemobSDK/LMSplashAd.h>

// MARK: - Debug工具（可选功能）
#if LITE_MOB_CXH_SDK_ENABLE_DEBUG_PANEL
#import <LitemobSDK/LMDebugLogPanelManager.h>
#import <LitemobSDK/LMDebugLogPanelView.h>
#endif
