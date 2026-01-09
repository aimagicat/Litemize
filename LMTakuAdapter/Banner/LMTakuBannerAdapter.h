//
//  LMTakuBannerAdapter.h
//  LitemizeSDK
//
//  Taku/AnyThink Banner 横幅广告 Adapter
//  用于将 LitemizeSDK 的 Banner 广告接入到 Taku SDK 中
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK Banner 横幅广告 Adapter
/// 实现 ATAdAdapter 协议，将 LitemizeSDK 的 Banner 广告接入 Taku SDK
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMTakuBannerAdapter : NSObject

@end

NS_ASSUME_NONNULL_END
