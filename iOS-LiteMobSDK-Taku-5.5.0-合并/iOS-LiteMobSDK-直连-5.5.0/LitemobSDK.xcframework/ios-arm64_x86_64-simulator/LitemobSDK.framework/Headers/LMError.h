//
//  LMError.h
//  LitemobSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const LMAdSDKErrorDidOccurNotification;

FOUNDATION_EXPORT NSErrorDomain const LMAdErrorDomain;

/// 错误上下文信息键
FOUNDATION_EXPORT NSString *const LMErrorFileKey; ///< 错误发生的文件路径
FOUNDATION_EXPORT NSString *const LMErrorFunctionKey; ///< 错误发生的函数名
FOUNDATION_EXPORT NSString *const LMErrorLineKey; ///< 错误发生的行号
FOUNDATION_EXPORT NSString *const LMErrorContextKey; ///< 自定义上下文信息（字典）

/// 错误参数信息键（用于错误构建器）
FOUNDATION_EXPORT NSString *const LMErrorParamNameKey; ///< 参数名称
FOUNDATION_EXPORT NSString *const LMErrorReasonKey; ///< 错误原因
FOUNDATION_EXPORT NSString *const LMErrorTechnicalDetailKey; ///< 技术细节（用于调试）

/// Java枚举错误码（对应EnumAdErrorCode，用于错误上报）
/// 编码规则：5位数字，首位标识错误类型，后四位为序号
/// 1xxxx：通用/系统错误
/// 2xxxx：配置/参数错误
/// 3xxxx：设备/版本/环境错误
/// 4xxxx：请求/解析错误
/// 5xxxx：广告加载/素材错误
/// 6xxxx：渲染/展示错误
/// 7xxxx：验证/权限错误
/// 8xxxx：特殊功能错误
typedef NS_ENUM(NSInteger, LMJavaErrorCode) {
    // ===================== 1xxxx：通用/系统错误 =====================
    LMJavaErrorCodeSuccess = 0, ///< 成功
    LMJavaErrorCodeUnknown = 1, ///< 未知错误
    LMJavaErrorCodeAdNotFilled = 204, ///< 广告未填充
    LMJavaErrorCodeAdNotInitialized = 10001, ///< 广告未初始化或初始化失败
    LMJavaErrorCodeRequestTimeout = 10002, ///< 广告请求超时
    LMJavaErrorCodeConfigFileError = 10003, ///< 配置文件错误
    LMJavaErrorCodeSDKLocationError = 10004, ///< SDK位置错误

    // ===================== 2xxxx：配置/参数错误 =====================
    LMJavaErrorCodeAppIdNotFound = 20001, ///< APPID不存在
    LMJavaErrorCodeAdSlotNotFound = 20002, ///< 广告位不存在
    LMJavaErrorCodeAdSlotMismatch = 20003, ///< 广告位和APPID不匹配
    LMJavaErrorCodeAdTypeMismatch = 20004, ///< 广告类型不匹配
    LMJavaErrorCodePackageNameVerifyFailed = 20005, ///< 包名校验错误
    LMJavaErrorCodeAdTypeOffline = 20006, ///< 该类型广告已下线
    LMJavaErrorCodeAdSlotBlocked = 20007, ///< 广告位被封锁
    LMJavaErrorCodeAppIdBlocked = 20008, ///< 应用被封锁
    LMJavaErrorCodeManifestConfigError = 20009, ///< Manifest配置错误
    LMJavaErrorCodeSplashAdContainerInvisible = 20010, ///< 开屏广告容器不可见
    LMJavaErrorCodeSplashAdContainerHeightError = 20011, ///< 开屏广告容器高度不足
    LMJavaErrorCodeAdInterfaceCallOrderError = 20012, ///< 广告接口调用顺序错误

    // ===================== 3xxxx：设备/版本/环境错误 =====================
    LMJavaErrorCodeDeviceOrVersionNotSupported = 30001, ///< 当前设备或版本不支持
    LMJavaErrorCodeSDKRenderV1Deprecated = 30002, ///< SDK原生自渲染版本废弃
    LMJavaErrorCodeIframeAdForbidden = 30003, ///< 禁止iframe嵌套广告

    // ===================== 4xxxx：请求/解析错误 =====================
    LMJavaErrorCodeCountryFieldParseFailed = 40001, ///< 国家字段解析失败
    LMJavaErrorCodeTimeZoneFieldParseFailed = 40002, ///< 时区字段解析失败
    LMJavaErrorCodeLanguageFieldParseFailed = 40003, ///< 语言字段解析失败
    LMJavaErrorCodeDeviceFieldParseFailed = 40004, ///< 设备字段解析失败
    LMJavaErrorCodeClientIpParseFailed = 40005, ///< 客户端IP解析失败
    LMJavaErrorCodeNetworkFieldParseFailed = 40006, ///< Network字段解析失败
    LMJavaErrorCodeSDKVersionBlank = 40007, ///< SDK版本为空
    LMJavaErrorCodeManufacturerParseFailed = 40008, ///< 设备制造商字段解析失败
    LMJavaErrorCodeCarrierParseFailed = 40009, ///< 运营商信息字段解析失败
    LMJavaErrorCodeConnectTypeParseFailed = 40010, ///< 网络连接类型解析失败
    LMJavaErrorCodeDeviceStartSecParseFailed = 40011, ///< 设备启动时间解析失败
    LMJavaErrorCodeDeviceNameParseFailed = 40012, ///< 设备名称字段解析失败
    LMJavaErrorCodeOrientationParseFailed = 40013, ///< 设备横竖屏字段解析失败
    LMJavaErrorCodeModelParseFailed = 40014, ///< 设备品牌型号字段解析失败
    LMJavaErrorCodeGeoParseFailed = 40015, ///< GEO字段解析失败
    LMJavaErrorCodeSystemUpdateSecParseFailed = 40016, ///< 系统更新时间解析失败
    LMJavaErrorCodeDiskParseFailed = 40017, ///< 硬盘大小字段解析失败
    LMJavaErrorCodeMemoryParseFailed = 40018, ///< 物理内存字段解析失败
    LMJavaErrorCodeScreenSizeParseFailed = 40019, ///< 屏幕宽高字段解析失败
    LMJavaErrorCodeOSVersionParseFailed = 40020, ///< 操作系统版本解析失败
    LMJavaErrorCodeUserAgentParseFailed = 40021, ///< 客户端UserAgent解析失败

    // ===================== 5xxxx：广告加载/素材错误 =====================
    LMJavaErrorCodeVideoDownloadError = 50001, ///< 视频素材下载错误
    LMJavaErrorCodeVideoPlayError = 50002, ///< 视频素材播放错误
    LMJavaErrorCodeImageLoadError = 50003, ///< 图片加载错误
    LMJavaErrorCodeAdDataExpired = 50004, ///< 广告数据过期
    LMJavaErrorCodeDuplicateAdShow = 50005, ///< 同一条广告不允许多次展示
    LMJavaErrorCodeDuplicateAdLoad = 50006, ///< 同一条广告不允许多次加载，需重新拉取广告后再进行加载

    // ===================== 6xxxx：渲染/展示错误 =====================
    LMJavaErrorCodePlatformTemplateRenderFailed = 60001, ///< 平台模板渲染失败
    LMJavaErrorCodeTemplateRewardVideoRenderFailed = 60002, ///< 模板激励视频渲染失败

    // ===================== 7xxxx：验证/权限错误 - 后端的错误sdk不处理 =====================
    LMJavaErrorCodeSHA1Invalid = 70001, ///< SHA1无效
    LMJavaErrorCodeAndroidIdInvalid = 70002, ///< Android ID无效
    LMJavaErrorCodeIDFAInvalid = 70003, ///< IDFA无效
    LMJavaErrorCodeIMEIInvalid = 70004, ///< IMEI无效
    LMJavaErrorCodeOAIDInvalid = 70005, ///< OAID无效

    // ===================== 8xxxx：特殊功能错误（断点续安装） =====================
    LMJavaErrorCodeApkLoadFrequent = 80001, ///< 断点续安装-加载频繁
    LMJavaErrorCodeApkInstallIntervalTooLong = 80002, ///< 断点续安装-调用间隔过长
    LMJavaErrorCodeApkFileNotExist = 80003, ///< 断点续安装-APK文件不存在
    LMJavaErrorCodeNoValidApkFile = 80004, ///< 断点续安装-无有效APK
    LMJavaErrorCodeApkFeatureNotEnabled = 80005, ///< 断点续安装-功能未开启
};

