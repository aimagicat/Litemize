//
//  LMTakuRewardedVideoAdapter.m
//  LitemizeSDK
//
//  Taku/AnyThink 激励视频广告 Adapter 实现
//

#import "LMTakuRewardedVideoAdapter.h"

#import "LMTakuRewardedVideoCustomEvent.h"
#import <AnyThinkRewardedVideo/ATRewardedVideo.h>
#import <AnyThinkRewardedVideo/ATRewardedVideoCustomEvent.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMRewardedVideoAd.h>

@interface LMTakuRewardedVideoAdapter ()

/// CustomEvent 实例，用于处理广告回调
@property(nonatomic, strong, nullable) LMTakuRewardedVideoCustomEvent *customEvent;

/// 当前加载的激励视频广告实例
@property(nonatomic, strong, nullable) LMRewardedVideoAd *rewardedVideoAd;

@end

@implementation LMTakuRewardedVideoAdapter

#pragma mark - Class Loading

/// 类加载时调用（系统自动调用）
+ (void)load {
    NSLog(@"✅ [LMTakuRewardedVideoAdapter] LMTakuRewardedVideoAdapter 类已加载到系统");
}

#pragma mark - ATAdAdapter Protocol Implementation

/// Adapter 初始化方法
/// @param serverInfo 服务端配置的参数字典（包含 slot_id、app_id 等）
/// @param localInfo 本次加载传入的参数字典
- (instancetype)initWithNetworkCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self != nil) {
        // 初始化完成
        NSLog(@"LMTakuRewardedVideoAdapter initWithNetworkCustomInfo: %@", serverInfo);
        NSLog(@"LMTakuRewardedVideoAdapter localInfo: %@", localInfo);
        // 尝试获取user_id，考虑不存在的情况，避免崩溃
        NSString *userId = localInfo[@"userID"] ?: @"";
        if (userId && userId.length > 0) {
            [LMAdSDK config:^(LMAdSDKConfigBuilder *builder) {
                builder.userId = userId;
            }];
        }
    }
    return self;
}

/// Adapter 发送加载请求，触发广告加载
/// @param serverInfo 服务端配置的参数字典
/// @param localInfo 本次加载传入的参数字典（包含用户ID等参数）
/// @param completion 加载完成回调（成功返回广告对象数组，失败返回错误）
- (void)loadADWithInfo:(NSDictionary *)serverInfo
             localInfo:(NSDictionary *)localInfo
            completion:(void (^)(NSArray *, NSError *))completion {
    // 获取广告位 ID（从 serverInfo 中获取）
    NSString *slotId = serverInfo[@"slot_id"];

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        // 创建 CustomEvent 实例
        self.customEvent = [[LMTakuRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        // 必须赋值 completion block
        self.customEvent.requestCompletionBlock = completion;

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeRewardedVideo];

        // 创建激励视频广告实例
        self.rewardedVideoAd = [[LMRewardedVideoAd alloc] initWithSlot:slot];
        // 设置代理为 CustomEvent，用于接收广告回调
        self.rewardedVideoAd.delegate = self.customEvent;

        // 开始加载广告
        [self.rewardedVideoAd loadAd];
    });
}

/// 检查广告源是否已经准备好
/// @param customObject 自定义广告平台的实例对象（这里是 LMRewardedVideoAd 实例）
/// @param info 服务端配置的参数字典
/// @return YES 表示广告已准备好，NO 表示未准备好
+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary *)info {
    NSLog(@"LMTakuRewardedVideoAdapter adReadyWithCustomObject: %@", customObject);
    // 转换成 LMRewardedVideoAd 实例
    if ([customObject isKindOfClass:[LMRewardedVideoAd class]]) {
        LMRewardedVideoAd *rewardedVideoAd = (LMRewardedVideoAd *)customObject;
        return rewardedVideoAd.isLoaded;
    }
    return NO;
}

/// 展示激励视频广告
/// @param rewardedVideo Taku SDK 传入的 ATRewardedVideo 对象
/// @param viewController 当前视图控制器
/// @param delegate 广告对象代理
+ (void)showRewardedVideo:(ATRewardedVideo *)rewardedVideo
         inViewController:(UIViewController *)viewController
                 delegate:(id)delegate {
    // 从 ATRewardedVideo 对象中获取 customObject，直接就是 LMRewardedVideoAd 实例
    id customObject = rewardedVideo.customObject;

    // customObject 就是 LMRewardedVideoAd 实例
    LMRewardedVideoAd *rewardedVideoAd = nil;
    if ([customObject isKindOfClass:[LMRewardedVideoAd class]]) {
        rewardedVideoAd = (LMRewardedVideoAd *)customObject;
    } else {
        NSLog(@"⚠️ showRewardedVideo: customObject 不是 LMRewardedVideoAd 类型，customObject=%@", customObject);
        return;
    }

    // 获取 CustomEvent（通过 ATRewardedVideo 的 customEvent 属性）
    LMTakuRewardedVideoCustomEvent *customEvent = nil;
    if ([rewardedVideo.customEvent isKindOfClass:[LMTakuRewardedVideoCustomEvent class]]) {
        customEvent = (LMTakuRewardedVideoCustomEvent *)rewardedVideo.customEvent;
    }

    // 更新 CustomEvent 的 delegate
    if (customEvent) {
        customEvent.delegate = delegate;
    }

    // 展示广告
    [rewardedVideoAd showFromViewController:viewController];
}

@end
