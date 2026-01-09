//
//  LMTakuBannerAdapter.m
//  LitemizeSDK
//
//  Taku/AnyThink Banner 横幅广告 Adapter 实现
//

#import "LMTakuBannerAdapter.h"

#import "LMTakuBannerCustomEvent.h"
#import <AnyThinkBanner/ATBanner.h>
#import <AnyThinkBanner/ATBannerCustomEvent.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMBannerAd.h>

@interface LMTakuBannerAdapter ()

/// CustomEvent 实例，用于处理广告回调
@property(nonatomic, strong, nullable) LMTakuBannerCustomEvent *customEvent;

/// 当前加载的 Banner 广告实例
@property(nonatomic, strong, nullable) LMBannerAd *bannerAd;

@end

@implementation LMTakuBannerAdapter

#pragma mark - Class Loading

/// 类加载时调用（系统自动调用）
+ (void)load {
    NSLog(@"✅ [LMTakuBannerAdapter] LMTakuBannerAdapter 类已加载到系统");
}

#pragma mark - ATAdAdapter Protocol Implementation

/// Adapter 初始化方法
/// @param serverInfo 服务端配置的参数字典（包含 slot_id、app_id 等）
/// @param localInfo 本次加载传入的参数字典
- (instancetype)initWithNetworkCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self != nil) {
        // 初始化完成
        NSLog(@"LMTakuBannerAdapter initWithNetworkCustomInfo: %@", serverInfo);
        NSLog(@"LMTakuBannerAdapter localInfo: %@", localInfo);
    }
    return self;
}

/// Adapter 发送加载请求，触发广告加载
/// @param serverInfo 服务端配置的参数字典
/// @param localInfo 本次加载传入的参数字典（包含广告尺寸等参数）
/// @param completion 加载完成回调（成功返回广告对象数组，失败返回错误）
- (void)loadADWithInfo:(NSDictionary *)serverInfo
             localInfo:(NSDictionary *)localInfo
            completion:(void (^)(NSArray *, NSError *))completion {
    // 获取广告位 ID（从 serverInfo 中获取）
    NSString *slotId = serverInfo[@"slot_id"];

    // 获取广告尺寸（从 localInfo 中获取，默认为 320x50）
    // 注意：AnyThink SDK 可能使用 kATAdLoadingExtraBannerAdSizeKey 作为 key
    CGSize adSize = CGSizeMake(320.0f, 50.0f);
    // 尝试从 localInfo 中获取广告尺寸
    id sizeValue = localInfo[@"kATAdLoadingExtraBannerAdSizeKey"];
    if (sizeValue == nil) {
        // 如果没有找到，尝试其他可能的 key
        sizeValue = localInfo[@"banner_size"];
    }
    if (sizeValue != nil) {
        if ([sizeValue respondsToSelector:@selector(CGSizeValue)]) {
            adSize = [sizeValue CGSizeValue];
        } else if ([sizeValue isKindOfClass:[NSValue class]]) {
            adSize = [sizeValue CGSizeValue];
        }
    }

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        // 先释放上一个 banner 实例（如果存在）
        if (self.bannerAd) {
            NSLog(@"LMTakuBannerAdapter 释放上一个 Banner 广告实例");
            // 先移除代理，避免回调
            self.bannerAd.delegate = nil;
            // 调用 close 方法清理资源（会触发关闭回调并清理视图）
            [self.bannerAd close];
            self.bannerAd = nil;
        }

        // 创建 CustomEvent 实例
        self.customEvent = [[LMTakuBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        // 必须赋值 completion block
        self.customEvent.requestCompletionBlock = completion;

        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeBanner];
        // 设置图片尺寸（Banner 广告尺寸）
        slot.imgSize = adSize;

        // 创建 Banner 广告实例
        self.bannerAd = [[LMBannerAd alloc] initWithSlot:slot];
        // 设置代理为 CustomEvent，用于接收广告回调
        self.bannerAd.delegate = self.customEvent;

        // 开始加载广告
        [self.bannerAd loadAd];
    });
}

/// 检查广告源是否已经准备好
/// @param customObject 自定义广告平台的实例对象（这里是 LMBannerAd 实例）
/// @param info 服务端配置的参数字典
/// @return YES 表示广告已准备好，NO 表示未准备好
+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary *)info {
    NSLog(@"LMTakuBannerAdapter adReadyWithCustomObject: %@", customObject);
    // 转换成 LMBannerAd 实例
    if ([customObject isKindOfClass:[LMBannerAd class]]) {
        LMBannerAd *bannerAd = (LMBannerAd *)customObject;
        return bannerAd.isAdValid;
    }
    return NO;
}

/// 展示 Banner 广告
/// @param banner Taku SDK 传入的 ATBanner 对象
/// @param view Taku SDK 内部定义的 BannerView 容器
/// @param viewController 外部通过 presentingViewController 属性传入的视图控制器
+ (void)showBanner:(ATBanner *)banner inView:(UIView *)view presentingViewController:(UIViewController *)viewController {
    NSLog(@"LMTakuBannerAdapter showBanner: %@, customObject: %@", banner, banner.bannerView);

    // 从 ATBanner 对象中获取 customObject
    // 根据文档，customObject 应该是传入 trackBannerAdLoaded 的 bannerView 对象
    id customObject = banner.bannerView;

    if (!customObject) {
        NSLog(@"❌ showBanner: customObject 为 nil，banner 可能已被释放");
        return;
    }

    // 从 customObject 获取 LMBannerAd 实例
    LMBannerAd *bannerAd = nil;

    // 情况2：customObject 直接就是 LMBannerAd（兼容处理）
    if (!bannerAd && [customObject isKindOfClass:[LMBannerAd class]]) {
        bannerAd = (LMBannerAd *)customObject;
        NSLog(@"✅ showBanner: customObject 直接是 LMBannerAd 实例，isAdValid: %@", @(bannerAd.isAdValid));
    }

    if (!bannerAd) {
        NSLog(@"❌ showBanner: 无法从 customObject 获取 LMBannerAd，customObject=%@, class=%@", customObject,
              [customObject class]);
        return;
    }

    // 检查广告是否已加载
    if (!bannerAd.isAdValid) {
        NSLog(@"⚠️ showBanner: 广告未加载，无法展示");
        return;
    }

    // 获取 CustomEvent（通过 ATBanner 的 customEvent 属性）
    LMTakuBannerCustomEvent *customEvent = nil;
    if ([banner.customEvent isKindOfClass:[LMTakuBannerCustomEvent class]]) {
        customEvent = (LMTakuBannerCustomEvent *)banner.customEvent;
        NSLog(@"✅ showBanner: 获取到 CustomEvent 实例");
    } else {
        NSLog(@"⚠️ showBanner: 无法获取 CustomEvent，customEvent=%@", banner.customEvent);
    }
}

@end
