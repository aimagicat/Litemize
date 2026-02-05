//
//  LMSigmobBannerAdapter.h
//  LitemobSDK
//
//  Sigmob Banner 横幅广告 Adapter
//  用于将 LitemobSDK 的 Banner 广告接入到 ToBid SDK 中
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// LiteMobCXH SDK Banner 横幅广告 Adapter
/// 实现 AWMCustomBannerAdapter 协议，将 LitemobSDK 的 Banner 广告接入 ToBid SDK
/// 注意：此类必须被导出，确保运行时可以找到
__attribute__((visibility("default")))
@interface LMSigmobBannerAdapter : NSObject<AWMCustomBannerAdapter>

@end

NS_ASSUME_NONNULL_END
