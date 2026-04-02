//
//  LMTakuNativeObject.m
//  LitemobSDK
//
//  Taku/AnyThink 自定义平台原生广告对象实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuNativeObject.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import <AVFoundation/AVFoundation.h>
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <LitemobSDK/LMNativeAd.h>
#import <LitemobSDK/LMNativeAdDataObject.h>
#import <UIKit/UIKit.h>

/// Taku 视频播放器视图（内部类）
/// 使用 AVPlayer 和 AVPlayerLayer 实现视频播放
@interface LMTakuVideoPlayerView : UIView

/// 视频播放器（只读）
@property(nonatomic, strong, readonly, nullable) AVPlayer *player;

/// 视频播放器层（只读）
@property(nonatomic, strong, readonly, nullable) AVPlayerLayer *playerLayer;

/// 视频填充模式（默认：AVLayerVideoGravityResizeAspectFill）
@property(nonatomic, assign) AVLayerVideoGravity videoGravity;

/// 是否自动播放（默认：YES）
@property(nonatomic, assign) BOOL shouldAutoPlay;

/// 初始化方法（通过视频 URL 创建）
- (nullable instancetype)initWithVideoURL:(NSString *)videoURL;

/// 播放视频
- (void)play;

/// 暂停视频
- (void)pause;

/// 停止视频（暂停并重置到开始位置）
- (void)stop;

/// 清理资源
- (void)cleanup;

@end

@interface LMTakuVideoPlayerView ()

@property(nonatomic, strong, nullable, readwrite) AVPlayer *player;
@property(nonatomic, strong, nullable) AVPlayerItem *playerItem;

@end

@implementation LMTakuVideoPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (nullable instancetype)initWithVideoURL:(NSString *)videoURL {
    if (!videoURL || videoURL.length == 0) {
        LMTakuLog(@"Native", @"⚠️ LMTakuVideoPlayerView: 视频 URL 为空");
        return nil;
    }

    // 创建 URL
    NSURL *url = nil;
    if ([videoURL hasPrefix:@"http://"] || [videoURL hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:videoURL];
    } else {
        url = [NSURL fileURLWithPath:videoURL];
    }

    if (!url) {
        LMTakuLog(@"Native", @"⚠️ LMTakuVideoPlayerView: 视频 URL 无效: %@", videoURL);
        return nil;
    }

    self = [super init];
    if (self) {
        _videoGravity = AVLayerVideoGravityResizeAspectFill;
        _shouldAutoPlay = YES;

        // 创建播放器
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

        // 设置 playerLayer
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
        playerLayer.player = player;
        playerLayer.videoGravity = _videoGravity;

        // 默认开启声音（不静音）
        player.muted = NO;

        // 设置背景色为黑色（视频加载前的默认背景）
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        // 保存引用
        _player = player;
        _playerItem = playerItem;

        // 监听播放器状态和播放结束
        [self _setupPlayerObservers];

        LMTakuLog(@"Native", @"✅ LMTakuVideoPlayerView: 视频播放器已创建，URL: %@", videoURL);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _videoGravity = AVLayerVideoGravityResizeAspectFill;
        _shouldAutoPlay = YES;

        // 设置 playerLayer（即使 player 为 nil）
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
        playerLayer.videoGravity = _videoGravity;

        // 设置背景色为黑色
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;

    // 确保在主线程上设置
    if ([NSThread isMainThread]) {
        self.playerLayer.videoGravity = videoGravity;
        // 强制刷新 layer
        [self.playerLayer setNeedsDisplay];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playerLayer.videoGravity = videoGravity;
            // 强制刷新 layer
            [self.playerLayer setNeedsDisplay];
            [self setNeedsLayout];
        });
    }
}

#pragma mark - Public Methods

- (void)play {
    if (!self.player) {
        return;
    }
    [self.player play];
}

- (void)pause {
    if (self.player) {
        [self.player pause];
    }
}

- (void)stop {
    if (self.player) {
        [self.player pause];
        [self.player seekToTime:kCMTimeZero];
    }
}

- (void)cleanup {
    // 移除观察者
    [self _removePlayerObservers];

    // 停止播放
    [self stop];

    // 清理资源
    self.player = nil;
    self.playerItem = nil;
}

#pragma mark - Private Methods

