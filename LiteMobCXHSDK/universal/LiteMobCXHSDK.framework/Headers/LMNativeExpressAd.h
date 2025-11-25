//
//  LMNativeExpressAd.h
//  LiteMobCXHSDK
//
//  信息流模版渲染广告
//

#import <Foundation/Foundation.h>
#import <LiteMobCXHSDK/LMAdSlot.h>
#import <LiteMobCXHSDK/LMBaseAd.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMNativeExpressAd;

/// 信息流广告素材填充方式
typedef NS_ENUM(NSInteger, LMNativeExpressAdMaterialFillMode) {
  LMNativeExpressAdMaterialFillModeScaleAspectFill = 0, ///< 默认，按比例填充，可能会裁剪
  LMNativeExpressAdMaterialFillModeScaleToFill, ///< 拉伸填充
  LMNativeExpressAdMaterialFillModeScaleAspectFit, ///< 按比例适应，可能会留白
};

/// 信息流广告模板类型
typedef NS_ENUM(NSInteger, LMNativeExpressAdTemplateType) {
  LMNativeExpressAdTemplateTypeTextTopImageBottom = 1, ///< 上文下图
  LMNativeExpressAdTemplateTypeTextBottomImageTop = 2, ///< 下文上图
  LMNativeExpressAdTemplateTypeImageLeftTextRight = 3, ///< 左图右文
  LMNativeExpressAdTemplateTypeImageRightTextLeft = 4, ///< 右图左文
  LMNativeExpressAdTemplateTypeThreeImages = 5, ///< 三图
  LMNativeExpressAdTemplateTypeVertical = 6, ///< 竖版
};

/// 信息流广告代理
@protocol LMNativeExpressAdDelegate <NSObject>
@optional
/// 广告策略服务加载成功
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdDidFinishLoadingADPolicy:(LMNativeExpressAd *)nativeExpressAd;

/// 广告数据加载成功回调
/// - Parameter nativeExpressAd: 信息流广告实例
/// - Note: 加载成功后，可以通过 nativeExpressAd.expressView 获取广告视图
- (void)lm_nativeExpressAdLoaded:(LMNativeExpressAd *)nativeExpressAd;

/// 广告加载失败
/// - Parameters:
///   - nativeExpressAd: 信息流广告实例
///   - error: 错误信息
///   - description: 错误描述字典
- (void)lm_nativeExpressAd:(LMNativeExpressAd *)nativeExpressAd
          didFailWithError:(nullable NSError *)error
               description:(NSDictionary *)description;

/// 信息流广告渲染成功
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewRenderSuccess:(LMNativeExpressAd *)nativeExpressAd;

/// 信息流广告渲染失败
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewRenderFail:(LMNativeExpressAd *)nativeExpressAd;

/// 广告即将曝光
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewWillExpose:(LMNativeExpressAd *)nativeExpressAd;

/// 广告被点击
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdViewDidClick:(LMNativeExpressAd *)nativeExpressAd;

/// 广告关闭回调
/// - Note: UI的移除和数据的解绑需要在该回调中进行
/// - Parameter nativeExpressAd: 信息流广告实例
- (void)lm_nativeExpressAdDidClose:(LMNativeExpressAd *)nativeExpressAd;
@end

/// 信息流模版渲染广告
/// - Note: 适用于信息流广告/沉浸式视频流广告/详情页插入广告/视频贴片广告等场景
@interface LMNativeExpressAd : LMBaseAd

/// 代理
@property(nonatomic, weak) id<LMNativeExpressAdDelegate> delegate;

/// 广告加载容忍时间（秒），建议3s~5s
/// - Note: 如果设定的时间内没有竞价到广告，则判断竞价失败，触发失败回调
@property(nonatomic, assign) NSTimeInterval tolerateTime;

/// 广告加载容器视图控制器（必填）
@property(nonatomic, weak) UIViewController *viewController;

/// 素材填充方式（默认：ScaleAspectFill）
@property(nonatomic, assign) LMNativeExpressAdMaterialFillMode materialFillMode;

/// 广告模板类型（默认：TextTopImageBottom 上文下图）
/// - Note: 1-上文下图, 2-下文上图, 3-左图右文, 4-右图左文, 5-三图, 6-竖版
@property(nonatomic, assign) LMNativeExpressAdTemplateType templateType;

/// 信息流广告视图（只读）
/// - Note: 需要将此视图添加到容器中才能展示广告
@property(nonatomic, strong, readonly, nullable) UIView *expressView;

/// 渠道标识（只读）
/// - Note: 标识广告来源渠道，如：PDD(拼多多)、VL(瑞狮)、JM(京东)、VS(SIGMOB)、VB(百度)
@property(nonatomic, copy, readonly, nullable) NSString *identifier;

/// 广告价格（只读，单位：分）
@property(nonatomic, assign, readonly) NSUInteger price;

/// 初始化方法
/// - Parameter adSlot: 广告位配置，需设置 slotId 和 imgSize
/// - Returns: 如果 adSlot 为空或类型不正确，返回 nil
- (nullable instancetype)initWithSlot:(LMAdSlot *)adSlot;

/// 加载广告
- (void)loadAd;

/// 广告是否有效
/// - Returns: YES 表示广告有效，NO 表示已过期或未加载
- (BOOL)isAdValid;

/// 展示广告到指定容器视图
/// - Parameter containerView: 容器视图，广告视图将添加到该视图中
/// - Note: 调用此方法会将广告视图添加到容器中，并自动触发曝光上报
- (void)showInView:(UIView *)containerView;

/// 移除广告（从容器视图移除）
/// - Note: 调用此方法会从父视图中移除广告视图，但不会销毁广告对象
- (void)removeFromSuperview;

/// 关闭广告，释放前调用
/// - Note: 调用此方法后，广告对象将无法继续使用
- (void)close;

/// 发送竞败通知
/// - Parameter lossInfo: 竞败信息字典
/// - Note: SDK广告竞败之后或未参竞时调用，用于上传竞败信息
///         字典key可参考竞败相关宏定义（如：竞胜价格等）
- (void)sendLossNotificationWithInfo:(NSDictionary *)lossInfo;

@end

NS_ASSUME_NONNULL_END
