//
//  LMTakuNativeRenderer.m
//  LitemizeSDK
//
//  Taku/AnyThink 原生广告 Renderer 实现
//

#import "LMTakuNativeRenderer.h"
#import "LMTakuLoopVideoPlayerView.h"
#import "LMTakuNativeCustomEvent.h"
#import <AVFoundation/AVFoundation.h>
#import <AnyThinkNative/ATNativeRenderer.h>
#import <AnyThinkNative/AnyThinkNative.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <LitemizeSDK/LMNativeAdViewMapping.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

@interface LMTakuNativeRenderer ()

/// CustomEvent 实例（从 offer.assets 中获取）
@property(nonatomic, readonly, nullable) LMTakuNativeCustomEvent *customEvent;

/// 原生广告数据对象（自渲染，从 offer.assets 中获取）
@property(nonatomic, readonly, nullable) LMNativeAdDataObject *dataObject;

/// 原生模板广告实例（模板渲染，从 offer.assets 中获取）
@property(nonatomic, readonly, nullable) LMNativeExpressAd *nativeExpressAd;

/// 原生广告实例（自渲染，从 customEvent 中获取）
@property(nonatomic, readonly, nullable) LMNativeAd *nativeAd;

/// 是否为模板渲染广告
@property(nonatomic, assign, readonly) BOOL isExpressAd;

/// 当前 offer（用于 dealloc 等方法）
@property(nonatomic, strong, nullable) ATNativeADCache *currentOffer;

/// 视频播放器视图（用于视频控制方法）
@property(nonatomic, weak, nullable) LMTakuLoopVideoPlayerView *videoPlayerView;

@end

@implementation LMTakuNativeRenderer

#pragma mark - ATNativeRenderer

/// 渲染广告 offer
/// @param offer 广告缓存对象，包含广告数据和素材
- (void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];

    // 保存 offer 引用（用于后续方法）
    _currentOffer = offer;

    // 从 offer.assets 中获取 CustomEvent
    _customEvent = offer.assets[kATAdAssetsCustomEventKey];
    if (!_customEvent || ![_customEvent isKindOfClass:[LMTakuNativeCustomEvent class]]) {
        NSLog(@"⚠️ LMTakuNativeRenderer: CustomEvent 为空或类型不正确");
        return;
    }

    // 设置 ADView 的 customEvent（用于后续的回调）
    self.ADView.customEvent = _customEvent;

    // 从 offer.assets 中获取自定义对象
    id value = offer.assets[kATAdAssetsCustomObjectKey];

    // 根据是否为模板广告来决定处理方式
    _isExpressAd = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];

    if (_isExpressAd) {
        // 模板渲染广告处理
        // 从 offer.assets 中获取原生模板广告实例
        if ([value isKindOfClass:[LMNativeExpressAd class]]) {
            _nativeExpressAd = (LMNativeExpressAd *)value;
            [_nativeExpressAd showInView:self.ADView];
        } else {
            NSLog(@"⚠️ LMTakuNativeRenderer: 原生模板广告实例为空或类型不正确");
        }
    } else {
        // 自渲染广告处理

        // 从 offer.assets 中获取原生广告数据对象
        if ([value isKindOfClass:[LMNativeAdDataObject class]]) {
            _dataObject = (LMNativeAdDataObject *)value;

            // 从 customEvent 中获取原生广告实例
            _nativeAd = _customEvent.nativeAd;
            if (!_nativeAd) {
                NSLog(@"⚠️ LMTakuNativeRenderer: 原生广告实例为空");
                return;
            }

            // 注册广告视图到原生广告实例（用于曝光监听和点击上报）
            // 注意：ADView 可选实现 LMNativeAdViewProtocol 协议
            if (self.ADView) {
                // 从 ADView 中查找 dislikeButton（通过属性）
                UIButton *dislikeButton = [self _findDislikeButtonInView:self.ADView];

                // 如果找到 dislikeButton，创建属性映射配置
                if (dislikeButton) {
                    NSLog(@"✅ LMTakuNativeRenderer: 找到 dislikeButton，创建属性映射");
                    // 创建映射配置，将 dislikeButton 映射为 closeButton（参考 Taku 的实现方式）
                    LMNativeAdViewMapping *mapping = [LMNativeAdViewMapping loadMapping:^(LMNativeAdViewMapping *mapping) {
                        mapping.closeButton = dislikeButton;
                        mapping.yaoyiyaoView = nil;
                    }];
                    // 使用映射配置注册视图
                    [_nativeAd registerAdView:self.ADView withMapping:mapping];
                } else {
                    // 没有找到 dislikeButton，直接注册视图
                    [_nativeAd registerAdView:self.ADView];
                }

            } else {
                NSLog(@"⚠️ LMTakuNativeRenderer: ADView 为空，无法注册");
            }

            // 关于 logo 的显示，通过 self.configuration.logoViewFrame，获取开发者传入的 logoViewFrame，去给开发者创建并显示 logo
            // 注意：这里需要根据实际需求处理 logo 显示

            NSLog(@"✅ LMTakuNativeRenderer: 渲染完成，dataObject.title=%@", _dataObject.title);
        } else {
            NSLog(@"⚠️ LMTakuNativeRenderer: 原生广告数据对象为空或类型不正确");
        }
    }
}

