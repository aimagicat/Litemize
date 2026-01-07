//
//  LMRewardedVideoAd.h
//  LitemizeSDK
//

#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBaseAd.h>
#import <UIKit/UIKit.h>

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

@property(nonatomic, weak) id<LMRewardedVideoAdDelegate> delegate;

/// 是否由服务器验证奖励发放
@property(nonatomic, assign) BOOL isServerReward;

/// 是否发放奖励
@property(nonatomic, assign) BOOL isSendReward;

/// 初始化方法
/// @param adSlot 广告位配置
/// @return 如果 adSlot 为空或类型不正确，返回 nil
- (instancetype)initWithSlot:(LMAdSlot *)adSlot;
/// 加载广告
- (void)loadAd;
/// 展示广告
- (void)showFromViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
