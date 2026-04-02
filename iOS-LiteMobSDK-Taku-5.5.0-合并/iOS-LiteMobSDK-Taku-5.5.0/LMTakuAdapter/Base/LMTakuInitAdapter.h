//
//  LMTakuInitAdapter.h
//  LitemobSDK
//
//  Taku/AnyThink 初始化适配器
//  负责初始化 AnyThink SDK，并返回其版本号信息
//
//  Created by Neko on 2026/01/28.
//

#import <Foundation/Foundation.h>
#import "LMTakuAdapterCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

/// Taku/AnyThink 初始化适配器
/// 继承 ATBaseInitAdapter，用于初始化 AnyThink SDK
__attribute__((visibility("default")))
@interface LMTakuInitAdapter : ATBaseInitAdapter

@end

NS_ASSUME_NONNULL_END
