//
//  LMTakuSplashAdapter.m
//  LitemizeSDK
//
//  Taku/AnyThink 开屏广告 Adapter 实现
//

#import "LMTakuSplashAdapter.h"

#import "LMTakuSplashCustomEvent.h"
#import <AnyThinkSplash/ATSplash.h>
#import <AnyThinkSplash/ATSplashCustomEvent.h>
#import <AnyThinkSplash/ATSplashManager.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMSplashAd.h>

@interface LMTakuSplashAdapter ()

/// CustomEvent 实例，用于处理广告回调
@property(nonatomic, strong, nullable) LMTakuSplashCustomEvent *customEvent;

/// 当前加载的开屏广告实例
@property(nonatomic, strong, nullable) LMSplashAd *splashAd;

@end

@implementation LMTakuSplashAdapter

#pragma mark - Class Loading

/// 类加载时调用（系统自动调用）
+ (void)load {
    NSLog(@"✅ [LMTakuSplashAdapter] LMTakuSplashAdapter 类已加载到系统");
}

#pragma mark - ATAdAdapter Protocol Implementation

/// Adapter 初始化方法
/// @param serverInfo 服务端配置的参数字典（包含 slot_id、app_id 等）
/// @param localInfo 本次加载传入的参数字典
- (instancetype)initWithNetworkCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self != nil) {
        // 初始化 完成
    }
    return self;
}

/// Adapter 发送加载请求，触发广告加载
/// @param serverInfo 服务端配置的参数字典
/// @param localInfo 本次加载传入的参数字典（包含超时时间、窗口等参数）
/// @param completion 加载完成回调（成功返回广告对象数组，失败返回错误）
- (void)loadADWithInfo:(NSDictionary *)serverInfo
             localInfo:(NSDictionary *)localInfo
            completion:(void (^)(NSArray *, NSError *))completion {
    // 获取广告位 ID（从 serverInfo 中获取）
    NSString *slotId = serverInfo[@"slot_id"];

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        // 创建 CustomEvent 实例
        self.customEvent = [[LMTakuSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        // 必须赋值 completion block
        self.customEvent.requestCompletionBlock = completion;
        self.customEvent.containerView = localInfo[kATSplashExtraContainerViewKey];

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeSplash];
        // 设置期望的图片尺寸（开屏广告通常是全屏）
        slot.imgSize = [UIScreen mainScreen].bounds.size;

        // 创建开屏广告实例
        self.splashAd = [[LMSplashAd alloc] initWithSlot:slot];
        // 设置代理为 CustomEvent，用于接收广告回调
        self.splashAd.delegate = self.customEvent;

        // 开始加载广告
        [self.splashAd loadAd];
    });
}

/// 检查广告源是否已经准备好
/// @param customObject 自定义广告平台的实例对象（这里是 LMSplashAd 实例）
/// @param info 服务端配置的参数字典
/// @return YES 表示广告已准备好，NO 表示未准备好
+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary *)info {
    NSLog(@"LMTakuSplashAdapter adReadyWithCustomObject: %@", customObject);
    // 转换成 LMSplashAd 实例
    LMSplashAd *splashAd = (LMSplashAd *)customObject;
    return splashAd.isLoaded;
}

/// 展示开屏广告
/// @param splash Taku SDK 传入的 ATSplash 对象
/// @param localInfo 本次加载传入的参数字典，包含 window 等参数
/// @param delegate 广告对象代理
+ (void)showSplash:(id)splash localInfo:(NSDictionary *)localInfo delegate:(id)delegate {
    // 从 ATSplash 对象中获取 customObject，直接就是 LMSplashAd 实例
    ATSplash *splashObj = (ATSplash *)splash;
    id customObject = splashObj.customObject;

    // customObject 就是 LMSplashAd 实例
    LMSplashAd *splashAd = nil;
    if ([customObject isKindOfClass:[LMSplashAd class]]) {
        splashAd = (LMSplashAd *)customObject;
    } else {
        NSLog(@"⚠️ showSplash: customObject 不是 LMSplashAd 类型，customObject=%@", customObject);
        return;
    }

    // 获取 CustomEvent（通过 ATSplash 的 customEvent 属性）
    LMTakuSplashCustomEvent *customEvent = nil;
    if ([splashObj.customEvent isKindOfClass:[LMTakuSplashCustomEvent class]]) {
        customEvent = (LMTakuSplashCustomEvent *)splashObj.customEvent;
    }

    // 获取 window（从 localInfo 中获取）
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    if (!window) {
        NSLog(@"⚠️ showSplash: window 为空");
        return;
    }

    // 获取背景图片视图（可选）
    UIImageView *backgroundImageView = localInfo[kATSplashExtraBackgroundImageViewKey];

    // 获取 containerView（如果有）
    UIView *containerView = localInfo[kATSplashExtraContainerViewKey];

    // 更新 CustomEvent 的 containerView 和 backgroundImageView（如果存在）
    if (customEvent) {
        if (containerView) {
            customEvent.containerView = containerView;
        }
        // 注意：backgroundImageView 可能需要保存到 CustomEvent 中，但目前 CustomEvent 没有这个属性
        // 如果需要，可以在 CustomEvent 中添加 backgroundImageView 属性
    }

    // 展示广告（LMSplashAd 内部会处理 containerView 的添加）
    [splashAd showInWindow:window];

    // 如果有背景图片视图，需要添加到 window 上（在最底层）
    if (backgroundImageView && backgroundImageView.superview != window) {
        [window addSubview:backgroundImageView];
        [window sendSubviewToBack:backgroundImageView];
    }
}

@end