/// 设置播放器观察者
- (void)_setupPlayerObservers {
    if (!self.playerItem) {
        return;
    }

    // 监听播放器状态
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    // 监听播放结束（用于循环播放）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
}

/// 移除播放器观察者
- (void)_removePlayerObservers {
    if (self.playerItem) {
        @try {
            [self.playerItem removeObserver:self forKeyPath:@"status"];
        } @catch (NSException *exception) {
            // 观察者可能已经被移除，忽略异常
        }
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 播放器状态变化回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            LMTakuLog(@"Native", @"✅ LMTakuVideoPlayerView: 视频准备就绪");
            // 如果设置了自动播放，开始播放
            if (self.shouldAutoPlay) {
                [self play];
            }
        } else if (item.status == AVPlayerItemStatusFailed) {
            LMTakuLog(@"Native", @"⚠️ LMTakuVideoPlayerView: 视频加载失败: %@", item.error.localizedDescription);
        }
    }
}

/// 播放结束回调（用于循环播放）
- (void)_playerItemDidPlayToEndTime:(NSNotification *)notification {
    // 广告视频通常需要循环播放
    if (self.player) {
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
    }
}

// 重写 layoutSubviews，确保 playerLayer 的 frame 与视图 bounds 同步
// 这样 Auto Layout 会自动管理视频层的大小
- (void)layoutSubviews {
    [super layoutSubviews];
    // AVPlayerLayer 会自动跟随视图的 bounds，无需手动设置
    // 但为了确保同步，我们在这里显式设置一次
    self.playerLayer.frame = self.bounds;
}

- (void)dealloc {
    [self cleanup];
    LMTakuLog(@"Native", @"LMTakuVideoPlayerView dealloc");
}

@end

@interface LMTakuNativeObject ()

/// 视频播放器视图引用（用于后续清理）
@property(nonatomic, strong, nullable) LMTakuVideoPlayerView *videoPlayerView;

/// 媒体视图实例变量（私有存储）
@property(nonatomic, strong, nullable) UIView *privateMediaView;

@end

@implementation LMTakuNativeObject

// 父类 ATCustomNetworkNativeAd 可能已声明 mediaView 属性，使用 @dynamic 并重写 getter
@dynamic mediaView;

