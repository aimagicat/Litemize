//
//  LMTakuBannerAdapter.h
//  LitemobSDK
//
//  Taku/AnyThink 横幅广告适配器
//  继承 LMTakuBaseAdapter，实现横幅广告的加载和展示
//
//  Created by Neko on 2026/01/28.
//

#import "../Base/LMTakuAdapterCommonHeader.h"
#import "../Base/LMTakuBaseAdapter.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Taku/AnyThink 横幅广告适配器
/// 继承 LMTakuBaseAdapter，遵循 ATBaseBannerAdapterProtocol 协议，实现横幅广告的加载和展示逻辑
__attribute__((visibility("default")))
@interface LMTakuBannerAdapter : LMTakuBaseAdapter<ATBaseBannerAdapterProtocol>

@end

NS_ASSUME_NONNULL_END
