//
//  LMBannerAd.h
//  LitemobSDK
//
//  Banner 横幅广告（门面类，通过 Adapter 模式加载广告）
//

#import <LitemobSDK/LMAdSlot.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMBannerAd;

/// Banner 广告代理
@protocol LMBannerAdDelegate <NSObject>
@optional
/// 广告加载成功
- (void)lm_bannerAdDidLoad:(LMBannerAd *)bannerAd;
/// 广告加载失败
- (void)lm_bannerAd:(LMBannerAd *)bannerAd didFailWithError:(NSError *)error;
/// 广告即将展示
- (void)lm_bannerAdWillVisible:(LMBannerAd *)bannerAd;
/// 广告被点击
- (void)lm_bannerAdDidClick:(LMBannerAd *)bannerAd;
/// 广告关闭
- (void)lm_bannerAdDidClose:(LMBannerAd *)bannerAd;
@end

/// Banner 横幅广告（门面类）
/// - Note: 内部通过 AdapterManager 选择 Adapter（可能是 Core 或第三方 Adapter）
@interface LMBannerAd : NSObject

/// 代理
@property(nonatomic, weak) id<LMBannerAdDelegate> delegate;

/// 初始化 Banner 广告
/// - Parameter adSlot: 广告位配置，需设置 imgSize（如 CGSizeMake(320, 50)）
- (instancetype)initWithSlot:(LMAdSlot *)adSlot;

/// 加载广告
- (void)loadAd;

/// 关闭广告（从容器视图移除并释放资源，同时触发关闭回调）
/// - Note: 调用此方法会触发 lm_bannerAdDidClose: 回调
- (void)close;

/// 获取广告视图（加载成功后可用）
/// @return Banner 广告视图，如果未加载或加载失败则返回 nil
- (nullable UIView *)bannerView;

/// 广告是否有效（未过期）
/// @return YES 表示广告有效，NO 表示已过期
- (BOOL)isAdValid;

/// 获取广告的 eCPM（每千次展示成本，单位：元）
/// @return eCPM 字符串，格式化为两位小数（如 "1.23"），如果没有 bid 或 price 为 0，返回 "0.00"
- (NSString *)getEcpm;

@end

NS_ASSUME_NONNULL_END
