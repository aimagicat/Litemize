//
//  LMBUMInterstitialAdapter.h
//  LitemobSDK
//
//  穿山甲（BUM）插屏广告 Adapter
//  用于将 LitemobSDK 的插屏广告接入到穿山甲 SDK 中
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 插屏广告 Adapter
/// 实现 BUMCustomInterstitialAdapter 协议，将 LitemobSDK 的插屏广告接入穿山甲 SDK
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMBUMInterstitialAdapter : NSObject<BUMCustomInterstitialAdapter>

@end

NS_ASSUME_NONNULL_END
