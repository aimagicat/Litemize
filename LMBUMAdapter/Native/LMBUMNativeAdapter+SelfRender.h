//
//  LMBUMNativeAdapter+SelfRender.h
//  LitemobSDK
//
//  穿山甲（BUM）信息流自渲染广告处理分类
//  专门处理自渲染（Native）广告的逻辑
//

#import "LMBUMNativeAdapter.h"
#import <LitemobSDK/LitemobSDK.h>
NS_ASSUME_NONNULL_BEGIN

/// 自渲染广告处理分类
/// 负责处理所有自渲染广告相关的逻辑，包括加载、回调、视图注册等
@interface LMBUMNativeAdapter (SelfRender)

/// 加载自渲染广告
/// @param slotID 广告位ID
/// @param count 请求数量
/// @param size 广告尺寸
/// @param imageSize 图片尺寸
- (void)selfRender_loadAdsWithSlotID:(NSString *)slotID count:(NSInteger)count size:(CGSize)size imageSize:(CGSize)imageSize;

/// 检查并通知自渲染广告加载成功
- (void)selfRender_checkAndNotifyLoadSuccess;

/// 处理自渲染广告加载成功回调
/// @param dataObject 广告数据对象
/// @param nativeAd 广告实例
- (void)selfRender_handleAdLoaded:(LMNativeAdDataObject *)dataObject nativeAd:(LMNativeAd *)nativeAd;

/// 处理自渲染广告加载失败回调
/// @param nativeAd 广告实例
/// @param error 错误信息
/// @param description 错误描述
- (void)selfRender_handleAdLoadFailed:(LMNativeAd *)nativeAd error:(NSError *)error description:(NSDictionary *)description;

/// 处理自渲染广告曝光回调
/// @param nativeAd 广告实例
/// @param adView 广告视图
- (void)selfRender_handleAdWillExpose:(LMNativeAd *)nativeAd adView:(UIView *)adView;

/// 处理自渲染广告点击回调
/// @param nativeAd 广告实例
/// @param adView 广告视图
- (void)selfRender_handleAdDidClick:(LMNativeAd *)nativeAd adView:(UIView *)adView;

/// 处理自渲染广告详情页即将展示回调
/// @param nativeAd 广告实例
/// @param adView 广告视图
- (void)selfRender_handleAdDetailViewWillPresent:(LMNativeAd *)nativeAd adView:(UIView *)adView;

/// 处理自渲染广告详情页关闭回调
/// @param nativeAd 广告实例
/// @param adView 广告视图
- (void)selfRender_handleAdDetailViewClosed:(LMNativeAd *)nativeAd adView:(UIView *)adView;

@end

NS_ASSUME_NONNULL_END
