//
//  LMTakuBannerCustomEvent.h
//  LitemizeSDK
//
//  Taku/AnyThink Banner 横幅广告 CustomEvent
//  用于处理 LitemizeSDK Banner 广告的回调，并转换为 Taku SDK 的回调
//

#import <AnyThinkBanner/ATBannerCustomEvent.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <LitemizeSDK/LMBannerAd.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK Banner 横幅广告 CustomEvent
/// 继承 ATBannerCustomEvent，处理广告回调并转换为 Taku SDK 的回调
@interface LMTakuBannerCustomEvent : ATBannerCustomEvent <LMBannerAdDelegate>

/// 容器视图（用于展示 Banner 广告）
@property(nonatomic, weak, nullable) UIView *containerView;

/// 当前的 Banner 广告实例（用于保持引用，防止被释放）
@property(nonatomic, strong, nullable) LMBannerAd *bannerAd;

@end

NS_ASSUME_NONNULL_END
