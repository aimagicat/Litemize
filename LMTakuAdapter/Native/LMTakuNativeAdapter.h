//
//  LMTakuNativeAdapter.h
//  LitemobSDK
//
//  Taku/AnyThink 原生（信息流）广告适配器
//  继承 LMTakuBaseAdapter，实现 ATBaseNativeAdapterProtocol 协议
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import "../Base/LMTakuBaseAdapter.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Taku/AnyThink 原生（信息流）广告适配器
/// 继承 LMTakuBaseAdapter，遵循 ATBaseNativeAdapterProtocol 协议，实现原生广告的加载逻辑
__attribute__((visibility("default")))
@interface LMTakuNativeAdapter : LMTakuBaseAdapter<ATBaseNativeAdapterProtocol>

@end

NS_ASSUME_NONNULL_END
