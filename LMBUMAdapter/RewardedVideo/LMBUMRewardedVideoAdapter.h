//
//  LMBUMRewardedVideoAdapter.h
//  LitemobSDK
//
//  穿山甲（BUM）激励视频广告 Adapter
//  用于将 LitemobSDK 的激励视频广告接入到穿山甲 SDK 中
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 激励视频广告 Adapter
/// 实现 BUMCustomRewardedVideoAdapter 协议，将 LitemobSDK 的激励视频广告接入穿山甲 SDK
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMBUMRewardedVideoAdapter : NSObject<BUMCustomRewardedVideoAdapter>

@end

NS_ASSUME_NONNULL_END
