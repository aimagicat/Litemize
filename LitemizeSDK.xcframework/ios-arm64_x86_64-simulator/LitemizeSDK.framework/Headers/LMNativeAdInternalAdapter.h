//
//  LMNativeAd.h
//  LitemizeSDK
//
//  信息流自渲染广告
//

#import <Foundation/Foundation.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBaseAd.h>
#import <LitemizeSDK/LMCustomAdapterProtocol.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <LitemizeSDK/LMNativeAdViewMapping.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 信息流自渲染广告
/// - Note: 适用于信息流自渲染广告场景，开发者需要自定义广告视图布局
@interface LMNativeAdInternalAdapter : LMBaseAd <LMCustomNativeAdapter>

/// Bridge（Adapter 协议要求）
@property(nonatomic, weak, nullable) id<LMCustomNativeAdapterBridge> bridge;

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
