//
//  LMBUMNativeAdapter.h
//  LitemobSDK
//
//  穿山甲（BUM）信息流广告 Adapter
//  用于将 LitemobSDK 的信息流广告接入到穿山甲 SDK 中
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LitemobSDK.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 信息流广告 Adapter
/// 实现 BUMCustomNativeAdapter 协议，将 LitemobSDK 的信息流广告接入穿山甲 SDK
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMBUMNativeAdapter : NSObject<BUMCustomNativeAdapter, LMNativeAdDelegate, LMNativeExpressAdDelegate>
@end

NS_ASSUME_NONNULL_END
