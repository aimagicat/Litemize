//
//  LMBUMBannerAdapter.h
//  LitemobSDK
//
//  穿山甲（BUM）Banner 横幅广告 Adapter
//  用于将 LitemobSDK 的 Banner 广告接入到穿山甲 SDK 中
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK Banner 横幅广告 Adapter
/// 实现 BUMCustomBannerAdapter 协议，将 LitemobSDK 的 Banner 广告接入穿山甲 SDK
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMBUMBannerAdapter : NSObject<BUMCustomBannerAdapter>

/// 释放 Banner 广告资源（当广告视图被移除时调用）
- (void)releaseBannerAd;
@end

NS_ASSUME_NONNULL_END
