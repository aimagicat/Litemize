//
//  LMSigmobInitAdapter.m
//  LitemizeSDK
//
//  Sigmob 初始化配置 Adapter 实现
//

#import "LMSigmobInitAdapter.h"
#import "LMSigmobAdapterLog.h"
#import <LitemizeSDK/LitemizeSDK.h>

@interface LMSigmobInitAdapter ()
@property(nonatomic, weak) id<AWMCustomConfigAdapterBridge> bridge;
@end

@implementation LMSigmobInitAdapter

#pragma mark - AWMCustomConfigAdapter Protocol Implementation

- (instancetype)initWithBridge:(id<AWMCustomConfigAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (AWMCustomAdapterVersion *)basedOnCustomAdapterVersion {
    return AWMCustomAdapterVersion1_0;
}

- (NSString *)adapterVersion {
    return @"1.0.0";
}

- (NSString *)networkSdkVersion {
    return [LMAdSDK sdkVersion] ?: @"5.0";
}

- (void)initializeAdapterWithConfiguration:(AWMSdkInitConfig *)initConfig {
    LMSigmobLog(@"Init initializeAdapterWithConfiguration: appID=%@, extra=%@", initConfig.appID, initConfig.extra);

    // 从配置中获取 App ID
    NSString *appId = initConfig.appID ?: @"";
    if (appId.length == 0) {
        // 如果 appID 为空，尝试从 extra 中获取
        if (initConfig.extra && initConfig.extra[@"appId"]) {
            appId = initConfig.extra[@"appId"];
        }
    }

    if (appId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LMSigmobInitAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"App ID 不能为空"}];
        if (self.bridge && [self.bridge respondsToSelector:@selector(initializeAdapterFailed:error:)]) {
            [self.bridge initializeAdapterFailed:self error:error];
        }
        return;
    }

    // 初始化 LitemizeSDK
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
                     LMSigmobLog(@"✅ Init: LitemizeSDK 初始化成功");
                     // 通知初始化成功
                     if (strongSelf.bridge && [strongSelf.bridge respondsToSelector:@selector(initializeAdapterSuccess:)]) {
                         [strongSelf.bridge initializeAdapterSuccess:strongSelf];
                     }
                 } else {
                     LMSigmobLog(@"❌ Init: LitemizeSDK 初始化失败: %@", error.localizedDescription ?: @"unknown");
                     // 通知初始化失败
                     if (strongSelf.bridge && [strongSelf.bridge respondsToSelector:@selector(initializeAdapterFailed:error:)]) {
                         [strongSelf.bridge
                             initializeAdapterFailed:strongSelf
                                               error:error
                                                   ?: [NSError errorWithDomain:@"LMSigmobInitAdapter"
                                                                          code:-1
                                                                      userInfo:@{NSLocalizedDescriptionKey : @"初始化失败"}]];
                     }
                 }
             }];
}

/// 隐私权限更新，用户更新隐私配置时触发，初始化方法调用前一定会触发一次
- (void)didRequestAdPrivacyConfigUpdate:(NSDictionary *)config {
    LMSigmobLog(@"Init didRequestAdPrivacyConfigUpdate: %@", config);
    // 调用三方 adn 隐私设置接口
    // 如果 LitemizeSDK 支持隐私配置，可以在这里设置
    // 例如：处理 IDFA、地理位置等隐私权限配置
}

@end
