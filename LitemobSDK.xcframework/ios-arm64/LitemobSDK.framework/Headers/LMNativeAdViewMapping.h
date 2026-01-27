//
//  LMNativeAdViewMapping.h
//  LitemobSDK
//
//  信息流自渲染广告视图属性映射配置
//  用于 adapter 场景，将第三方广告视图的属性映射为协议属性
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 信息流自渲染广告视图属性映射配置
/// - Note: 用于 adapter 场景，当广告视图不实现 LMNativeAdViewProtocol 协议时，
///         可以通过此配置类将第三方广告视图的属性映射为协议属性
@interface LMNativeAdViewMapping : NSObject

/// 关闭按钮（映射为协议的 closeButton）
@property(nonatomic, strong, nullable) UIButton *closeButton;

/// 摇一摇视图（映射为协议的 yaoyiyaoView）
@property(nonatomic, strong, nullable) UIView *yaoyiyaoView;

/// 需要提到 touchView 上层的视图数组（用于 adapter 场景）
/// - Note: 这些视图会被自动提到 touchView 上方，确保可以正常响应触摸事件
///         适用于第三方广告 SDK 的交互视图（如关闭按钮、下载按钮等）
@property(nonatomic, strong, nullable) NSArray<UIView *> *viewsToBringToFront;

/// 使用 block 配置映射（参考 Taku 的实现方式）
/// @param block 配置 block，在 block 中设置映射属性
/// @return 配置完成的映射对象
+ (instancetype)loadMapping:(void (^)(LMNativeAdViewMapping *mapping))block;

@end

// 便捷宏用法示例：
// LMNativeAdViewMapping *mapping = LMNativeAdViewMappingMake(^(LMNativeAdViewMapping *m) {
//     m.closeButton = xxx;
//     m.yaoyiyaoView = xxx;
// });
#define LMNativeAdViewMappingMake(block) [LMNativeAdViewMapping loadMapping:block]

NS_ASSUME_NONNULL_END
