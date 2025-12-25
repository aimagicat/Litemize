//
//  LMSplashSelfRenderAd.h
//  LitemizeSDK
//
//  开屏自渲染广告
//

#import <Foundation/Foundation.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBaseAd.h>
#import <LitemizeSDK/LMSplashSelfRenderAdDataObject.h>
#import <LitemizeSDK/LMSplashSelfRenderAdViewProtocol.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMSplashSelfRenderAd;

/// 开屏自渲染广告代理
@protocol LMSplashSelfRenderAdDelegate <NSObject>

@optional

/// 广告数据返回
/// - Parameters:
///   - dataObject: 广告数据对象，可能为 nil
///   - splashSelfRenderAd: 开屏自渲染广告实例
/// - Note: 一个 LMSplashSelfRenderAd 实例只维护一个广告
- (void)lm_splashSelfRenderAdLoaded:(nullable LMSplashSelfRenderAdDataObject *)dataObject
                 splashSelfRenderAd:(LMSplashSelfRenderAd *)splashSelfRenderAd;

/// 开屏自渲染广告加载失败
/// - Parameters:
///   - splashSelfRenderAd: 开屏自渲染广告实例
///   - error: 错误信息
///   - description: 错误描述字典
- (void)lm_splashSelfRenderAd:(LMSplashSelfRenderAd *)splashSelfRenderAd
             didFailWithError:(nullable NSError *)error
                  description:(NSDictionary *)description;

/// 广告即将展示
/// - Parameter splashSelfRenderAd: 开屏自渲染广告实例
- (void)lm_splashSelfRenderAdWillVisible:(LMSplashSelfRenderAd *)splashSelfRenderAd;

/// 广告被点击
/// - Parameter splashSelfRenderAd: 开屏自渲染广告实例
- (void)lm_splashSelfRenderAdDidClick:(LMSplashSelfRenderAd *)splashSelfRenderAd;

/// 广告已关闭
/// - Parameter splashSelfRenderAd: 开屏自渲染广告实例
/// - Note: UI的移除和数据的解绑需要在该回调中进行
- (void)lm_splashSelfRenderAdDidClose:(LMSplashSelfRenderAd *)splashSelfRenderAd;

/// 倒计时更新回调
/// - Parameters:
///   - remainingSeconds: 剩余秒数
///   - splashSelfRenderAd: 开屏自渲染广告实例
/// - Note: 每秒调用一次，从 countdownInterval 开始倒计时到 0
- (void)lm_splashSelfRenderAd:(LMSplashSelfRenderAd *)splashSelfRenderAd countdownUpdate:(NSUInteger)remainingSeconds;

@end

/// 开屏自渲染广告
/// - Note: 适用于开屏自渲染广告场景，开发者需要自定义广告视图布局
///         SDK会通过代理方法定时返回倒计时信息
@interface LMSplashSelfRenderAd : LMBaseAd

/// 代理
@property(nonatomic, weak) id<LMSplashSelfRenderAdDelegate> delegate;

/// 广告加载容器视图控制器（必填）
@property(nonatomic, weak) UIViewController *viewController;

/// 倒计时时长（秒），默认 5 秒
/// - Note: 用于倒计时总时长，SDK会通过代理方法定时返回剩余秒数
@property(nonatomic, assign) NSUInteger countdownInterval;

/// 初始化方法
/// - Parameter adSlot: 广告位配置，需设置 slotId
/// - Returns: 如果 adSlot 为空或配置无效，返回 nil
- (nullable instancetype)initWithSlot:(LMAdSlot *)adSlot;

/// 加载广告
- (void)loadAd;

/// 广告是否有效
/// - Returns: YES 表示广告有效，NO 表示已过期或未加载
- (BOOL)isAdValid;

/// 当前广告数据对象（只读）
/// - Note: 在 loadAd 成功后，通过 lm_splashSelfRenderAdLoaded:splashSelfRenderAd: 回调获取，或直接访问此属性
///         一个 LMSplashSelfRenderAd 实例只维护一个广告
@property(nonatomic, readonly, nullable) LMSplashSelfRenderAdDataObject *dataObject;

/// 注册广告视图（用于曝光监听和点击上报）
/// - Parameter adView: 广告视图，必须实现 LMSplashSelfRenderAdViewProtocol 协议
/// - Note: 必须在广告视图添加到父视图之前调用
///         SDK 会自动从已加载的广告数据中获取素材信息，监听广告视图的点击事件进行上报，并监听摇一摇视图的摇一摇事件
///         摇一摇视图通过协议的 yaoyiyaoView 属性获取，如果为 nil，SDK 会根据策略自动创建（如果策略允许）
///         一个 LMSplashSelfRenderAd 实例只维护一个广告，因此不需要传入 dataObject 参数
///         视图必须实现 LMSplashSelfRenderAdViewProtocol 协议
- (void)registerAdView:(UIView<LMSplashSelfRenderAdViewProtocol> *)adView;

/// 展示广告到 window
/// - Parameter window: 展示广告的 window
/// - Note: 必须在 registerAdView: 之后调用
- (void)showInWindow:(UIWindow *)window;

/// 关闭广告（释放资源）
/// - Note: 调用此方法会清理所有已注册的视图、摇一摇视图和相关资源，释放广告对象
- (void)close;

@end

NS_ASSUME_NONNULL_END
