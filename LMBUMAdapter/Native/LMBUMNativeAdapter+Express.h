//
//  LMBUMNativeAdapter+Express.h
//  LitemizeSDK
//
//  穿山甲（BUM）信息流模板广告处理分类
//  专门处理模板（Express）广告的逻辑
//

#import "LMBUMNativeAdapter.h"

@class LMNativeExpressAd;

NS_ASSUME_NONNULL_BEGIN

/// 模板广告处理分类
/// 负责处理所有模板广告相关的逻辑，包括加载、渲染、回调等
@interface LMBUMNativeAdapter (Express)

/// 加载模板广告
/// @param slotID 广告位ID
/// @param count 请求数量
/// @param size 广告尺寸
/// @param imageSize 图片尺寸
- (void)express_loadAdsWithSlotID:(NSString *)slotID count:(NSInteger)count size:(CGSize)size imageSize:(CGSize)imageSize;

/// 检查并通知模板广告加载成功
- (void)express_checkAndNotifyLoadSuccess;

/// 处理模板广告渲染
/// @param expressAdView 模板广告视图（expressView）
- (void)express_handleRenderForView:(UIView *)expressAdView;

/// 处理模板广告加载成功回调
/// @param nativeExpressAd 广告实例
- (void)express_handleAdLoaded:(LMNativeExpressAd *)nativeExpressAd;

/// 处理模板广告加载失败回调
/// @param nativeExpressAd 广告实例
/// @param error 错误信息
/// @param description 错误描述
- (void)express_handleAdLoadFailed:(LMNativeExpressAd *)nativeExpressAd
                             error:(NSError *)error
                       description:(NSDictionary *)description;

/// 处理模板广告渲染成功回调
/// @param nativeExpressAd 广告实例
- (void)express_handleRenderSuccess:(LMNativeExpressAd *)nativeExpressAd;

/// 处理模板广告渲染失败回调
/// @param nativeExpressAd 广告实例
- (void)express_handleRenderFail:(LMNativeExpressAd *)nativeExpressAd;

/// 处理模板广告曝光回调
/// @param nativeExpressAd 广告实例
- (void)express_handleAdWillExpose:(LMNativeExpressAd *)nativeExpressAd;

/// 处理模板广告点击回调
/// @param nativeExpressAd 广告实例
- (void)express_handleAdDidClick:(LMNativeExpressAd *)nativeExpressAd;

/// 处理模板广告关闭回调
/// @param nativeExpressAd 广告实例
- (void)express_handleAdDidClose:(LMNativeExpressAd *)nativeExpressAd;

@end

NS_ASSUME_NONNULL_END
