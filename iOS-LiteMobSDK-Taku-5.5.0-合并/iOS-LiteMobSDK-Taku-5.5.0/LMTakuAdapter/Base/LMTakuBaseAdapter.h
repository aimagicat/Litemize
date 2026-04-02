//
//  LMTakuBaseAdapter.h
//  LitemobSDK
//
//  Taku/AnyThink 基础适配器
//  用于指定初始化适配器类名
//
//  Created by Neko on 2026/01/28.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Taku/AnyThink 基础适配器
/// 继承 ATBaseMediationAdapter，用于指定初始化适配器
__attribute__((visibility("default")))
@interface LMTakuBaseAdapter : ATBaseMediationAdapter

/// 获取 C2S 竞价扩展信息
/// @param ecpmString LitemobSDK 返回的 ECPM 字符串（单位：分）
/// @discussion 返回的字典会包含 AnyThink 所需的价格与币种信息
+ (NSDictionary<NSString *, id> *)getC2SInfo:(NSString *)ecpmString;

@end

NS_ASSUME_NONNULL_END
