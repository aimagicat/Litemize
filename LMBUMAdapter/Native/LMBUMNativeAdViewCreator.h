//
//  LMBUMNativeAdViewCreator.h
//  LitemizeSDK
//
//  穿山甲（BUM）信息流广告视图创建器
//  实现 BUMMediatedNativeAdViewCreator 协议，提供媒体视图和标题标签
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>

NS_ASSUME_NONNULL_BEGIN

/// 穿山甲信息流广告视图创建器
/// 实现 BUMMediatedNativeAdViewCreator 协议，提供媒体视图和标题标签
@interface LMBUMNativeAdViewCreator : NSObject <BUMMediatedNativeAdViewCreator>

/// 初始化方法
/// @param nativeAd 原始广告实例
/// @param delegate 视图代理（用于设置 LMNativeAd 的 delegate）
- (instancetype)initWithNativeAd:(LMNativeAd *)nativeAd viewDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
