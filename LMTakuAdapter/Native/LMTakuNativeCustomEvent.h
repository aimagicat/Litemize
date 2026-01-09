//
//  LMTakuNativeCustomEvent.h
//  LitemizeSDK
//
//  Taku/AnyThink 原生广告 CustomEvent
//  用于处理 LitemizeSDK 原生广告的回调，并转换为 Taku SDK 的回调
//

#import <AnyThinkNative/AnyThinkNative.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 原生广告 CustomEvent
/// 继承 ATNativeCustomEvent，处理广告回调并转换为 Taku SDK 的回调
@interface LMTakuNativeCustomEvent : ATNativeADCustomEvent <LMNativeAdDelegate, LMNativeExpressAdDelegate>

/// 当前的原生广告实例（用于保持引用，防止被释放）
@property(nonatomic, strong, nullable) LMNativeAd *nativeAd;

/// 当前的原生模板广告实例（用于保持引用，防止被释放）
@property(nonatomic, strong, nullable) LMNativeExpressAd *nativeExpressAd;

/// 渲染类型（0: 自渲染, 1: 模板渲染）
@property(nonatomic, assign) NSInteger layoutType;

@end

NS_ASSUME_NONNULL_END
