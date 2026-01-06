//
//  LMSigmobNativeAdViewCreator.h
//  LitemizeSDK
//
//  Sigmob 原生广告视图创建器
//  实现 AWMMediatedNativeAdViewCreator 协议，提供媒体视图和标题标签
//

#import <Foundation/Foundation.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class LMNativeAd;
@class LMNativeAdDataObject;

/// Sigmob 原生广告视图创建器
/// 实现 AWMMediatedNativeAdViewCreator 协议，提供媒体视图和标题标签
@interface LMSigmobNativeAdViewCreator : NSObject <AWMMediatedNativeAdViewCreator>

/// 初始化方法（自渲染广告）
/// @param nativeAd 原始广告实例
- (instancetype)initWithNativeAd:(LMNativeAd *)nativeAd;

/// 初始化方法（模板渲染广告）
/// @param expressAdView 模板广告视图
- (instancetype)initWithExpressAdView:(UIView *)expressAdView;

@end

NS_ASSUME_NONNULL_END