/// SDK 内部错误码定义（LMAdErrorDomain）
///
/// 错误码统一编号规则：
/// ===================== 系统级错误（负数）=====================
/// -1: 未知错误（系统级，无法归类的错误）
///
/// ===================== 基础业务错误（1xxx）=====================
/// 1001: SDK 未初始化或初始化失败
/// 1002: 广告加载超时（业务层面，请求超时）
/// 1003: 无填充（服务器无可用广告）
/// 1004: 展示失败（业务层面，如容器不可见、广告未加载等）
/// 1005: 重复加载（广告已加载，不能重复加载）
/// 1006: 重复展示（广告已展示，不能重复展示）
/// 1007: 请求正在进行中（已有请求在进行，请等待完成或先取消）
///
/// ===================== 参数/配置错误（2xxx）=====================
/// 2001: 参数无效（如 viewController 为空、slotId 为空等）
/// 2002: 无效的URL（URL格式错误或无法解析）
/// 2003: URL构建失败（URL构建过程中出错）
/// 2004: 请求配置错误（请求配置无效或缺失）
/// 2005: 不支持的请求体类型（请求体类型不被支持）
///
/// ===================== 网络相关错误（3xxx）=====================
/// 3001: 网络请求错误（通用，无法具体分类的网络错误）
/// 3002: 网络不可用（设备无网络连接）
/// 3003: 网络超时（请求或响应超时）
/// 3004: 网络异常（DNS解析失败、连接中断等）
/// 3005: 链接建立失败（TCP/SSL连接建立失败）
/// 3006: 链接建立超时（TCP连接或SSL握手超时）
/// 3007: HTTP状态码错误（HTTP响应状态码异常，如4xx、5xx）
///
/// ===================== 资源/素材错误（4xxx）=====================
/// 4001: 资源加载失败（如图片下载失败、视频下载失败等）
/// 4002: 广告已过期（广告数据超过有效期）
///
/// ===================== 渲染/展示错误（5xxx）=====================
/// 5001: 渲染失败（模板渲染广告失败）
///
/// ===================== 解析/数据处理错误（6xxx）=====================
/// 6001: 响应解析错误（JSON解析失败、数据格式错误等）
/// 6002: 数据加密失败（JSON加密或数据处理失败）
/// 6003: 数据格式错误（数据格式不符合预期）
typedef NS_ERROR_ENUM(LMAdErrorDomain, LMAdErrorCode){
    // ===================== 系统级错误（负数）=====================
    LMAdErrorUnknown = -1, ///< 未知错误（系统级，无法归类的错误）

    // ===================== 基础业务错误（1xxx）=====================
    LMAdErrorNotStarted = 1001, ///< SDK 未初始化或初始化失败
    LMAdErrorTimeout = 1002, ///< 广告加载超时（业务层面，请求超时）
    LMAdErrorNoFill = 1003, ///< 无填充（服务器无可用广告）
    LMAdErrorShowFailed = 1004, ///< 展示失败（业务层面，如容器不可见、广告未加载等）
    LMAdErrorDuplicateLoad = 1005, ///< 重复加载（广告已加载，不能重复加载）
    LMAdErrorDuplicateShow = 1006, ///< 重复展示（广告已展示，不能重复展示）
    LMAdErrorRequestInProgress = 1007, ///< 请求正在进行中（已有请求在进行，请等待完成或先取消）
    // ===================== 适配器错误（1xxx）=====================
    LMAdErrorAdapterNotStarted = 1008, ///< 适配器未初始化或初始化失败
    LMAdErrorAdapterInvalidParameter = 1009, ///< 适配器参数无效（如 appId 为空等）

    // ===================== 参数/配置错误（2xxx）=====================
    LMAdErrorInvalidParameter = 2001, ///< 参数无效（如 viewController 为空、slotId 为空等）
    LMAdErrorInvalidURL = 2002, ///< 无效的URL（URL格式错误或无法解析）
    LMAdErrorURLBuildFailed = 2003, ///< URL构建失败（URL构建过程中出错）
    LMAdErrorInvalidConfig = 2004, ///< 请求配置错误（请求配置无效或缺失）
    LMAdErrorUnsupportedBodyType = 2005, ///< 不支持的请求体类型（请求体类型不被支持）

    // ===================== 网络相关错误（3xxx）=====================
    LMAdErrorNetworkError = 3001, ///< 网络请求错误（通用，无法具体分类的网络错误）
    LMAdErrorNetworkUnavailable = 3002, ///< 网络不可用（设备无网络连接）
    LMAdErrorNetworkTimeout = 3003, ///< 网络超时（请求或响应超时）
    LMAdErrorNetworkException = 3004, ///< 网络异常（DNS解析失败、连接中断等）
    LMAdErrorConnectionFailed = 3005, ///< 链接建立失败（TCP/SSL连接建立失败）
    LMAdErrorConnectionTimeout = 3006, ///< 链接建立超时（TCP连接或SSL握手超时）
    LMAdErrorHTTPStatusCode = 3007, ///< HTTP状态码错误（HTTP响应状态码异常，如4xx、5xx）

    // ===================== 资源/素材错误（4xxx）=====================
    LMAdErrorResourceLoadFailed = 4001, ///< 资源加载失败（如图片下载失败、视频下载失败等）
    LMAdErrorAdExpired = 4002, ///< 广告已过期（广告数据超过有效期）

    // ===================== 渲染/展示错误（5xxx）=====================
    LMAdErrorRenderFailed = 5001, ///< 渲染失败（模板渲染广告失败）

    // ===================== 解析/数据处理错误（6xxx）=====================
    LMAdErrorParseError = 6001, ///< 响应解析错误（JSON解析失败、数据格式错误等）
    LMAdErrorEncryptionFailed = 6002, ///< 数据加密失败（JSON加密或数据处理失败）
    LMAdErrorDataFormatError = 6003, ///< 数据格式错误（数据格式不符合预期）
};

