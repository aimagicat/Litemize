//
//  LMBUMInitAdapter.m
//  LitemobSDK
//
//  穿山甲（BUM）初始化配置 Adapter 实现
//

#import "LMBUMInitAdapter.h"
#import <LitemobSDK/LMAdSDK.h>

@implementation LMBUMInitAdapter

#pragma mark - BUMCustomConfigAdapter Protocol Implementation

/// 用于校验Adapter使用协议版本
/// 该自定义adapter是基于哪个版本实现的，填写编写时的最新值即可，融合SDK会根据该值进行兼容处理
/// @return 协议版本对象
- (BUMCustomAdapterVersion *)basedOnCustomAdapterVersion {
    return BUMCustomAdapterVersion1_0;
}

/// adn初始化方法
/// 开发者需在该方法中完成Adapter的初始化及对应network的初始化
/// @param initConfig 初始化配置，包括appid、appkey基本信息和部分用户传递配置
- (void)initializeAdapterWithConfiguration:(BUMSdkInitConfig *_Nullable)initConfig {
    NSLog(@"LMBUMInitAdapter initializeAdapterWithConfiguration: %@", initConfig.userConfig.extraDeviceMap);
    // 初始化 LitemobSDK
    NSString *appId = initConfig.appID ?: @"";

    LMAdSDK *sdk = [LMAdSDK sharedSDK];
    [LMAdSDK enableLog:YES];

    [sdk startWithAppId:appId
             completion:^(BOOL success, NSError *_Nullable error) {
                 if (success) {
                     NSLog(@"✅ LMBUMInitAdapter: LitemobSDK 初始化成功");
                 } else {
                     NSLog(@"❌ LMBUMInitAdapter: LitemobSDK 初始化失败: %@", error.localizedDescription ?: @"unknown");
                 }
             }];

    // 其他配置
    // 如果 initConfig 中有主题状态配置，可以在这里处理
    // 例如：处理 initConfig.themeStatus（如果 LitemobSDK 支持主题配置）
}

/// adapter的版本号
/// 用于融合SDK获取Adaptre的版本号
/// @return Adapter 版本号
- (NSString *_Nonnull)adapterVersion {
    return @"1.0.0";
}

/// adn的版本号
/// 用于融合SDK获取network的版本号
/// @return network SDK 版本号
- (NSString *_Nonnull)networkSdkVersion {
    return [LMAdSDK sdkVersion] ?: @"5.0";
}

/// 隐私权限更新，用户更新隐私配置时触发，初始化方法调用前一定会触发一次
/// @param config 隐私合规配置，字段详见ABUPrivacyConfig.h文件
- (void)didRequestAdPrivacyConfigUpdate:(NSDictionary *)config {
    // 处理隐私配置更新
    // 根据穿山甲 SDK 的隐私配置要求，更新 LitemobSDK 的隐私配置
    // 如果 LitemobSDK 支持隐私配置，可以在这里设置
    // 例如：处理 IDFA、地理位置等隐私权限配置
}

@end
