//
//  LMAdSDKConfigBuilder.h
//  LitemizeSDK
//
//  SDK 配置构建器，支持闭包方式设置各种属性
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// SDK 配置构建器，支持闭包方式设置属性
/// 使用示例：
/// [LMAdSDK config:^(LMAdSDKConfigBuilder *builder) {
///     builder.ua = @"CustomUserAgent";
///     builder.idfa = @"custom-idfa-value";  // 设置用户传入的 IDFA（SDK 内部不再自动获取系统 IDFA）
///     builder.userId = @"userID"; // 用户ID，用于奖励验证等场景
/// }];
@interface LMAdSDKConfigBuilder : NSObject

/// 自定义 UserAgent
@property(nonatomic, copy, nullable) NSString *ua;

/// 自定义 IDFA（用户传入的 IDFA 值）
/// - Note: SDK 内部不再自动获取系统 IDFA，只使用用户通过此属性传入的 IDFA 值
@property(nonatomic, copy, nullable) NSString *idfa;

/// 用户ID
@property(nonatomic, copy, nullable) NSString *userId;

@end

NS_ASSUME_NONNULL_END
