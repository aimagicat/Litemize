//
//  LMBannerAd.h
//  LiteMobCXHSDK
//
//  Banner 横幅广告
//

#import <LiteMobCXHSDK/LMAdSlot.h>
#import <LiteMobCXHSDK/LMBaseAd.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMBannerAd;

/// Banner 广告布局方向
typedef NS_ENUM(NSInteger, LMBannerAdLayoutDirection) {
  LMBannerAdLayoutDirectionImageLeftTextRight = 0, ///< 左图右文（默认）
  LMBannerAdLayoutDirectionImageRightTextLeft = 1, ///< 右图左文
};

/// Banner 广告代理
@protocol LMBannerAdDelegate <NSObject>
@optional
/// 广告加载成功
- (void)lm_bannerAdDidLoad:(LMBannerAd *)bannerAd;
/// 广告加载失败
- (void)lm_bannerAd:(LMBannerAd *)bannerAd didFailWithError:(NSError *)error;
/// 广告即将展示
- (void)lm_bannerAdWillVisible:(LMBannerAd *)bannerAd;
/// 广告被点击
- (void)lm_bannerAdDidClick:(LMBannerAd *)bannerAd;
/// 广告关闭
- (void)lm_bannerAdDidClose:(LMBannerAd *)bannerAd;
@end

/// Banner 横幅广告
/// - Note: Banner 广告需要通过 showInView: 方法展示到容器视图中
@interface LMBannerAd : LMBaseAd

/// 代理
@property(nonatomic, weak) id<LMBannerAdDelegate> delegate;
/// 布局方向（默认：左图右文）
@property(nonatomic, assign) LMBannerAdLayoutDirection layoutDirection;

/// 初始化 Banner 广告
/// - Parameter adSlot: 广告位配置，需设置 imgSize（如 CGSizeMake(320, 50)）
- (instancetype)initWithSlot:(LMAdSlot *)adSlot;

/// 加载广告
- (void)loadAd;

/// 展示广告到指定容器视图
/// - Parameter containerView: 容器视图，Banner 广告将添加到该视图中
- (void)showInView:(UIView *)containerView;

/// 移除广告（从容器视图移除并清理资源）
- (void)removeFromSuperview;

/// 关闭广告（释放资源并触发关闭回调）
/// - Note: 调用此方法会触发 lm_bannerAdDidClose: 回调
- (void)close;

@end

NS_ASSUME_NONNULL_END
