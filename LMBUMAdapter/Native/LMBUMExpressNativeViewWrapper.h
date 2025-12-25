//
//  LMBUMExpressNativeViewWrapper.h
//  LitemizeSDK
//
//  穿山甲（BUM）信息流模板广告视图包装器
//  用于包装 LMNativeExpressAd 的 expressView
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LMNativeExpressAd;
@class LMBUMNativeAdapter;

NS_ASSUME_NONNULL_BEGIN

/// 用于包装 LMNativeExpressAd 的 Express View Wrapper
/// 模板广告需要包装在 wrapper 中，以便 BUM SDK 正确识别和管理
@interface LMBUMExpressNativeViewWrapper : UIView

/// 原始模板广告实例
@property(nonatomic, strong) LMNativeExpressAd *expressAd;
/// Adapter 引用（用于回调）
@property(nonatomic, weak) LMBUMNativeAdapter *adapter;

/// 初始化方法
/// @param expressAd 模板广告实例
/// @param adapter 适配器实例
- (instancetype)initWithExpressAd:(LMNativeExpressAd *)expressAd adapter:(LMBUMNativeAdapter *)adapter;

@end

NS_ASSUME_NONNULL_END
