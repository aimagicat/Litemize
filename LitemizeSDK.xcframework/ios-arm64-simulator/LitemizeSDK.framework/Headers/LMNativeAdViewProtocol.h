//
//  LMNativeAdViewProtocol.h
//  LitemizeSDK
//
//  信息流自渲染广告视图协议
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 信息流自渲染广告视图协议
/// - Note: 开发者自定义的广告视图需要遵循此协议
///         协议中定义的视图会被放在 touchView 上方，touchView 会跳过这些视图，不拦截它们的触摸事件
///         其他区域都视作广告区域，可以被 touchView 捕获用于点击上报
@protocol LMNativeAdViewProtocol <NSObject>

@optional

/// 关闭按钮（可选）
/// - Note: 如果提供此按钮，touchView 会跳过此按钮，不拦截其触摸事件
///         开发者需要自行实现关闭按钮的点击逻辑，并在适当时机调用 lm_nativeAdDidClose:adView: 回调
@property(nonatomic, strong, nullable) UIButton *closeButton;

/// 摇一摇视图（可选）
/// - Note: 如果提供此视图，touchView 会跳过此视图，不拦截其触摸事件
///         如果为 nil，SDK 会根据策略自动创建（需要策略允许）
@property(nonatomic, strong, nullable) UIView *yaoyiyaoView;

@end

NS_ASSUME_NONNULL_END
