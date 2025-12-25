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
///     builder.idfa = @"custom-idfa-value";  // 设置 idfa 后会自动禁用系统 IDFA
///     builder.userId = @"userID"; // 用户ID，用于奖励验证等场景
/// }];
@interface LMAdSDKConfigBuilder : NSObject

/// 自定义 UserAgent
@property(nonatomic, copy, nullable) NSString *ua;

/// 自定义 IDFA
/// - Note: 如果设置了此属性，将自动禁用系统 IDFA（idfaEnabled 自动设为 NO）
@property(nonatomic, copy, nullable) NSString *idfa;

/// 是否允许使用系统 IDFA（默认 YES）
/// - Note: 如果设置了 idfa 属性，此值会被自动设为 NO，无需手动设置
@property(nonatomic, assign) BOOL idfaEnabled;

/// 用户ID
@property(nonatomic, copy, nullable) NSString *userId;

@end

NS_ASSUME_NONNULL_END