/// 错误构建器类（Builder模式，支持链式调用）
/// - Note: 灵活支持多种错误场景，自动生成用户友好的错误消息
/// - Example:
///   // 方式1：直接设置消息（最简单）
///   NSError *error = LMErr.code(LMAdErrorShowFailed).msg(@"广告未加载").err;
///
///   // 方式2：原因+参数
///   NSError *error = LMErr.code(LMAdErrorInvalidParameter).reason(@"不能为空").param(@"viewController").err;
///
///   // 方式3：原因+技术细节
///   NSError *error = LMErr.code(LMAdErrorNetworkException).reason(@"请求失败").tech(@"JSON序列化失败").err;
@interface LMErrorBuilder : NSObject

/// 创建构建器实例（自动捕获文件、函数、行号信息）
+ (instancetype)builder;

/// 设置错误码
- (LMErrorBuilder * (^)(LMAdErrorCode))code;

/// 设置错误消息（最简单方式，直接使用此消息）
- (LMErrorBuilder * (^)(NSString *))msg;

/// 设置错误原因（如"不能为空"、"格式错误"、"请求失败"等）
- (LMErrorBuilder * (^)(NSString *))reason;

/// 设置参数名称（可选，与reason配合使用）
- (LMErrorBuilder * (^)(NSString *))param;

