//
//  LMNativeObject.h
//  LiteMobCXHSDK
//
//  信息流自渲染广告对象（Controller）
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <LiteMobCXHSDK/LMNativeAdViewProtocol.h>
#import <LiteMobCXHSDK/LMNativeAdDataObject.h>

NS_ASSUME_NONNULL_BEGIN

/// 信息流自渲染广告对象（Controller）
/// - Note: 内部使用MVC模式，此为Controller层
///         LMNativeObject(Controller), nativeAdView(View), LMNativeAdDataObject(Model)
@interface LMNativeObject : NSObject

/// 自渲染信息流广告素材（Model）
@property(nonatomic, strong, readonly) LMNativeAdDataObject *dataObject;

/// 自渲染信息流展示容器（View）
/// - Note: 开发者需要将此视图添加到自己的容器中才能展示广告
@property(nonatomic, strong, readonly) UIView<LMNativeAdViewProtocol> *nativeAdView;

/// 初始化方法（SDK内部使用，开发者不必理会）
/// - Parameters:
///   - nativeAdView: 自渲染信息流展示容器
///   - dataObject: 自渲染信息流广告素材
- (instancetype)initWithNativeAdView:(UIView<LMNativeAdViewProtocol> *)nativeAdView
                          dataObject:(LMNativeAdDataObject *)dataObject;

/// 绑定可点击、可关闭的视图
/// - Parameters:
///   - clickableViews: 可点击的视图数组，传nil表示整个广告视图可点击
///   - closeableViews: 可关闭的视图数组，传nil表示不支持关闭
/// - Note: 必须在广告视图添加到父视图之前调用
- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
                 closeableViews:(nullable NSArray<UIView *> *)closeableViews;

/// 销毁view，非常重要，必须在释放前调用
/// - Note: 调用此方法后，广告对象将无法继续使用
- (void)destoryNativeAdView;

@end

NS_ASSUME_NONNULL_END

