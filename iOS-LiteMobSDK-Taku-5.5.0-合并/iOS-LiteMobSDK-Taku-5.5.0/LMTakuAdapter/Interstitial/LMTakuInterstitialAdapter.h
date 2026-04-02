//
//  LMTakuInterstitialAdapter.h
//  LitemobSDK
//
//  Taku/AnyThink 插屏广告适配器
//  继承 LMTakuBaseAdapter，实现插屏广告的加载和展示
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import "../Base/LMTakuBaseAdapter.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Taku/AnyThink 插屏广告适配器
/// 继承 LMTakuBaseAdapter，遵循 ATBaseInterstitialAdapterProtocol 协议，实现插屏广告的加载和展示逻辑
__attribute__((visibility("default")))
@interface LMTakuInterstitialAdapter : LMTakuBaseAdapter<ATBaseInterstitialAdapterProtocol>

@end

NS_ASSUME_NONNULL_END
