//
//  LMTakuNativeObject.h
//  LitemobSDK
//
//  Taku/AnyThink 自定义平台原生广告对象
//  继承 ATCustomNetworkNativeAd，用于承载 LitemobSDK 的 LMNativeAdDataObject 数据
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMNativeAd.h>
#import <LitemobSDK/LMNativeAdDataObject.h>

NS_ASSUME_NONNULL_BEGIN

/// Taku/AnyThink 自定义平台原生广告对象
/// 承载 LitemobSDK 的原生广告数据，并实现点击注册与配置能力
@interface LMTakuNativeObject : ATCustomNetworkNativeAd

/// LitemobSDK 自渲染原生广告实例
@property(nonatomic, strong, nullable) LMNativeAd *nativeAd;

/// LitemobSDK 自渲染原生广告数据对象
@property(nonatomic, strong, nullable) LMNativeAdDataObject *dataObject;

@end

NS_ASSUME_NONNULL_END
