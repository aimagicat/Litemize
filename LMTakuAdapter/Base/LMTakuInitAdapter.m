//
//  LMTakuInitAdapter.m
//  LitemobSDK
//
//  Taku/AnyThink 初始化适配器实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuInitAdapter.h"
#import <LitemobSDK/LMAdSDK.h>

@implementation LMTakuInitAdapter

#pragma mark - ATBaseInitAdapter Implementation

/// 初始化 LitemobSDK
/// @param adInitArgument 包含服务器下发的初始化参数
- (void)initWithInitArgument:(ATAdInitArgument *)adInitArgument {
    // 从 adInitArgument 对象中获取后台配置的信息
    // 例如：appId 等参数
    NSDictionary *serverContentDic = adInitArgument.serverContentDic ?: @{};
    
    // 尝试多种可能的字段名获取 appId
    NSString *appId = serverContentDic[@"appId"];
    
    // 参数校验：appId 是必需的
    if (!appId || appId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LMTakuInitAdapter"
                                              code:-1
                                          userInfo:@{NSLocalizedDescriptionKey: @"App ID 不能为空，请在后台配置 appId 参数"}];
        [self notificationNetworkInitFail:error];
        return;
    }
    
    // 初始化 LitemobSDK
    LMAdSDK *sdk = [LMAdSDK sharedSDK];
    [LMAdSDK enableLog:YES];
    
    __weak typeof(self) weakSelf = self;
    [sdk startWithAppId:appId
             completion:^(BOOL success, NSError *_Nullable error) {
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                 if (!strongSelf) {
                     return;
                 }
                 
                 if (success) {
                     // 初始化成功，通知 AnyThink SDK
                     [strongSelf notificationNetworkInitSuccess];
                 } else {
                     // 初始化失败，通知 AnyThink SDK
                     NSError *initError = error ?: [NSError errorWithDomain:@"LMTakuInitAdapter"
                                                                        code:-1
                                                                    userInfo:@{NSLocalizedDescriptionKey: @"LitemobSDK 初始化失败"}];
                     [strongSelf notificationNetworkInitFail:initError];
                 }
             }];
}

/// 返回 LitemobSDK 的版本号
/// @return SDK 版本号
- (nullable NSString *)sdkVersion {
    return [LMAdSDK sdkVersion] ?: @"5.0";
}

/// 返回适配器版本号
/// @return 适配器版本号
- (nullable NSString *)adapterVersion {
    return LMTakuAdapterVersion;
}

@end
