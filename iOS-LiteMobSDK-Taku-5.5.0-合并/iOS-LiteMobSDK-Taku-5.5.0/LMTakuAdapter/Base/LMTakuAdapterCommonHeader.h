//
//  LMTakuAdapterCommonHeader.h
//  LitemobSDK
//
//  Taku/AnyThink 适配器公共头文件
//  用于声明一些公共的头文件和宏定义
//
//  Created by Neko on 2026/01/28.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Taku/AnyThink 适配器版本号
FOUNDATION_EXPORT NSString *const LMTakuAdapterVersion;

/// Taku/AnyThink SDK 版本号（动态获取）
FOUNDATION_EXPORT NSString *_Nonnull LMTakuSDKVersion(void);

#pragma mark - 日志宏定义

/// LMTakuAdapter 日志开关（默认在 DEBUG 模式下开启，RELEASE 模式下关闭）
#ifdef DEBUG
#define LMTakuAdapter_LOG_ENABLED 1
#else
#define LMTakuAdapter_LOG_ENABLED 0
#endif

/// 统一日志宏（仅在 DEBUG 模式下输出）
/// @param module 模块名称（如 @"Interstitial"、@"Banner" 等）
/// @param format 格式化字符串
/// @param ... 可变参数
#if LMTakuAdapter_LOG_ENABLED
#define LMTakuLog(module, format, ...) NSLog(@"[LMTakuAdapter][%@] %@", module, [NSString stringWithFormat:format, ##__VA_ARGS__])
#else
#define LMTakuLog(module, format, ...) ((void)0)
#endif

NS_ASSUME_NONNULL_END
