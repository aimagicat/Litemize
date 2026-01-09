//
//  LMTakuLoopVideoPlayerView.m
//  LitemizeSDK
//
//  Taku 循环播放视频播放器视图实现
//

#import "LMTakuLoopVideoPlayerView.h"

@interface LMTakuLoopVideoPlayerView ()

/// 播放器（内部可写）
@property(nonatomic, strong, nullable, readwrite) AVPlayer *player;

/// 播放器项
@property(nonatomic, strong, nullable) AVPlayerItem *playerItem;

/// 是否正在播放（内部可写）
@property(nonatomic, assign, readwrite) BOOL isPlaying;

@end

@implementation LMTakuLoopVideoPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (nullable instancetype)initWithVideoURL:(NSString *)videoURL {
    if (!videoURL || videoURL.length == 0) {
        NSLog(@"⚠️ LMTakuLoopVideoPlayerView: 视频 URL 为空");
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
        NSLog(@"⚠️ LMTakuLoopVideoPlayerView: 视频 URL 无效: %@", videoURL);
        return nil;
    }

    self = [super init];
    if (self) {
        _videoGravity = AVLayerVideoGravityResizeAspectFill;
        _isPlaying = NO;
        _shouldAutoPlay = YES;
        _muted = NO;

        // 创建播放器
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

        // 设置 playerLayer
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
        playerLayer.player = player;
        playerLayer.videoGravity = _videoGravity;

        // 设置静音
        player.muted = _muted;

        // 设置背景色为黑色（视频加载前的默认背景）
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        // 保存引用
        _player = player;
        _playerItem = playerItem;

        // 监听播放器状态和播放结束
        [self _setupPlayerObservers];

        NSLog(@"✅ LMTakuLoopVideoPlayerView: 视频播放器已创建，URL: %@", videoURL);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    // 使用 Auto Layout 时，系统可能会调用 initWithFrame:
    self = [super initWithFrame:frame];
    if (self) {
        _videoGravity = AVLayerVideoGravityResizeAspectFill;
        _isPlaying = NO;
        _shouldAutoPlay = YES;
        _muted = NO;

        // 设置 playerLayer（即使 player 为 nil）
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
        playerLayer.videoGravity = _videoGravity;

        // 设置背景色为黑色
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        NSLog(@"⚠️ LMTakuLoopVideoPlayerView: 使用 initWithFrame: 初始化，请使用 initWithVideoURL: 创建播放器");
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

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    if (self.player) {
        self.player.muted = muted;
    }
}

#pragma mark - Public Methods

- (void)play {
    if (!self.player) {
        return;
    }

    [self.player play];
    self.isPlaying = YES;
}

- (void)pause {
    if (self.player) {
        [self.player pause];
        self.isPlaying = NO;
    }
}

- (void)stop {
    if (self.player) {
        [self.player pause];
        [self.player seekToTime:kCMTimeZero];
        self.isPlaying = NO;
    }
}

- (CGFloat)currentPlayTime {
    if (!self.player || !self.playerItem) {
        return 0;
    }

    // 获取当前播放时间（CMTime）
    CMTime currentTime = self.player.currentTime;
    if (CMTIME_IS_INVALID(currentTime) || CMTIME_IS_INDEFINITE(currentTime)) {
        return 0;
    }

    // 转换为毫秒
    CGFloat seconds = CMTimeGetSeconds(currentTime);
    return seconds * 1000.0;
}

- (CGFloat)duration {
    if (!self.playerItem) {
        return 0;
    }

    // 获取视频总时长（CMTime）
    CMTime duration = self.playerItem.duration;
    if (CMTIME_IS_INVALID(duration) || CMTIME_IS_INDEFINITE(duration)) {
        return 0;
    }

    // 转换为毫秒
    CGFloat seconds = CMTimeGetSeconds(duration);
    return seconds * 1000.0;
}

- (void)cleanup {
    // 移除观察者
    [self _removePlayerObservers];

    // 停止播放
    [self stop];

    // 清理资源
    self.player = nil;
    self.playerItem = nil;
    self.isPlaying = NO;

    NSLog(@"✅ LMTakuLoopVideoPlayerView: 视频播放器资源已清理");
}

#pragma mark - Private Methods

/// 设置播放器观察者
- (void)_setupPlayerObservers {
    if (!self.playerItem) {
        return;
    }

    // 监听播放器状态变化
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    // 监听播放结束通知（用于循环播放）
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
            // 忽略重复移除观察者的异常
            NSLog(@"⚠️ LMTakuLoopVideoPlayerView: 移除观察者异常: %@", exception);
        }
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 播放结束通知（实现循环播放）
- (void)_playerItemDidPlayToEndTime:(NSNotification *)notification {
    self.isPlaying = NO;

    // 循环播放：将播放进度重置到开始位置，然后重新播放
    if (self.player && self.playerItem) {
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:kCMTimeZero
              completionHandler:^(BOOL finished) {
                  __strong typeof(weakSelf) strongSelf = weakSelf;
                  if (finished && strongSelf && strongSelf.player) {
                      [strongSelf.player play];
                      strongSelf.isPlaying = YES;
                  }
              }];
    }
}

/// KVO 观察者回调
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        [self _checkPlayerStatus];
    }
}

/// 检查播放器状态
- (void)_checkPlayerStatus {
    if (!self.playerItem) {
        return;
    }

    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self _tryAutoPlay];
    } else if (self.playerItem.status == AVPlayerItemStatusFailed) {
        NSLog(@"❌ LMTakuLoopVideoPlayerView: 视频播放失败: %@", self.playerItem.error.localizedDescription ?: @"未知错误");
    }
}

/// 尝试自动播放（如果条件满足）
- (void)_tryAutoPlay {
    if (!self.shouldAutoPlay || !self.superview || self.isPlaying) {
        return;
    }

    if (self.playerItem && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && strongSelf.superview && !strongSelf.isPlaying) {
                [strongSelf play];
            }
        });
    }
}

// 当视图被添加到父视图时，如果已经准备就绪且应该自动播放，则触发播放
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self _tryAutoPlay];
}

- (void)dealloc {
    [self cleanup];
    NSLog(@"✅ LMTakuLoopVideoPlayerView: 视频播放器视图已释放");
}

@end
