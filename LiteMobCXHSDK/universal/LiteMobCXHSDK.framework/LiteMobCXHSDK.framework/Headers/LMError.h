//
//  LMError.h
//  LiteMobCXHSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const LMAdErrorDomain;

/// 错误上下文信息键
FOUNDATION_EXPORT NSString *const LMErrorFileKey; ///< 错误发生的文件路径
FOUNDATION_EXPORT NSString *const LMErrorFunctionKey; ///< 错误发生的函数名
FOUNDATION_EXPORT NSString *const LMErrorLineKey; ///< 错误发生的行号
FOUNDATION_EXPORT NSString *const LMErrorContextKey; ///< 自定义上下文信息（字典）

typedef NS_ERROR_ENUM(LMAdErrorDomain, LMAdErrorCode){
  LMAdErrorUnknown = -1,
  LMAdErrorNotStarted = 1001, ///< SDK 未初始化
  LMAdErrorTimeout = 1002, ///< 加载超时
  LMAdErrorNoFill = 1003, ///< 无填充（MVP 随机模拟）
  LMAdErrorShowFailed = 1004, ///< 展示失败
  LMAdErrorNetworkError = 1005, ///< 网络请求错误（通用）
  LMAdErrorParseError = 1006, ///< 响应解析错误
  LMAdErrorInvalidParameter = 1007, ///< 参数无效（如 viewController 为空、slotId 为空等）
  LMAdErrorResourceLoadFailed = 1008, ///< 资源加载失败（如图片下载失败）
  LMAdErrorAdExpired = 1009, ///< 广告已过期
  LMAdErrorRenderFailed = 1010, ///< 渲染失败（模板渲染广告）

  // 网络环境错误码（SDK 内部定义）
  LMAdErrorNetworkUnavailable = 9999, ///< 网络不可用
  LMAdErrorNetworkTimeout1 = 3001, ///< 网络超时（类型1）
  LMAdErrorNetworkTimeout2 = 3002, ///< 网络超时（类型2）
  LMAdErrorNetworkException = 3003, ///< 网络异常
  LMAdErrorConnectionFailed = -2, ///< 链接建立失败
  LMAdErrorConnectionTimeout1 = 601, ///< 链接建立超时（类型1）
  LMAdErrorConnectionTimeout2 = 602, ///< 链接建立超时（类型2）
};

/// 创建错误对象（带上下文信息）
/// - Parameters:
///   - code: 错误码
///   - message: 错误描述信息
///   - file: 文件路径（通常使用 __FILE__）
///   - function: 函数名（通常使用 __FUNCTION__）
///   - line: 行号（通常使用 __LINE__）
///   - context: 自定义上下文信息（可选，字典格式）
/// - Returns: NSError 对象
static inline NSError *_LMErrorMakeWithContext(LMAdErrorCode code, NSString *_Nullable message, const char *_Nullable file,
                                               const char *_Nullable function, int line, NSDictionary *_Nullable context) {
  NSMutableDictionary *info = [NSMutableDictionary dictionary];

  // 基础错误描述
  if (message.length) {
    info[NSLocalizedDescriptionKey] = message;
  }

  // 添加上下文信息
  if (file) {
    NSString *filePath = [NSString stringWithUTF8String:file];
    // 只保留文件名，去掉完整路径（保护隐私）
    NSString *fileName = [filePath lastPathComponent];
    if (fileName.length) {
      info[LMErrorFileKey] = fileName;
    }
  }

  if (function) {
    NSString *functionName = [NSString stringWithUTF8String:function];
    if (functionName.length) {
      info[LMErrorFunctionKey] = functionName;
    }
  }

  if (line > 0) {
    info[LMErrorLineKey] = @(line);
  }

  // 添加自定义上下文
  if (context && context.count > 0) {
    info[LMErrorContextKey] = context;
  }

  return [NSError errorWithDomain:LMAdErrorDomain code:code userInfo:info];
}

/// 创建错误对象（便捷宏，自动捕获上下文，不带自定义上下文）
#define LMErrorMake(code, message) _LMErrorMakeWithContext(code, message, __FILE__, __FUNCTION__, __LINE__, nil)

/// 创建错误对象（便捷宏，自动捕获上下文，带自定义上下文）
/// - Parameters:
///   - code: 错误码
///   - message: 错误描述信息
///   - context: 自定义上下文信息（字典格式）
/// - Note: 自动捕获文件、函数、行号信息，便于错误排查
/// - Example:
///   - LMErrorMake(LMAdErrorNetworkError, @"网络请求失败")
///   - LMErrorMakeWithContext(LMAdErrorInvalidParameter, @"参数无效", @{@"slotId": slotId, @"reason": @"为空"})
#define LMErrorMakeWithContext(code, message, context)                                                                           \
  _LMErrorMakeWithContext(code, message, __FILE__, __FUNCTION__, __LINE__, context)

