//
//  LMBUMSplashAdapter.h
//  LitemobSDK
//
//  穿山甲（BUM）开屏广告 Adapter
//  用于将 LitemobSDK 的开屏广告接入到穿山甲 SDK 中
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 如果项目中有穿山甲 SDK，取消下面的注释并导入相应的头文件
// #import <BUAdSDK/BUAdSDK.h>
// #import <BUMSplashAd/BUMCustomSplashAdapter.h>

// 前向声明穿山甲 SDK 的协议和类（如果没有导入头文件）
@protocol BUMCustomSplashAdapter;
@protocol BUMCustomSplashAdapterDelegate;
@class BUMMediaBidResult;

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 开屏广告 Adapter
/// 实现 BUMCustomSplashAdapter 协议，将 LitemobSDK 的开屏广告接入穿山甲 SDK
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMBUMSplashAdapter : NSObject<BUMCustomSplashAdapter>

@end

NS_ASSUME_NONNULL_END
