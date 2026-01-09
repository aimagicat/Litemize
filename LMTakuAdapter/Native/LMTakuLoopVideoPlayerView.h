//
//  LMTakuLoopVideoPlayerView.h
//  LitemizeSDK
//
//  Taku 循环播放视频播放器视图
//  支持循环播放，使用视频地址初始化
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 循环播放视频播放器视图
/// - Note: 基于 AVPlayer 实现，支持循环播放和自动布局
@interface LMTakuLoopVideoPlayerView : UIView

/// 视频播放器（只读）
@property(nonatomic, strong, readonly, nullable) AVPlayer *player;

/// 视频播放器层（只读）
@property(nonatomic, strong, readonly, nullable) AVPlayerLayer *playerLayer;

/// 视频填充模式（默认：AVLayerVideoGravityResizeAspectFill）
@property(nonatomic, assign) AVLayerVideoGravity videoGravity;

/// 是否正在播放（只读）
@property(nonatomic, assign, readonly) BOOL isPlaying;

/// 是否自动播放（默认：YES）
@property(nonatomic, assign) BOOL shouldAutoPlay;

/// 是否静音（默认：NO）
@property(nonatomic, assign) BOOL muted;

/// 初始化方法（通过视频 URL 创建）
/// - Parameter videoURL: 视频 URL 字符串（支持 http/https 和本地文件路径）
- (nullable instancetype)initWithVideoURL:(NSString *)videoURL;

/// 播放视频
- (void)play;

/// 暂停视频
- (void)pause;

/// 停止视频（暂停并重置到开始位置）
- (void)stop;

/// 获取当前播放时长（单位：毫秒）
- (CGFloat)currentPlayTime;

/// 获取视频总时长（单位：毫秒）
- (CGFloat)duration;

/// 清理资源
- (void)cleanup;

@end

NS_ASSUME_NONNULL_END
