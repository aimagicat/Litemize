//
//  LMNativeAd.h
//  LitemizeSDK
//
//  信息流自渲染广告
//

#import <Foundation/Foundation.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBaseAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <LitemizeSDK/LMNativeAdViewMapping.h>
#import <LitemizeSDK/LMNativeAdViewProtocol.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMNativeAd;

/// 信息流自渲染广告代理
@protocol LMNativeAdDelegate <NSObject>

@optional

/// 广告数据返回
/// - Parameters:
///   - dataObject: 广告数据对象，可能为 nil
///   - nativeAd: 信息流自渲染广告实例
/// - Note: 一个 LMNativeAd 实例只维护一个广告
- (void)lm_nativeAdLoaded:(nullable LMNativeAdDataObject *)dataObject nativeAd:(LMNativeAd *)nativeAd;

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
/// 当前广告数据对象（只读）
/// - Note: 在 loadAd 成功后，通过 lm_nativeAdLoaded:nativeAd: 回调获取，或直接访问此属性
///         一个 LMNativeAd 实例只维护一个广告
@property(nonatomic, readonly, nullable) LMNativeAdDataObject *dataObject;

/// 广告加载容器视图控制器
@property(nonatomic, weak, nullable) UIViewController *viewController;

/// 初始化方法
/// - Parameter adSlot: 广告位配置，需设置 slotId 和 imgSize
/// - Returns: 如果 adSlot 为空或配置无效，返回 nil
- (nullable instancetype)initWithSlot:(LMAdSlot *)adSlot;

/// 加载广告
- (void)loadAd;

/// 广告是否有效
/// - Returns: YES 表示广告有效，NO 表示已过期或未加载
- (BOOL)isAdValid;

/// 注册广告视图（用于曝光监听和点击上报）
/// - Parameter adView: 广告视图，可选实现 LMNativeAdViewProtocol 协议
/// - Note: 必须在广告视图添加到父视图之前调用
///         这是便捷方法，等同于调用 registerAdView:withMapping: 并传入 nil
- (void)registerAdView:(UIView *)adView;

/// 注册广告视图（用于曝光监听和点击上报），支持属性映射和视图层级配置
/// - Parameters:
///   - adView: 广告视图
///   - mapping: 属性映射配置（可选），用于将第三方广告视图的属性映射为协议属性
/// - Note: 适用于 adapter 场景，当 adView 不实现协议但需要映射属性时使用
///         如果 adView 已实现协议，则优先使用协议中的属性
///         如果同时提供了 mapping 和协议属性，优先使用协议属性
///         mapping.viewsToBringToFront 中的视图会自动提到 touchView 上层
- (void)registerAdView:(UIView *)adView withMapping:(nullable LMNativeAdViewMapping *)mapping;

/// 关闭广告（释放资源）
/// - Note: 调用此方法会清理所有已注册的视图、摇一摇视图和相关资源，释放广告对象
- (void)close;

@end

NS_ASSUME_NONNULL_END
