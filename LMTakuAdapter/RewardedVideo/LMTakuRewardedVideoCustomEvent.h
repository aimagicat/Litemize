//
//  LMTakuRewardedVideoCustomEvent.h
//  LitemizeSDK
//
//  Taku/AnyThink 激励视频广告 CustomEvent
//  用于处理 LitemizeSDK 激励视频广告的回调，并转换为 Taku SDK 的回调
//

#import <AnyThinkRewardedVideo/ATRewardedVideoCustomEvent.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <LitemizeSDK/LMRewardedVideoAd.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 激励视频广告 CustomEvent
/// 继承 ATRewardedVideoCustomEvent，处理广告回调并转换为 Taku SDK 的回调
@interface LMTakuRewardedVideoCustomEvent : ATRewardedVideoCustomEvent <LMRewardedVideoAdDelegate>

@end

NS_ASSUME_NONNULL_END
