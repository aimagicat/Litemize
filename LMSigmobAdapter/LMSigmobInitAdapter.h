//
//  LMSigmobInitAdapter.h
//  LitemobSDK
//
//  Sigmob 初始化配置 Adapter
//  用于将 LitemobSDK 接入到 ToBid SDK 中
//

#import <Foundation/Foundation.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 初始化配置 Adapter
/// 实现 AWMCustomConfigAdapter 协议，用于 ToBid SDK 初始化配置
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMSigmobInitAdapter : NSObject<AWMCustomConfigAdapter>

@end

NS_ASSUME_NONNULL_END
