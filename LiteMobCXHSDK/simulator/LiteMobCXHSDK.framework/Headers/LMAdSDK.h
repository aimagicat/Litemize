//
//  LMAdSDK.h
//  LiteMobCXHSDK
//
//  MVP 版本：提供 SDK 初始化与全局配置能力
//

#import <Foundation/Foundation.h>
#import <LiteMobCXHSDK/LMLogger.h> // 统一导出日志宏，避免各处重复引入

NS_ASSUME_NONNULL_BEGIN
/// 地理位置信息类
@interface LMLocation : NSObject
@property(nonatomic, assign) double latitude; ///< 纬度
@property(nonatomic, assign) double longitude; ///< 经度
@end

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

/// 检查 SDK 是否已经初始化成功
+ (BOOL)isInitialized;

/// 是否开启日志，可选，默认为 NO
+ (void)enableLog:(BOOL)enableLog;

/// 获取日志是否开启（内部方法，供 SDK 内部使用）
+ (BOOL)isLogEnabled;

/// 设置自定义 UserAgent
/// - Parameter ua: 外部传入的 UserAgent，传入后内部不再进行获取 UserAgent 的操作
/// - Note: iOS UserAgent 为系统全局属性，一旦更改 SDK 内部会获取更改后的 UserAgent。
///         为避免此情况，开发者需根据自身情况获取 UserAgent 然后原始 UserAgent 传入 SDK。
///         注意：不要在 ua 后拼接包名等任何信息，不然会影响填充率
+ (void)setCustomUA:(NSString *)ua;

/// 是否允许使用 IDFA，不设置则默认为 YES
/// - Parameter isCanUseIDFA: 设置为 NO 时，IDFA 权限不可用，可通过 setCustomIDFA 传入有效的 IDFA 值
+ (void)canUseIDFA:(BOOL)isCanUseIDFA;

/// 传入 IDFA 值，可选配置，SDK 内部不获取系统的 IDFA 权限
/// - Parameter idfa: 自定义 IDFA 字符串
/// - Note: canUseIDFA = YES 时该设置无效。若您的 app 有自己获取 IDFA 的获取策略，
///         则将 isCanUseIDFA 置为 NO，然后设置该值即可生效
+ (void)setCustomIDFA:(NSString *)idfa;

/// 广告请求中广协 CAIDList
/// - Parameter polluxValues: CAID 数组，示例：[{"version": "20230330", "caid": "75c7bc3754b3019c135b526cb8eb4420"}]
+ (void)setPolluxValues:(NSArray<NSDictionary *> *)polluxValues;

/// 是否允许 SDK 使用地理位置权限，可选
/// - Parameter isCanUseLocation: 设置为 NO 时，SDK 不获取地理位置权限
/// - Note: SDK 不会主动向系统索取地理位置权限，只是当权限可用时获取经纬度
+ (void)canUseLocation:(BOOL)isCanUseLocation;

/// 当 isCanUseLocation = NO 时，可传入地理位置信息，SDK 使用您传入的地理位置信息
/// - Parameter location: 地理位置信息对象
+ (void)setUserLocation:(LMLocation *)location;

/// 是否允许使用 carrier，默认为 NO
/// - Parameter isCanUseCarrier: 设置为 NO 时，SDK 则不获取 carrier，可通过 setCustomCarrier 传入有效的 carrier 值
+ (void)canUseCarrier:(BOOL)isCanUseCarrier;

/// 可通过该方法传入您的 carrier 值
/// - Parameter carrier: carrier 值，请传入 unknown, mobile, telecom, unicom 之中的某个值
/// - Note: unknown: 未知, mobile: 移动, telecom: 电信, unicom: 联通
///         isCanUseCarrier = YES 时该设置无效
+ (void)setCustomCarrier:(NSString *)carrier;

/// 安全执行 selector（内部方法，供宏使用）
/// - Parameters:
///   - selector: 方法选择器
///   - target: 目标对象
///   - firstObject: 第一个参数（可变参数，以 nil 结尾）
+ (void)_performSelector:(SEL)selector onTarget:(id)target withObjects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/// 错误监控通知名（任何广告错误都会发送通知，object 为 NSError）
FOUNDATION_EXPORT NSString *const LMAdSDKErrorDidOccurNotification;

/// 发送错误通知（便捷宏）
/// - Parameter error: 错误对象
/// - Note: 内部会发送 LMAdSDKErrorDidOccurNotification 通知，错误监听器会自动处理日志
#define LMErrorNotify(error)                                                                                                     \
  do {                                                                                                                           \
    if (error) {                                                                                                                 \
      [[NSNotificationCenter defaultCenter] postNotificationName:LMAdSDKErrorDidOccurNotification object:error];                 \
    }                                                                                                                            \
  } while (0)

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
#define LMDelegateCall(delegate, selector, ...)                                                                                  \
  [LMAdSDK _performSelector:(selector) onTarget:(delegate)withObjects:__VA_ARGS__, nil]

/// 定义 weakSelf（用于避免循环引用）
/// - Parameter self: 当前对象（通常传入 self）
/// - Note: 在 block 外使用，定义 __weak typeof(self) weakSelf = self
/// - Example:
///   LMWeakSelf(self);
///   [someBlock:^{
///     LMStrongSelf;
///     // 使用 strongSelf
///   }];
#define LMWeakSelf(self) __weak typeof(self) weakSelf = self

/// 定义 strongSelf 并检查（在 block 内使用）
/// - Note: 在 block 内使用，定义 __strong typeof(weakSelf) strongSelf = weakSelf，并检查是否为 nil
/// - Example:
///   LMWeakSelf(self);
///   [someBlock:^{
///     LMStrongSelf;
///     if (!strongSelf) return;
///     // 使用 strongSelf
///   }];
/// - Note: 如果 weakSelf 为 nil，则直接 return（适用于 void block）
#define LMStrongSelf                                                                                                             \
  __strong typeof(weakSelf) strongSelf = weakSelf;                                                                               \
  if (!strongSelf)                                                                                                               \
  return

/// 定义 strongSelf 并检查（带返回值）
/// - Parameter returnValue: 如果 weakSelf 为 nil 时的返回值
/// - Note: 适用于有返回值的 block
/// - Example:
///   LMWeakSelf(self);
///   [someBlock:^BOOL{
///     LMStrongSelfReturn(NO);
///     // 使用 strongSelf
///     return YES;
///   }];
#define LMStrongSelfReturn(returnValue)                                                                                          \
  __strong typeof(weakSelf) strongSelf = weakSelf;                                                                               \
  if (!strongSelf)                                                                                                               \
  return returnValue

@end

NS_ASSUME_NONNULL_END
