//
//  LMInterstitialAd.h
//  LitemobSDK
//

#import <LitemobSDK/LMAdSlot.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMInterstitialAd;

@protocol LMInterstitialAdDelegate <NSObject>
@optional
/// 广告加载成功
- (void)lm_interstitialAdDidLoad:(LMInterstitialAd *)ad;
/// 广告加载失败
- (void)lm_interstitialAd:(LMInterstitialAd *)ad didFailWithError:(NSError *)error;
/// 广告即将展示
- (void)lm_interstitialAdWillVisible:(LMInterstitialAd *)ad;
/// 广告被点击
- (void)lm_interstitialAdDidClick:(LMInterstitialAd *)ad;
/// 广告已关闭
- (void)lm_interstitialAdDidClose:(LMInterstitialAd *)ad;
@end

/// MVP 插屏广告
@interface LMInterstitialAd : NSObject

@property(nonatomic, weak) id<LMInterstitialAdDelegate> delegate;

/// 初始化方法
/// @param adSlot 广告位配置
/// @return 如果 adSlot 为空或类型不正确，返回 nil
- (instancetype)initWithSlot:(LMAdSlot *)adSlot;
/// 加载广告
- (void)loadAd;

/// 展示广告
- (void)showFromViewController:(UIViewController *)rootViewController;

/// 广告是否有效（未过期）
/// @return YES 表示广告有效，NO 表示已过期
- (BOOL)isAdValid;

/// 获取广告的 eCPM（每千次展示成本，单位：分）
/// @return eCPM 字符串，格式化为两位小数（如 "1.23"），如果没有 bid 或 price 为 0，返回 "0.00"
- (NSString *)getEcpm;

/// 广告是否已加载
/// @return YES 表示广告已加载，NO 表示未加载
- (BOOL)isLoaded;

@end

NS_ASSUME_NONNULL_END
