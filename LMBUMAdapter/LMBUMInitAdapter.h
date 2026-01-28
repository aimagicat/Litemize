//
//  LMBUMInitAdapter.h
//  LitemobSDK
//
//  穿山甲（BUM）初始化配置 Adapter
//  用于将 LitemobSDK 接入到穿山甲 SDK 中
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
// 如果项目中有穿山甲 SDK，取消下面的注释并导入相应的头文件

// 前向声明穿山甲 SDK 的协议和类（如果没有导入头文件）

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK 初始化配置 Adapter
/// 实现 ABUCustomConfigAdapter 协议，用于穿山甲 SDK 初始化配置
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMBUMInitAdapter : NSObject<BUMCustomConfigAdapter>

@end

NS_ASSUME_NONNULL_END
