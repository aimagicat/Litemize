//
//  LMInterstitialAd.h
//  LitemizeSDK
//

#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBaseAd.h>
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
@interface LMInterstitialAd : LMBaseAd

@property(nonatomic, weak) id<LMInterstitialAdDelegate> delegate;

- (instancetype)initWithSlot:(LMAdSlot *)adSlot;
- (void)loadAd;
- (void)showFromViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
