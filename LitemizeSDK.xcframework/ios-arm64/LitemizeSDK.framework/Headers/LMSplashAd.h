//
//  LMSplashAd.h
//  LitemizeSDK
//

#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBaseAd.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMSplashAd;

/// 开屏广告代理
@protocol LMSplashAdDelegate <NSObject>
@optional
/// 广告加载成功
- (void)lm_splashAdDidLoad:(LMSplashAd *)splashAd;
/// 广告加载失败
- (void)lm_splashAd:(LMSplashAd *)splashAd didFailWithError:(NSError *)error;
/// 广告即将展示
- (void)lm_splashAdWillVisible:(LMSplashAd *)splashAd;
/// 广告被点击
- (void)lm_splashAdDidClick:(LMSplashAd *)splashAd;
/// 广告已关闭
- (void)lm_splashAdDidClose:(LMSplashAd *)splashAd;
@end

/// MVP 开屏广告，支持加载与展示
/// 布局风格由SDK内部根据设置的参数自动选择：
/// - 设置了bottomLogoView或bottomAppNameLabel时：使用底部信息风格（logo+应用名称）
/// - 未设置时：使用左上角logo风格（需要设置topLogoView）
@interface LMSplashAd : NSObject

/// 代理
@property(nonatomic, weak) id<LMSplashAdDelegate> delegate;
/// 广告是否有效（未过期）
/// @return YES 表示广告有效，NO 表示已过期
- (BOOL)isAdValid;

/// 获取广告的 eCPM（每千次展示成本，单位：元）
/// @return eCPM 字符串，格式化为两位小数（如 "1.23"），如果没有 bid 或 price 为 0，返回 "0.00"
- (NSString *)getEcpm;

/// 广告是否已加载
/// @return YES 表示广告已加载，NO 表示未加载
- (BOOL)isLoaded;

/// 底部信息区域的Logo视图（可选，由应用提供，用于底部信息风格）
@property(nonatomic, strong, nullable) UIView *bottomLogoView;

/// 底部信息区域的应用名称标签（可选，由应用提供，用于底部信息风格）
@property(nonatomic, strong, nullable) UILabel *bottomAppNameLabel;

- (instancetype)initWithSlot:(LMAdSlot *)adSlot;

/// 加载广告
- (void)loadAd;

/// 展示广告到 window.rootViewController
- (void)showInWindow:(UIWindow *)window;

/// 关闭广告
- (void)close;

@end

NS_ASSUME_NONNULL_END