/// 设置技术细节（可选，用于调试，不暴露给调用者）
- (LMErrorBuilder * (^)(NSString *))tech;

/// 设置自定义上下文信息（可选）
- (LMErrorBuilder * (^)(NSDictionary *))ctx;

/// 从网络错误转换（自动映射错误码和消息，添加上下文信息）
/// - Parameter error: 原始网络错误
/// - Returns: 构建器自身，支持链式调用
/// - Note: 如果 error 为 nil 或已经是 SDK 内部错误，则直接使用；否则自动映射网络错误码
- (LMErrorBuilder * (^)(NSError *_Nullable))fromNetworkError;

/// 构建错误对象（链式调用结束）
- (NSError *)err;

// 上下文信息属性（用于自动捕获文件、函数、行号，供 LMErr 宏使用）
@property(nonatomic, assign) const char *file;
@property(nonatomic, assign) const char *function;
@property(nonatomic, assign) int line;

@end

/// 便捷宏：函数式链式调用错误构建器（自动捕获上下文信息）
/// - Note: 自动捕获文件、函数、行号信息，支持链式调用
/// - Example:
///   NSError *error = LMErr.code(LMAdErrorShowFailed).msg(@"广告未加载").err;
///   NSError *error = LMErr.code(LMAdErrorInvalidParameter).reason(@"不能为空").param(@"viewController").err;
///   NSError *error = LMErr.code(LMAdErrorNetworkException).reason(@"请求失败").tech(@"JSON序列化失败").err;
///   NSError *error = LMErr.fromNetworkError(networkError).err; // 从网络错误转换
#define LMErr                                                                                                                    \
    ({                                                                                                                           \
        LMErrorBuilder *_b = [LMErrorBuilder builder];                                                                           \
        _b.file = __FILE__;                                                                                                      \
        _b.function = __FUNCTION__;                                                                                              \
        _b.line = __LINE__;                                                                                                      \
        _b;                                                                                                                      \
    })

NS_ASSUME_NONNULL_END