/// 注册可点击视图和容器视图
/// @param clickableViews 可点击视图数组
/// @param container 容器视图（AnyThink SDK 传入的 ATNativeADView）
/// @param registerArgument 注册参数（包含关闭按钮、媒体视图等信息）
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews
                 withContainer:(UIView *)container
              registerArgument:(ATNativeRegisterArgument *)registerArgument {
    LMTakuLog(@"Native", @"🔥 registerClickableViews 被调用 - container: %@, clickableViews count: %lu, renderType: %ld",
              container, (unsigned long)clickableViews.count, (long)self.nativeAdRenderType);

    // 防御：没有底层原生广告实例时直接返回
    if (!self.nativeAd) {
        LMTakuLog(@"Native", @"⚠️ nativeAd 为空，无法注册点击事件");
        return;
    }

    if (!container) {
        LMTakuLog(@"Native", @"⚠️ container 为空，无法注册点击事件");
        return;
    }

    // 模板渲染和自渲染都需要注册点击事件
    // 对于模板渲染，AnyThink SDK 会自动处理点击，但需要确保 viewController 设置正确
    // 对于自渲染，需要明确注册可点击视图

    if (self.nativeAdRenderType == ATNativeAdRenderExpress) {
        // 模板渲染：将整个容器视图注册为可点击区域
        // 模板渲染时，AnyThink SDK 会自动处理点击，但需要确保 LitemobSDK 的 viewController 设置正确
        LMNativeAdViewMapping *mapping = [LMNativeAdViewMapping loadMapping:^(LMNativeAdViewMapping *_Nonnull mapping) {
            // 关闭按钮：从注册参数中获取（如果 AnyThink 有传入）
            if (registerArgument && registerArgument.dislikeButton) {
                mapping.closeButton = registerArgument.dislikeButton;
            } else {
                mapping.closeButton = nil;
            }
            // 模板渲染时，将整个容器作为可点击区域
            // mapping.viewsToBringToFront = container ? @[ container ] : nil;
            mapping.yaoyiyaoView = nil;
        }];
        [self.nativeAd registerAdView:container withMapping:mapping];
        LMTakuLog(@"Native", @"✅ 模板渲染广告已注册点击事件，container = %@", container);
    } else {
        // 自渲染：明确注册可点击视图
        // 注意：container 是 AnyThink SDK 传入的 ATNativeADView
        // clickableViews 是我们在 Demo 中注册的可点击视图数组（icon、title、text、cta、mainImage 等）
        // 这些视图是 TakuNativeAdCustomView 的子视图，而不是 ATNativeADView 的直接子视图
        if (!clickableViews || clickableViews.count == 0) {
            LMTakuLog(@"Native", @"⚠️ 自渲染广告 clickableViews 为空，无法注册点击事件");
            return;
        }

        // 关键修复：找到 clickableViews 中第一个视图的父视图（应该是 TakuNativeAdCustomView）
        // 如果找不到，则使用 container（ATNativeADView）作为容器
        UIView *actualContainer = container;
        if (clickableViews.count > 0) {
            UIView *firstClickableView = clickableViews.firstObject;
            UIView *parentView = firstClickableView.superview;

            // 向上查找，找到包含所有 clickableViews 的公共父视图
            // 通常这个父视图就是 TakuNativeAdCustomView（自渲染视图）
            while (parentView && parentView != container) {
                // 检查这个父视图是否包含所有 clickableViews
                BOOL containsAll = YES;
                for (UIView *view in clickableViews) {
                    if (![view isDescendantOfView:parentView]) {
                        containsAll = NO;
                        break;
                    }
                }

                if (containsAll) {
                    actualContainer = parentView;
                    LMTakuLog(@"Native", @"✅ 找到自渲染视图容器: %@ (原 container: %@)", actualContainer, container);
                    break;
                }

                parentView = parentView.superview;
            }

            // 如果没找到合适的父视图，使用 container（ATNativeADView）
            // 这种情况下，LitemobSDK 可能会报错，但至少不会崩溃
            if (actualContainer == container) {
                LMTakuLog(@"Native", @"⚠️ 未找到自渲染视图容器，使用 ATNativeADView 作为容器（可能导致层级检查失败）");
            }
        }

        LMNativeAdViewMapping *mapping = [LMNativeAdViewMapping loadMapping:^(LMNativeAdViewMapping *_Nonnull mapping) {
            // 关闭按钮：从注册参数中获取（如果 AnyThink 有传入）
            // 关闭按钮会单独处理自己的点击事件（关闭广告），不参与 touchView 的跳转逻辑
            if (registerArgument && registerArgument.dislikeButton) {
                mapping.closeButton = registerArgument.dislikeButton;
                // 确保关闭按钮可以响应点击事件
                registerArgument.dislikeButton.userInteractionEnabled = YES;
                LMTakuLog(@"Native", @"✅ 找到关闭按钮: %@", registerArgument.dislikeButton);
            } else {
                mapping.closeButton = nil;
                LMTakuLog(@"Native", @"⚠️ 未找到关闭按钮");
            }

            mapping.viewsToBringToFront = nil;
            // 摇一摇视图：当前未使用
            mapping.yaoyiyaoView = nil;
        }];

        // 确保容器视图可以响应交互（touchView 需要添加到可交互的容器上）
        actualContainer.userInteractionEnabled = YES;

        // 注册到 LitemobSDK：使用找到的自渲染视图容器（TakuNativeAdCustomView）
        // 注意：registerAdView 会在容器上添加 touchView，用于拦截点击事件
        // touchView 会覆盖整个容器，统一处理点击跳转（关闭按钮除外）
        [self.nativeAd registerAdView:actualContainer withMapping:mapping];
        LMTakuLog(@"Native",
                  @"✅ 自渲染广告已注册点击事件 - container: %@ (userInteractionEnabled: %d), clickableViews count: %lu",
                  actualContainer, actualContainer.userInteractionEnabled, (unsigned long)clickableViews.count);

        // 确保 viewController 已设置（用于点击跳转）
        if (registerArgument && registerArgument.viewController && self.nativeAd) {
            self.nativeAd.viewController = registerArgument.viewController;
            LMTakuLog(@"Native", @"✅ 已设置 viewController: %@", registerArgument.viewController);
        }
    }
}

/// 配置原生广告渲染参数
/// @param configuration AnyThink 下发的渲染配置
- (void)setNativeADConfiguration:(ATNativeAdRenderConfig *)configuration {
    // 将根控制器同步给 LitemobSDK，确保点击跳转等行为正常
    if (self.nativeAd && configuration.rootViewController) {
        self.nativeAd.viewController = configuration.rootViewController;
    }
}

