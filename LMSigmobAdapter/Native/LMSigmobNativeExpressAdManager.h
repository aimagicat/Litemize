//
//  LMSigmobNativeExpressAdManager.h
//  LitemobSDK
//
//  Sigmob 模板渲染原生广告管理器
//

#import "LMSigmobAdProtocol.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Sigmob 模板渲染原生广告管理器
/// 负责处理模板渲染原生广告的加载和回调
@interface LMSigmobNativeExpressAdManager : NSObject <LMSigmobAdProtocol>

/// 初始化方法
/// @param bridge ToBid SDK 桥接对象
/// @param adapter 适配器实例
- (instancetype)initWithBridge:(id<AWMCustomAdapterBridge>)bridge adapter:(id<AWMCustomAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
