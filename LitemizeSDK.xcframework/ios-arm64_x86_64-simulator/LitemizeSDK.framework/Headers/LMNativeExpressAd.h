//
//  LMNativeExpressAd.h
//  LitemizeSDK
//
//  信息流模版渲染广告
//

#import <Foundation/Foundation.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <UIKit/UIKit.h>

@class LMNativeExpressAd;
NS_ASSUME_NONNULL_BEGIN

/// 信息流广告代理
@protocol LMNativeExpressAdDelegate <NSObject>
@optional
/// 广告数据加载成功回调
/// - Parameter nativeExpressAd: 信息流广告实例
/// - Note: 加载成功后，可以通过 nativeExpressAd.expressView 获取广告视图
- (void)lm_nativeExpressAdLoaded:(LMNativeExpressAd *)nativeExpressAd;

/// 广告加载失败
/// - Parameters:
///   - nativeExpressAd: 信息流广告实例
///   - error: 错误信息
///   - description: 错误描述字典
- (void)lm_nativeExpressAd:(LMNativeExpressAd *)nativeExpressAd
          didFailWithError:(nullable NSError *)error
               description:(NSDictionary *)description;

/// 信息流广告渲染成功
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewRenderSuccess:(LMNativeExpressAd *)nativeExpressAd;

/// 信息流广告渲染失败
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewRenderFail:(LMNativeExpressAd *)nativeExpressAd;

/// 广告即将曝光
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewWillExpose:(LMNativeExpressAd *)nativeExpressAd;

/// 广告被点击
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewDidClick:(LMNativeExpressAd *)nativeExpressAd;

/// 广告关闭回调
/// - Note: UI的移除和数据的解绑需要在该回调中进行
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdDidClose:(LMNativeExpressAd *)nativeExpressAd;
@end

/// 信息流模版渲染广告
/// - Note: 适用于信息流广告/沉浸式视频流广告/详情页插入广告/视频贴片广告等场景
@interface LMNativeExpressAd : NSObject

/// 代理
@property(nonatomic, weak) id<LMNativeExpressAdDelegate> delegate;

/// 广告加载容器视图控制器（必填）
@property(nonatomic, weak) UIViewController *viewController;

/// 信息流广告视图（只读）
/// - Note: 需要将此视图添加到容器中才能展示广告
@property(nonatomic, strong, readonly, nullable) UIView *expressView;

/// 初始化方法
/// - Parameter adSlot: 广告位配置，需设置 slotId 和 imgSize
/// - Returns: 如果 adSlot 为空或类型不正确，返回 nil
- (nullable instancetype)initWithSlot:(LMAdSlot *)adSlot;

/// 加载广告
- (void)loadAd;

/// 广告是否有效
/// - Returns: YES 表示广告有效，NO 表示已过期或未加载
- (BOOL)isAdValid;

/// 展示广告到指定容器视图
/// - Parameter containerView: 容器视图，广告视图将添加到该视图中
/// - Note: 调用此方法会将广告视图添加到容器中，并自动触发曝光上报
- (void)showInView:(UIView *)containerView;

/// 关闭广告，释放前调用
/// - Note: 调用此方法后，广告对象将无法继续使用
- (void)close;

/// 广告是否有效（未过期）
/// @return YES 表示广告有效，NO 表示已过期
- (BOOL)isAdValid;

/// 获取广告的 eCPM（每千次展示成本，单位：元）
/// @return eCPM 字符串，格式化为两位小数（如 "1.23"），如果没有 bid 或 price 为 0，返回 "0.00"
- (NSString *)getEcpm;

/// 广告是否已加载
/// @return YES 表示广告已加载，NO 表示未加载
- (BOOL)isLoaded;
@end

NS_ASSUME_NONNULL_END