/// 判断是否为网络环境错误码（SDK 内部定义）
/// - Parameter errorCode: 错误码
/// - Returns: YES 表示是网络环境错误码
/// - Note: SDK 内部定义的网络环境错误码：9999、3001、3002、3003、-2、601、602
static inline BOOL LMIsNetworkEnvironmentErrorCode(NSInteger errorCode) {
  // SDK 内部定义的网络环境错误码：网络不可用/超时/异常、链接建立失败/超时
  NSArray<NSNumber *> *networkErrorCodes = @[
    @(LMAdErrorNetworkUnavailable), // 9999
    @(LMAdErrorNetworkTimeout1), // 3001
    @(LMAdErrorNetworkTimeout2), // 3002
    @(LMAdErrorNetworkException), // 3003
    @(LMAdErrorConnectionFailed), // -2
    @(LMAdErrorConnectionTimeout1), // 601
    @(LMAdErrorConnectionTimeout2) // 602
  ];
  return [networkErrorCodes containsObject:@(errorCode)];
}

/// 将实际网络错误映射为 SDK 内部网络环境错误码
/// - Parameter error: 原始网络错误
/// - Returns: SDK 内部错误码，如果无法识别则返回 LMAdErrorNetworkError
/// - Note: 根据实际的网络错误类型映射到 SDK 内部定义的网络环境错误码
static inline LMAdErrorCode LMMapNetworkErrorToSDKCode(NSError *error) {
  if (!error) {
    return LMAdErrorNetworkError;
  }

  // 如果已经是 SDK 内部错误，直接返回其错误码
  if ([error.domain isEqualToString:LMAdErrorDomain]) {
    return (LMAdErrorCode)error.code;
  }

  NSInteger errorCode = error.code;

  // 映射 NSURLErrorDomain 错误到 SDK 内部错误码
  if ([error.domain isEqualToString:NSURLErrorDomain]) {
    switch (errorCode) {
    case NSURLErrorNotConnectedToInternet:
      // 网络不可用 -> 9999
      return LMAdErrorNetworkUnavailable;

    case NSURLErrorTimedOut:
      // 网络超时 -> 3001
      return LMAdErrorNetworkTimeout1;

    case NSURLErrorCannotConnectToHost:
    case NSURLErrorCannotFindHost:
      // 链接建立失败 -> -2
      return LMAdErrorConnectionFailed;

    case NSURLErrorNetworkConnectionLost:
      // 网络连接中断 -> 3003
      return LMAdErrorNetworkException;

    case NSURLErrorDNSLookupFailed:
      // DNS 解析失败 -> 3003
      return LMAdErrorNetworkException;

    default:
      // 其他网络错误 -> 3003
      return LMAdErrorNetworkException;
    }
  }

  // 其他错误域，根据错误码判断
  // 如果是已知的网络环境错误码，直接使用
  if (LMIsNetworkEnvironmentErrorCode(errorCode)) {
    return (LMAdErrorCode)errorCode;
  }

  // 默认返回通用网络错误
  return LMAdErrorNetworkError;
}

/// 获取网络环境错误码对应的错误描述
/// - Parameter errorCode: SDK 内部网络环境错误码
/// - Returns: 错误描述信息
static inline NSString *_Nonnull LMNetworkErrorDescription(LMAdErrorCode errorCode) {
  switch (errorCode) {
  case LMAdErrorNetworkUnavailable: return @"网络不可用，请检查设备网络连通性";
  case LMAdErrorNetworkTimeout1:
  case LMAdErrorNetworkTimeout2: return @"网络超时，请检查网络连接或重试请求";
  case LMAdErrorNetworkException: return @"网络异常，请检查网络连接";
  case LMAdErrorConnectionFailed: return @"链接建立失败，请检查网络连接";
  case LMAdErrorConnectionTimeout1:
  case LMAdErrorConnectionTimeout2: return @"链接建立超时，请检查网络连接或避免网络代理";
  default: return @"网络环境异常，请检查设备网络连通性";
  }
}

/// 将网络错误转换为 SDK 内部错误（带详细描述）
/// - Parameter error: 原始网络错误
/// - Returns: SDK 内部错误对象，如果无法识别则返回通用网络错误
/// - Note: 将实际的网络错误映射为 SDK 内部定义的网络环境错误码
static inline NSError *_Nonnull LMConvertNetworkError(NSError *error) {
  if (!error) {
    return LMErrorMake(LMAdErrorNetworkError, @"网络请求失败");
  }

  // 如果是 SDK 内部错误，直接返回
  if ([error.domain isEqualToString:LMAdErrorDomain]) {
    return error;
  }

  NSInteger originalErrorCode = error.code;
  NSString *originalErrorMessage = error.localizedDescription ?: @"网络请求失败";
  NSString *originalDomain = error.domain ?: @"";

  // 映射到 SDK 内部错误码
  LMAdErrorCode sdkErrorCode = LMMapNetworkErrorToSDKCode(error);
  NSString *sdkErrorMessage = LMNetworkErrorDescription(sdkErrorCode);

  // 添加上下文信息：原始错误码和错误域
  NSDictionary *context = @{
    @"originalCode" : @(originalErrorCode),
    @"originalDomain" : originalDomain,
    @"originalMessage" : originalErrorMessage,
    @"suggestion" : @"检查设备网络连通性，重试请求；避免网络代理或弱网环境"
  };

  return LMErrorMakeWithContext(sdkErrorCode, sdkErrorMessage, context);
}

NS_ASSUME_NONNULL_END
