//
//  LMLogger.h
//  LitemizeSDK
//
//  统一日志模块，支持级别控制与开关
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 日志级别
typedef NS_ENUM(NSInteger, LMLogLevel) {
    LMLogLevelDebug = 0, ///< 调试信息
    LMLogLevelInfo, ///< 普通信息
    LMLogLevelWarning, ///< 警告
    LMLogLevelError, ///< 错误
};

/// 统一日志模块（单例）
@interface LMLogger : NSObject

/// 是否启用日志（通过 LMAdSDK.enableLog: 设置）
@property(nonatomic, assign, class) BOOL enabled;

/// 最小日志级别（低于此级别的日志不会输出，默认 DEBUG）
@property(nonatomic, assign, class) LMLogLevel minimumLevel;

/// 获取单例
+ (instancetype)sharedLogger;

/// 日志输出（类方法，推荐使用宏）
+ (void)logLevel:(LMLogLevel)level module:(NSString *)module format:(NSString *)format, ... NS_FORMAT_FUNCTION(3, 4);

/// 便捷方法
+ (void)debug:(NSString *)module format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void)info:(NSString *)module format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void)warning:(NSString *)module format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void)error:(NSString *)module format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

@end

/// 便捷宏定义（推荐使用）
#define LMLogDebug(module, fmt, ...) [LMLogger debug:module format:fmt, ##__VA_ARGS__]
#define LMLogInfo(module, fmt, ...) [LMLogger info:module format:fmt, ##__VA_ARGS__]
#define LMLogWarning(module, fmt, ...) [LMLogger warning:module format:fmt, ##__VA_ARGS__]
#define LMLogError(module, fmt, ...) [LMLogger error:module format:fmt, ##__VA_ARGS__]

NS_ASSUME_NONNULL_END
