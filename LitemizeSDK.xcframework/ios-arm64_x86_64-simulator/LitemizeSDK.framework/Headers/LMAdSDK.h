//
//  LMAdSDK.h
//  LitemizeSDK
//
//  MVP 版本：提供 SDK 初始化与全局配置能力
//

#import <Foundation/Foundation.h>
#import <LitemizeSDK/LMAdSDKConfigBuilder.h>
#import <LitemizeSDK/LMLogger.h>

NS_ASSUME_NONNULL_BEGIN

@class LMAdSlot; // 前向声明
@class LMAdSDKConfigBuilder; // 前向声明

/// 初始化完成回调
typedef void (^LMAdSDKInitCompletion)(BOOL success, NSError *_Nullable error);

/// SDK 全局入口，参考穿山甲 BUAdSDK 风格
@interface LMAdSDK : NSObject

/// 获取单例
+ (instancetype)sharedSDK;

/// 必要：注册 App 与 SDK
/// - Parameters:
///   - appId: 媒体位 AppId（MVP 不校验，仅透传）
///   - completion: 初始化完成回调
- (void)startWithAppId:(NSString *)appId completion:(LMAdSDKInitCompletion _Nullable)completion;

/// 可选：全局超时（秒），默认 3 秒（MVP 用于模拟加载时长）
@property(nonatomic, assign) NSTimeInterval globalTimeout;

/// 只读：当前 AppId（初始化后可用）
@property(nonatomic, readonly, copy, nullable) NSString *appId;

/// 获取 SDK 版本号
+ (NSString *)sdkVersion;

/// 获取 SDK 版本号前两位（主版本号.次版本号），如 "5.0.1" -> "5.0"
+ (NSString *)sdkVersionMajorMinor;

/// 检查 SDK 是否已经初始化成功
+ (BOOL)isInitialized;

/// 是否开启日志，可选，默认为 NO
+ (void)enableLog:(BOOL)enableLog;

/// 获取日志是否开启（内部方法，供 SDK 内部使用）
+ (BOOL)isLogEnabled;

/// 获取当前用户ID（只读）由开发者设置
/// - Returns: 用户ID字符串，如果未设置则返回 nil
+ (nullable NSString *)userId;

/// 使用闭包方式配置 SDK 属性
/// - Parameter block: 配置闭包，在闭包中设置 builder 的属性
/// - Note: 使用示例：
///   [LMAdSDK config:^(LMAdSDKConfigBuilder *builder) {
///       builder.ua = @"CustomUserAgent";
///       builder.idfa = @"custom-idfa-value";
///       builder.userId = @"userID";// 用户ID，用于奖励验证等场景
///   }];
+ (void)config:(void (^)(LMAdSDKConfigBuilder *builder))block;

/// 清除指定广告位类型的广告池和预加载缓存
/// - Parameter slot: 广告位配置（使用 slotType 确定池）
/// - Note: 会清除缓存的广告、取消正在进行的请求（包括预加载请求）、清除预加载失败记录
///         用于清理缓存的广告和正在准备缓存的广告
+ (void)clearPoolForSlot:(LMAdSlot *)slot;

/// 清除所有广告位类型的广告池和预加载缓存
/// - Note: 会清除所有缓存的广告、取消所有正在进行的请求（包括预加载请求）、清除所有预加载失败记录
///         用于清理所有缓存的广告和正在准备缓存的广告
+ (void)clearAllPool;

/// 启用Debug日志面板（可选配置，类似摇一摇功能）
/// - Parameter enable: 是否启用debug面板
/// - Note: 启用后可以通过摇一摇设备或调用 showDebugPanel/hideDebugPanel 来显示/隐藏面板
///         面板会实时显示SDK的日志信息，方便调试
+ (void)enableDebugPanel:(BOOL)enable;

/// 显示Debug日志面板
+ (void)showDebugPanel;

/// 隐藏Debug日志面板
+ (void)hideDebugPanel;

/// 切换Debug日志面板显示/隐藏状态
+ (void)toggleDebugPanel;

/// 安全执行 selector（内部方法，供宏使用）
/// - Parameters:
///   - selector: 方法选择器
///   - target: 目标对象
///   - firstObject: 第一个参数（可变参数，以 nil 结尾）
+ (void)_performSelector:(SEL)selector onTarget:(id)target withObjects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/// 安全调用 delegate 方法（统一便捷宏）
/// - Parameters:
///   - delegate: delegate 对象
///   - selector: 方法选择器（使用 @selector(...) 格式）
///   - ...: 方法参数（0-3 个参数，自动识别）
/// - Examples:
///   - LMDelegateCall(self.delegate, @selector(lm_bannerAdDidClick:), self)
///   - LMDelegateCall(self.delegate, @selector(lm_bannerAd:didFailWithError:), self, error)
///   - LMDelegateCall(self.delegate, @selector(lm_nativeAd:didFailWithError:description:), self, error, description)
/// - Note: 自动检查 delegate 是否存在且响应方法，避免崩溃
/// - Note: 所有 delegate 回调都会在主线程执行，使用方无需手动切换线程
#define LMDelegateCall(delegate, selector, ...)                                                                                  \
    [LMAdSDK _performSelector:(selector) onTarget:(delegate)withObjects:__VA_ARGS__, nil]

@end

NS_ASSUME_NONNULL_END
