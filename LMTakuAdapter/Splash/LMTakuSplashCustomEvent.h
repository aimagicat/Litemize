//
//  LMTakuSplashCustomEvent.h
//  LitemizeSDK
//
//  Taku/AnyThink 开屏广告 CustomEvent
//  用于处理 LitemizeSDK 开屏广告的回调，并转换为 Taku SDK 的回调
//

#import <AnyThinkSplash/ATSplashCustomEvent.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <LitemizeSDK/LMSplashAd.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 开屏广告 CustomEvent
/// 继承 ATSplashCustomEvent，处理广告回调并转换为 Taku SDK 的回调
@interface LMTakuSplashCustomEvent : ATSplashCustomEvent <LMSplashAdDelegate>

/// Container 视图（可选）
@property(nonatomic, strong, nullable) UIView *containerView;

@end

NS_ASSUME_NONNULL_END
