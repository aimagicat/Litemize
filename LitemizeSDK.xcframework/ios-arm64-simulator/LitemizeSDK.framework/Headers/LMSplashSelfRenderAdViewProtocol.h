//
//  LMSplashSelfRenderAdViewProtocol.h
//  LitemizeSDK
//
//  开屏自渲染广告视图协议
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 开屏自渲染广告视图协议
/// - Note: 开发者自定义的开屏广告视图需要遵循此协议，提供必需的UI元素
///         SDK负责这些按钮的逻辑（倒计时、点击关闭、声音控制等）
@protocol LMSplashSelfRenderAdViewProtocol <NSObject>

@required

/// 关闭/跳过按钮（必需）
/// - Note: SDK会管理倒计时逻辑和点击关闭逻辑
///         开发者可以使用任何 UIButton 子类，SDK会在注册时配置逻辑
@property(nonatomic, strong, nullable) UIButton *skipButton;

/// 声音控制按钮（必需，用于视频广告）
/// - Note: SDK会管理点击静音/取消静音的逻辑
@property(nonatomic, strong, nullable) UIButton *muteButton;

/// 播放/暂停按钮（必需，用于视频广告）
/// - Note: SDK会管理点击播放/暂停的逻辑
@property(nonatomic, strong, nullable) UIButton *playPauseButton;

/// 摇一摇视图（可选）
/// - Note: 如果为 nil，SDK会根据策略自动创建（需要策略允许）
@property(nonatomic, strong, nullable) UIView *yaoyiyaoView;

@end

NS_ASSUME_NONNULL_END
