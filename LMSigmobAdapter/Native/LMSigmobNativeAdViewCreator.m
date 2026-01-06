//
//  LMSigmobNativeAdViewCreator.m
//  LitemizeSDK
//
//  Sigmob 原生广告视图创建器实现
//

#import "LMSigmobNativeAdViewCreator.h"
#import "../LMSigmobAdapterLog.h"
#import <AVFoundation/AVFoundation.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <UIKit/UIKit.h>

/// Sigmob 视频播放器视图（内部类）
/// 使用 AVPlayer 和 AVPlayerLayer 实现视频播放
@interface LMSigmobVideoPlayerView : UIView

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

@interface LMSigmobVideoPlayerView ()

@property(nonatomic, strong, nullable, readwrite) AVPlayer *player;
@property(nonatomic, strong, nullable) AVPlayerItem *playerItem;

@end

@implementation LMSigmobVideoPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (nullable instancetype)initWithVideoURL:(NSString *)videoURL {
    if (!videoURL || videoURL.length == 0) {
        LMSigmobLog(@"⚠️ LMSigmobVideoPlayerView: 视频 URL 为空");
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
        LMSigmobLog(@"⚠️ LMSigmobVideoPlayerView: 视频 URL 无效: %@", videoURL);
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

        // 设置静音（广告通常需要静音）
        player.muted = YES;

        // 设置背景色为黑色（视频加载前的默认背景）
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        // 保存引用
        _player = player;
        _playerItem = playerItem;

        // 监听播放器状态和播放结束
        [self _setupPlayerObservers];

        LMSigmobLog(@"✅ LMSigmobVideoPlayerView: 视频播放器已创建，URL: %@", videoURL);
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
    self.playerLayer.videoGravity = videoGravity;
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
            LMSigmobLog(@"✅ LMSigmobVideoPlayerView: 视频准备就绪");
            // 如果设置了自动播放，开始播放
            if (self.shouldAutoPlay) {
                [self play];
            }
        } else if (item.status == AVPlayerItemStatusFailed) {
            LMSigmobLog(@"⚠️ LMSigmobVideoPlayerView: 视频加载失败: %@", item.error.localizedDescription);
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

- (void)dealloc {
    [self cleanup];
    LMSigmobLog(@"LMSigmobVideoPlayerView dealloc");
}

@end

@interface LMSigmobNativeAdViewCreator ()

@property(nonatomic, strong) LMNativeAd *nativeAd;
@property(nonatomic, strong) UIView *expressAdView;
@property(nonatomic, strong) UIImage *placeholderImage;
@property(nonatomic, strong) LMSigmobVideoPlayerView *videoPlayerView; // 视频播放器视图引用

@end

@implementation LMSigmobNativeAdViewCreator

@synthesize adLogoView = _adLogoView;
@synthesize dislikeBtn = _dislikeBtn;
@synthesize imageView = _imageView;
@synthesize imageViewArray = _imageViewArray;
@synthesize mediaView = _mediaView;
@synthesize interactiveView = _interactiveView;

- (instancetype)initWithNativeAd:(LMNativeAd *)nativeAd {
    if (self = [super init]) {
        _nativeAd = nativeAd;
    }
    return self;
}

- (instancetype)initWithExpressAdView:(UIView *)expressAdView {
    if (self = [super init]) {
        _expressAdView = expressAdView;
    }
    return self;
}

- (void)setRootViewController:(UIViewController *)viewController {
    // LitemizeSDK 的 LMNativeAd 可能需要在其他地方设置 viewController
    // 这里先保留接口，如果 SDK 有相关方法可以在这里调用
    if (self.nativeAd) {
        // 如果 LMNativeAd 有 viewController 属性，可以在这里设置
        self.nativeAd.viewController = viewController;
    }
    // 模板广告的 viewController 通常已经在创建时设置
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    // LitemizeSDK 的 LMNativeAd 可能需要注册容器视图
    // 这里先保留接口，如果 SDK 有相关方法可以在这里调用
    if (self.nativeAd) {
        LMNativeAdViewMapping *mapping = [LMNativeAdViewMapping loadMapping:^(LMNativeAdViewMapping *_Nonnull mapping) {
            mapping.closeButton = self->_dislikeBtn;
            mapping.yaoyiyaoView = nil;
            mapping.viewsToBringToFront = clickableViews;
        }];
        [self.nativeAd registerAdView:containerView withMapping:mapping];
    }
}

- (void)refreshData {
    // 模板广告需要调用 render 方法
    if (self.expressAdView) {
        // 模板广告的渲染通常由 SDK 自动处理，这里可能需要调用相关方法
        // 如果 SDK 有 refresh 或 render 方法，可以在这里调用
    } else if (self.nativeAd) {
        // 自渲染广告的数据刷新
        // 如果 SDK 有 refresh 方法，可以在这里调用
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
}

#pragma mark - AWMMediatedNativeAdViewCreator Getters

- (UIImageView *)imageView {
    if (!_imageView && self.nativeAd && self.nativeAd.dataObject) {
        // 从 dataObject 中获取第一张图片
        NSArray<LMNativeAdMaterialObject *> *materialList = self.nativeAd.dataObject.materialList;
        if (materialList && materialList.count > 0) {
            // 查找第一张非视频的图片
            for (LMNativeAdMaterialObject *material in materialList) {
                if (!material.isVideo && material.materialUrl && material.materialUrl.length > 0) {
                    _imageView = [[UIImageView alloc] init];
                    // 这里可以使用图片加载库加载图片
                    // 例如：使用 SDWebImage 或其他图片加载库
                    // [_imageView sd_setImageWithURL:[NSURL URLWithString:material.materialUrl]
                    // placeholderImage:self.placeholderImage];
                    break;
                }
            }
        }
    }
    return _imageView;
}

- (NSArray<UIImageView *> *)imageViewArray {
    if (!_imageViewArray && self.nativeAd && self.nativeAd.dataObject) {
        // 检查是否为多图模式
        NSArray<LMNativeAdMaterialObject *> *materialList = self.nativeAd.dataObject.materialList;
        if (materialList && materialList.count > 1) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (LMNativeAdMaterialObject *material in materialList) {
                if (!material.isVideo && material.materialUrl && material.materialUrl.length > 0) {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    // 这里可以使用图片加载库加载图片
                    // [imageView sd_setImageWithURL:[NSURL URLWithString:material.materialUrl]
                    // placeholderImage:self.placeholderImage];
                    [arr addObject:imageView];
                }
            }
            if (arr.count > 0) {
                _imageViewArray = arr;
            }
        }
    }
    return _imageViewArray;
}

- (UIView *)mediaView {
    if (self.expressAdView) {
        // 模板广告的 mediaView 就是 expressAdView 本身
        return self.expressAdView;
    } else if (self.nativeAd && self.nativeAd.dataObject) {
        // 自渲染广告的 mediaView
        if (!_mediaView) {
            LMNativeAdDataObject *dataObject = self.nativeAd.dataObject;

            // 检查是否是视频广告
            if (dataObject.isVideo && dataObject.materialList && dataObject.materialList.count > 0) {
                // 查找第一个视频物料
                LMNativeAdMaterialObject *videoMaterial = nil;
                for (LMNativeAdMaterialObject *material in dataObject.materialList) {
                    if (material.isVideo && material.materialUrl && material.materialUrl.length > 0) {
                        videoMaterial = material;
                        break;
                    }
                }

                // 如果找到视频物料，创建视频播放器
                if (videoMaterial) {
                    NSString *videoURL = videoMaterial.materialUrl;
                    LMSigmobVideoPlayerView *videoPlayerView = [[LMSigmobVideoPlayerView alloc] initWithVideoURL:videoURL];

                    if (videoPlayerView) {
                        // 设置视频填充模式（居中缩放，上下留白）
                        videoPlayerView.videoGravity = AVLayerVideoGravityResizeAspectFill;

                        // 设置自动播放（广告通常需要自动播放）
                        videoPlayerView.shouldAutoPlay = YES;

                        _mediaView = videoPlayerView;
                        self.videoPlayerView = videoPlayerView; // 保存引用以便后续清理

                        LMSigmobLog(@"✅ LMSigmobNativeAdViewCreator: 创建视频播放器，URL: %@", videoURL);
                    } else {
                        LMSigmobLog(@"⚠️ LMSigmobNativeAdViewCreator: 创建视频播放器失败，URL: %@", videoURL);
                        // 创建失败时返回占位视图
                        _mediaView = [[UIView alloc] init];
                        _mediaView.backgroundColor = [UIColor clearColor];
                    }
                } else {
                    // 没有找到有效的视频物料，返回占位视图
                    LMSigmobLog(@"⚠️ LMSigmobNativeAdViewCreator: 未找到有效的视频物料");
                    _mediaView = [[UIView alloc] init];
                    _mediaView.backgroundColor = [UIColor clearColor];
                }
            } else {
                // 不是视频广告，返回占位视图
                _mediaView = [[UIView alloc] init];
                _mediaView.backgroundColor = [UIColor clearColor];
            }
        }
        return _mediaView;
    }
    return nil;
}

/// 创建并返回广告"关闭/不喜欢"按钮。
/// @discussion 需确保将返回的按钮添加到正确的广告视图之上，否则可能触发视图层级警告。
///             使用懒加载机制，确保每个 creator 实例只创建一次按钮，可以复用。
/// @return UIButton 实例，若原生广告对象无效则返回 nil。
- (UIButton *)dislikeBtn {
    // 如果已经创建过，直接返回（懒加载，只创建一次）
    if (_dislikeBtn) {
        return _dislikeBtn;
    }

    // 只有自渲染广告才需要创建 dislikeBtn
    if (!self.nativeAd || !self.nativeAd.dataObject) {
        return nil;
    }

    // 创建关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;

    // 使用系统 SF Symbols 图标（iOS 13+）或纯代码绘制关闭图标
    UIImage *closeImage = nil;
    if (@available(iOS 13.0, *)) {
        // 使用 SF Symbols 的 xmark.circle.fill 图标
        closeImage = [UIImage systemImageNamed:@"xmark.circle.fill"];
        if (closeImage) {
            // 设置图标颜色和大小
            closeImage = [closeImage imageWithTintColor:[UIColor colorWithWhite:0.0 alpha:0.6]
                                          renderingMode:UIImageRenderingModeAlwaysOriginal];
            // 调整图标大小
            CGSize iconSize = CGSizeMake(24, 24);
            UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
            [closeImage drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)];
            closeImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }

    // 如果没有系统图标，使用纯代码绘制一个简单的关闭图标
    if (!closeImage) {
        closeImage = [self _createCloseIconImage];
    }

    if (closeImage) {
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        // 配置图片显示模式：让图片填充整个按钮区域
        closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        // 移除默认的图片内边距
        closeButton.imageEdgeInsets = UIEdgeInsetsZero;
    } else {
        // 最后的备选方案：使用文字符号
        [closeButton setTitle:@"✕" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.6] forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    }
    // 保存到实例变量（懒加载，只创建一次）
    _dislikeBtn = closeButton;

    LMSigmobLog(@"✅ LMSigmobNativeAdViewCreator: 创建 dislikeBtn（懒加载）");

    return _dislikeBtn;
}

/// 使用 Core Graphics 绘制关闭图标
/// @return 绘制好的关闭图标 UIImage
- (UIImage *)_createCloseIconImage {
    CGSize size = CGSizeMake(24, 24);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 设置绘制参数
    CGFloat lineWidth = 2.0;
    CGFloat padding = 6.0;
    UIColor *iconColor = [UIColor colorWithWhite:0.0 alpha:0.6];

    // 绘制一个圆形背景（可选，用于更好的可见性）
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.8].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));

    // 绘制 X 形状
    CGContextSetStrokeColorWithColor(context, iconColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);

    // 绘制两条对角线
    CGContextMoveToPoint(context, padding, padding);
    CGContextAddLineToPoint(context, size.width - padding, size.height - padding);
    CGContextMoveToPoint(context, size.width - padding, padding);
    CGContextAddLineToPoint(context, padding, size.height - padding);
    CGContextStrokePath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)dealloc {
    // 清理视频播放器资源
    if (self.videoPlayerView) {
        [self.videoPlayerView cleanup];
        self.videoPlayerView = nil;
    }

    LMSigmobLog(@"LMSigmobNativeAdViewCreator dealloc");
}

@end
