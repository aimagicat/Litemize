//
//  LMNativeAdConfig.h
//  LiteMobCXHSDK
//
//  信息流自渲染广告配置类
//

#import <Foundation/Foundation.h>
#import <LiteMobCXHSDK/LMAdSlot.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 信息流自渲染广告配置
@interface LMNativeAdConfig : NSObject

/// 广告位配置（必填）
/// - Note: 包含 slotId、slotType、imgSize 等基础配置
@property(nonatomic, strong) LMAdSlot *adSlot;

/// 广告加载容忍时间（秒），建议3s~5s
/// - Note: 如果设定的时间内没有竞价到广告，则判断竞价失败，触发失败回调
@property(nonatomic, assign) NSTimeInterval tolerateTime;

/// 广告加载容器视图控制器（必填）
@property(nonatomic, weak) UIViewController *viewController;

/// 初始化方法
/// - Parameter adSlot: 广告位配置，需设置 slotId 和 imgSize
- (instancetype)initWithSlot:(LMAdSlot *)adSlot;

@end

NS_ASSUME_NONNULL_END