#pragma mark - MediaView

/// 获取媒体视图（用于视频广告）
/// @discussion AnyThink SDK 会通过此方法获取 mediaView，如果是视频广告，需要返回视频播放器视图
- (UIView *)mediaView {
    if (!self.privateMediaView && self.dataObject) {
        // 检查是否是视频广告
        if (self.dataObject.isVideo && self.dataObject.materialList && self.dataObject.materialList.count > 0) {
            // 查找第一个视频物料
            LMNativeAdMaterialObject *videoMaterial = nil;
            for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
                if (material.isVideo && material.materialUrl && material.materialUrl.length > 0) {
                    videoMaterial = material;
                    break;
                }
            }

            // 如果找到视频物料，创建视频播放器
            if (videoMaterial) {
                NSString *videoURL = videoMaterial.materialUrl;
                LMTakuVideoPlayerView *videoPlayerView = [[LMTakuVideoPlayerView alloc] initWithVideoURL:videoURL];

                if (videoPlayerView) {
                    // 根据视频宽高比设置合适的填充模式
                    // 参考 LitemobSDK 内部实现：宽高比 < 0.7 认为是竖比例
                    CGFloat videoAspectRatio = 0;
                    BOOL isVideoPortrait = NO;
                    if (videoMaterial.materialWidth > 0 && videoMaterial.materialHeight > 0) {
                        videoAspectRatio = (CGFloat)videoMaterial.materialWidth / (CGFloat)videoMaterial.materialHeight;
                        isVideoPortrait = videoAspectRatio < 0.7;
                    }

                    // 根据视频方向设置填充模式
                    // 竖比例：使用 ResizeAspect（居中显示，左右留白）
                    // 横比例：使用 ResizeAspectFill（填充，上下可能裁剪）
                    AVLayerVideoGravity videoGravity =
                        isVideoPortrait ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResizeAspectFill;
                    videoPlayerView.videoGravity = videoGravity;

                    // 设置自动播放（广告通常需要自动播放）
                    videoPlayerView.shouldAutoPlay = YES;

                    self.privateMediaView = videoPlayerView;
                    self.videoPlayerView = videoPlayerView; // 保存引用以便后续清理

                    LMTakuLog(
                        @"Native", @"✅ LMTakuNativeObject: 创建视频播放器，URL: %@, 宽高比: %.2f, 竖比例: %d, videoGravity: %@",
                        videoURL, videoAspectRatio, isVideoPortrait, isVideoPortrait ? @"ResizeAspect" : @"ResizeAspectFill");
                } else {
                    LMTakuLog(@"Native", @"⚠️ LMTakuNativeObject: 创建视频播放器失败，URL: %@", videoURL);
                    // 创建失败时返回占位视图
                    self.privateMediaView = [[UIView alloc] init];
                    self.privateMediaView.backgroundColor = [UIColor clearColor];
                }
            } else {
                // 没有找到有效的视频物料，返回占位视图
                LMTakuLog(@"Native", @"⚠️ LMTakuNativeObject: 未找到有效的视频物料");
                self.privateMediaView = [[UIView alloc] init];
                self.privateMediaView.backgroundColor = [UIColor clearColor];
            }
        } else {
            // 不是视频广告，返回占位视图
            self.privateMediaView = [[UIView alloc] init];
            self.privateMediaView.backgroundColor = [UIColor clearColor];
        }
    }
    return self.privateMediaView;
}

- (void)dealloc {
    // 清理视频播放器资源
    if (self.videoPlayerView) {
        [self.videoPlayerView cleanup];
        self.videoPlayerView = nil;
    }
    self.privateMediaView = nil;

    // 注销 LitemobSDK 原生广告，避免回调和资源泄漏
    // 注意：如果 nativeAd 已经关闭（isClosed = YES），close 方法会直接返回，不会重复调用
    if (self.nativeAd) {
        self.nativeAd.delegate = nil;
        // 调用 close 方法，内部会检查 isClosed 状态，避免重复调用
        [self.nativeAd close];
        self.nativeAd = nil;
    }
    self.dataObject = nil;
    LMTakuLog(@"Native", @"LMTakuNativeObject dealloc");
}

@end