/// 获取网络媒体视图（视频广告）
/// @return MediaView 对象，如果不需要则返回 nil
- (UIView *)getNetWorkMediaView {
    // ---- 先调用了这里，offer 从 ADView.nativeAd 获取 ----
    if (!self.ADView || ![self.ADView respondsToSelector:@selector(nativeAd)]) {
        return nil;
    }

    // offer 实际上是 ATNativeADCache 类型
    id adCache = [self.ADView performSelector:@selector(nativeAd)];
    ATNativeADCache *offer = nil;
    if ([adCache isKindOfClass:NSClassFromString(@"ATNativeADCache")]) {
        offer = (ATNativeADCache *)adCache;
    } else {
        return nil;
    }
    if (!offer) {
        return nil;
    }

    id valueOri = offer.assets[kATAdAssetsCustomObjectKey];
    // 这里实际 valueOri 为 LMNativeAdDataObject（如接 QuMeng 时是 QuMengNativeAd），需安全判断和取值
    LMNativeAdDataObject *value = nil;
    if ([valueOri isKindOfClass:[LMNativeAdDataObject class]]) {
        value = (LMNativeAdDataObject *)valueOri;

        // 自渲染-视频广告返回循环播放器 view
        if (value.isVideo && value.materialList.count > 0) {
            // 获取第一个视频物料的 URL
            LMNativeAdMaterialObject *firstMaterial = value.materialList.firstObject;
            NSString *videoURL = firstMaterial.materialUrl;

            if (videoURL && videoURL.length > 0) {
                // 创建循环播放视频播放器
                LMTakuLoopVideoPlayerView *videoPlayerView = [[LMTakuLoopVideoPlayerView alloc] initWithVideoURL:videoURL];

                if (videoPlayerView) {
                    // 设置填充模式
                    videoPlayerView.videoGravity = AVLayerVideoGravityResizeAspectFill;

                    // 设置自动播放（根据需求调整）
                    videoPlayerView.shouldAutoPlay = YES;

                    // 设置静音（根据需求调整，广告通常需要静音）
                    videoPlayerView.muted = YES;

                    // 不设置 frame，使用 Auto Layout（约束会在 TakuSelfRenderView 中设置）
                    // 确保使用 Auto Layout
                    videoPlayerView.translatesAutoresizingMaskIntoConstraints = NO;

                    // 保存视频播放器引用（用于后续控制方法）
                    _videoPlayerView = videoPlayerView;

                    NSLog(@"✅ LMTakuNativeRenderer: 创建循环播放视频播放器，URL: %@", videoURL);
                    return videoPlayerView;
                } else {
                    NSLog(@"⚠️ LMTakuNativeRenderer: 创建视频播放器失败，URL: %@", videoURL);
                }
            } else {
                NSLog(@"⚠️ LMTakuNativeRenderer: 视频 URL 为空");
            }
        }
    }

    // 模板视频广告
    // 注意：对于模板广告，视频播放器已经在 expressView 内部，不需要单独返回
    // 如果需要返回视频视图，可以通过查找包含 AVPlayerLayer 的视图来判断

    return nil;
}

/// 获取当前原生广告渲染类型
/// @return 渲染类型
- (ATNativeAdRenderType)getCurrentNativeAdRenderType {
    if (_isExpressAd) {
        return ATNativeAdRenderExpress;
    } else {
        return ATNativeAdRenderSelfRender;
    }
}

/**
 * The duration of the video ad playing, unit ms
 * 获取视频广告当前播放时长，单位：毫秒
 */
- (CGFloat)videoPlayTime {
    if (self.videoPlayerView) {
        return [self.videoPlayerView currentPlayTime];
    }
    return 0;
}

/**
 * Video ad duration, unit ms
 * 获取视频广告总时长，单位：毫秒
 */
- (CGFloat)videoDuration {
    if (self.videoPlayerView) {
        return [self.videoPlayerView duration];
    }
    return 0;
}

/**
 Play mute switch
 @param flag whether to mute
 播放静音开关
 @param flag 是否静音
 */
- (void)muteEnable:(BOOL)flag {
    if (self.videoPlayerView) {
        self.videoPlayerView.muted = flag;
        NSLog(@"✅ LMTakuNativeRenderer: 设置视频静音: %@", flag ? @"YES" : @"NO");
    }
}

/**
 * The video ad play
 * 播放视频广告
 */
- (void)videoPlay {
    if (self.videoPlayerView) {
        [self.videoPlayerView play];
        NSLog(@"✅ LMTakuNativeRenderer: 播放视频");
    }
}

/**
 * The video ad pause
 * 暂停视频广告
 */
- (void)videoPause {
    if (self.videoPlayerView) {
        [self.videoPlayerView pause];
        NSLog(@"✅ LMTakuNativeRenderer: 暂停视频");
    }
}

#pragma mark - Private Methods

/// 从视图中查找 dislikeButton
/// @param view 要查找的视图
/// @return 找到的 dislikeButton，如果不存在则返回 nil
- (UIButton *)_findDislikeButtonInView:(UIView *)view {
    if (!view) {
        return nil;
    }

    // 检查 view 本身是否有 dislikeButton 属性
    if ([view respondsToSelector:@selector(dislikeButton)]) {
        UIButton *button = [view performSelector:@selector(dislikeButton)];
        if (button && [button isKindOfClass:[UIButton class]]) {
            return button;
        }
    }

    return nil;
}

@end
