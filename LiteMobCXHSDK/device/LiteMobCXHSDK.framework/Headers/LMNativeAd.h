//
//  LMNativeAd.h
//  LiteMobCXHSDK
//
//  信息流自渲染广告
//

#import <Foundation/Foundation.h>
#import <LiteMobCXHSDK/LMBaseAd.h>
#import <LiteMobCXHSDK/LMNativeAdConfig.h>
#import <LiteMobCXHSDK/LMNativeObject.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMNativeAd;

/// 信息流自渲染广告代理
@protocol LMNativeAdDelegate <NSObject>

@optional

/// 广告策略服务加载成功
/// - Parameter nativeAd: 信息流自渲染广告实例
- (void)lm_didFinishLoadingADPolicy:(LMNativeAd *)nativeAd;

/// 广告数据返回
/// - Parameters:
///   - adObjects: 广告对象数组，可能为空
///   - nativeAd: 信息流自渲染广告实例
- (void)lm_nativeAdLoaded:(nullable NSArray<LMNativeObject *> *)adObjects nativeAd:(LMNativeAd *)nativeAd;

/// 信息流自渲染加载失败
/// - Parameters:
///   - nativeAd: 信息流自渲染广告实例
///   - error: 错误信息
///   - description: 错误描述字典
- (void)lm_nativeAd:(LMNativeAd *)nativeAd didFailWithError:(nullable NSError *)error description:(NSDictionary *)description;

/// 广告曝光回调
/// - Parameters:
///   - nativeAd: 信息流自渲染广告实例
///   - adView: 广告视图
- (void)lm_nativeAdViewWillExpose:(LMNativeAd *)nativeAd adView:(UIView *)adView;

/// 广告点击回调
/// - Parameters:
///   - nativeAd: 信息流自渲染广告实例
///   - adView: 广告视图
- (void)lm_nativeAdViewDidClick:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView;

/// 广告点击关闭回调
/// - Parameters:
///   - nativeAd: 信息流自渲染广告实例
///   - adView: 广告视图
/// - Note: UI的移除和数据的解绑需要在该回调中进行
- (void)lm_nativeAdDidClose:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView;

/// 广告详情页面即将展示回调
/// - Parameters:
///   - nativeAd: 信息流自渲染广告实例
///   - adView: 广告视图
/// - Note: 当广告位落地页广告时会触发
- (void)lm_nativeAdDetailViewWillPresentScreen:(LMNativeAd *)nativeAd adView:(UIView *)adView;

/// 广告详情页关闭回调，即落地页关闭回调
/// - Parameters:
///   - nativeAd: 信息流自渲染广告实例
///   - adView: 广告视图
/// - Note: 当关闭弹出的落地页时触发
- (void)lm_nativeAdDetailViewClosed:(LMNativeAd *)nativeAd adView:(UIView *)adView;

@end

/// 信息流自渲染广告
/// - Note: 适用于信息流自渲染广告场景，开发者需要自定义广告视图布局
@interface LMNativeAd : LMBaseAd

/// 代理
@property(nonatomic, weak) id<LMNativeAdDelegate> delegate;

/// 配置信息（只读）
@property(nonatomic, strong, readonly) LMNativeAdConfig *config;

/// 初始化方法
/// - Parameter config: 信息流自渲染广告配置
/// - Returns: 如果 config 为空或配置无效，返回 nil
- (nullable instancetype)initWithConfig:(LMNativeAdConfig *)config;

/// 加载广告
- (void)loadAd;

/// 广告是否有效
/// - Returns: YES 表示广告有效，NO 表示已过期或未加载
- (BOOL)isAdValid;

@end

NS_ASSUME_NONNULL_END
