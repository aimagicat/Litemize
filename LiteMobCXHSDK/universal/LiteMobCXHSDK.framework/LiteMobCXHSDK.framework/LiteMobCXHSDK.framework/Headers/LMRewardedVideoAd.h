//
//  LMRewardedVideoAd.h
//  LiteMobCXHSDK
//

#import <UIKit/UIKit.h>
#import <LiteMobCXHSDK/LMAdSlot.h>
#import <LiteMobCXHSDK/LMBaseAd.h>

NS_ASSUME_NONNULL_BEGIN

@class LMRewardedVideoAd;

@protocol LMRewardedVideoAdDelegate <NSObject>
@optional
/// 广告加载成功
- (void)lm_rewardedVideoAdDidLoad:(LMRewardedVideoAd *)rewardedAd;
/// 广告加载失败
- (void)lm_rewardedVideoAd:(LMRewardedVideoAd *)rewardedAd didFailWithError:(NSError *)error;
/// 广告即将展示
- (void)lm_rewardedVideoAdWillVisible:(LMRewardedVideoAd *)rewardedAd;
/// 广告被点击
- (void)lm_rewardedVideoAdDidClick:(LMRewardedVideoAd *)rewardedAd;
/// 广告已关闭
- (void)lm_rewardedVideoAdDidClose:(LMRewardedVideoAd *)rewardedAd;
/// 触发激励（用户完成观看任务）
- (void)lm_rewardedVideoAdDidRewardEffective:(LMRewardedVideoAd *)rewardedAd;
@end

/// MVP 激励视频
@interface LMRewardedVideoAd : LMBaseAd

@property (nonatomic, weak) id<LMRewardedVideoAdDelegate> delegate;

- (instancetype)initWithSlot:(LMAdSlot *)adSlot;
- (void)loadAd;
- (void)showFromViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END


