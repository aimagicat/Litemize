//
//  LMTakuNativeAdapter.m
//  LitemizeSDK
//
//  Taku/AnyThink 原生广告 Adapter 实现
//

#import "LMTakuNativeAdapter.h"

#import "LMTakuNativeCustomEvent.h"
#import "LMTakuNativeRenderer.h"
#import <AnyThinkNative/AnyThinkNative.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

@interface LMTakuNativeAdapter ()

/// CustomEvent 实例，用于处理广告回调
@property(nonatomic, strong, nullable) LMTakuNativeCustomEvent *customEvent;

/// 当前加载的原生广告实例（自渲染）
@property(nonatomic, strong, nullable) LMNativeAd *nativeAd;

/// 当前加载的原生广告实例（模板渲染）
@property(nonatomic, strong, nullable) LMNativeExpressAd *nativeExpressAd;

@end

@implementation LMTakuNativeAdapter

#pragma mark - Class Loading

/// 类加载时调用（系统自动调用）
+ (void)load {
    NSLog(@"✅ [LMTakuNativeAdapter] LMTakuNativeAdapter 类已加载到系统");
}

#pragma mark - ATAdAdapter Protocol Implementation

/// Adapter 初始化方法
/// @param serverInfo 服务端配置的参数字典（包含 slot_id、app_id 等）
/// @param localInfo 本次加载传入的参数字典
- (instancetype)initWithNetworkCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self != nil) {
        // 初始化完成
        NSLog(@"LMTakuNativeAdapter initWithNetworkCustomInfo: %@", serverInfo);
        NSLog(@"LMTakuNativeAdapter localInfo: %@", localInfo);
    }
    return self;
}

/// Adapter 发送加载请求，触发广告加载
/// @param serverInfo 服务端配置的参数字典
/// @param localInfo 本次加载传入的参数字典（包含 viewController 等参数）
/// @param completion 加载完成回调（成功返回广告对象数组，失败返回错误）
- (void)loadADWithInfo:(NSDictionary *)serverInfo
             localInfo:(NSDictionary *)localInfo
            completion:(void (^)(NSArray *, NSError *))completion {
    // 获取广告位 ID（从 serverInfo 中获取）
    NSString *slotId = serverInfo[@"slot_id"];

    // 获取广告渲染方式（从 serverInfo 中获取，默认为自渲染）
    NSInteger layoutType = [serverInfo[@"unit_type"] integerValue]; // 渲染方式 1:模板渲染 0:自渲染

    // 获取广告尺寸（从 localInfo 中获取，默认为 320x180）
    CGSize adSize = CGSizeMake(320.0f, 180.0f);
    id sizeValue = localInfo[kATExtraNativeImageSizeKey];
    if (sizeValue != nil) {
        if ([sizeValue respondsToSelector:@selector(CGSizeValue)]) {
            adSize = [sizeValue CGSizeValue];
        } else if ([sizeValue isKindOfClass:[NSValue class]]) {
            adSize = [sizeValue CGSizeValue];
        }
    }

    // 验证 slotId 是否有效
    if (!slotId || slotId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LMTakuNativeAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"广告位ID无效"}];
        completion(nil, error);
        return;
    }

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        // 创建 CustomEvent 实例
        self.customEvent = [[LMTakuNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;

        // 根据渲染方式选择不同的广告实例
        if (layoutType == 1) {
            // 模板渲染
            [self loadNativeExpressAdWithSlotId:slotId adSize:adSize localInfo:localInfo completion:completion];
        } else {
            // 自渲染
            [self loadNativeAdWithSlotId:slotId adSize:adSize localInfo:localInfo completion:completion];
        }
    });
}

/// 返回自定义 Renderer 类
/// @return Renderer 类
+ (Class)rendererClass {
    return [LMTakuNativeRenderer class];
}

#pragma mark - Private Methods

/// 加载原生模板广告
/// @param slotId 广告位ID
/// @param adSize 广告尺寸
/// @param localInfo 本地参数信息
/// @param completion 完成回调
- (void)loadNativeExpressAdWithSlotId:(NSString *)slotId
                               adSize:(CGSize)adSize
                            localInfo:(NSDictionary *)localInfo
                           completion:(void (^)(NSArray *, NSError *))completion {
    // 创建广告位配置
    LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeNativeExpress];
    slot.imgSize = adSize;

    // 创建原生模板广告实例
    self.nativeExpressAd = [[LMNativeExpressAd alloc] initWithSlot:slot];
    if (!self.nativeExpressAd) {
        NSError *error = [NSError errorWithDomain:@"LMTakuNativeAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"创建原生模板广告实例失败"}];
        completion(nil, error);
        return;
    }

    // 配置广告实例
    [self configureAdInstance:self.nativeExpressAd withLocalInfo:localInfo];

    // 保存引用到 customEvent
    self.customEvent.nativeExpressAd = self.nativeExpressAd;

    // 开始加载广告
    [self.nativeExpressAd loadAd];
}

/// 加载原生自渲染广告
/// @param slotId 广告位ID
/// @param adSize 广告尺寸
/// @param localInfo 本地参数信息
/// @param completion 完成回调
- (void)loadNativeAdWithSlotId:(NSString *)slotId
                        adSize:(CGSize)adSize
                     localInfo:(NSDictionary *)localInfo
                    completion:(void (^)(NSArray *, NSError *))completion {
    // 创建广告位配置
    LMAdSlot *slot = [LMAdSlot slotWithId:slotId type:LMAdSlotTypeNative];
    slot.imgSize = adSize;

    // 创建原生广告实例
    self.nativeAd = [[LMNativeAd alloc] initWithSlot:slot];
    if (!self.nativeAd) {
        NSError *error = [NSError errorWithDomain:@"LMTakuNativeAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"创建原生广告实例失败"}];
        completion(nil, error);
        return;
    }

    // 配置广告实例
    [self configureAdInstance:self.nativeAd withLocalInfo:localInfo];

    // 保存引用到 customEvent
    self.customEvent.nativeAd = self.nativeAd;

    // 开始加载广告
    [self.nativeAd loadAd];
}

/// 配置广告实例的通用属性（delegate 和 viewController）
/// @param adInstance 广告实例（LMNativeAd 或 LMNativeExpressAd）
/// @param localInfo 本地参数信息
- (void)configureAdInstance:(id)adInstance withLocalInfo:(NSDictionary *)localInfo {
    // 设置代理为 CustomEvent，用于接收广告回调
    if ([adInstance respondsToSelector:@selector(setDelegate:)]) {
        [adInstance setDelegate:self.customEvent];
    }

    // 设置 viewController（从 localInfo 中获取）
    UIViewController *viewController = localInfo[kATAdLoadingExtraShowViewControllerKey];
    if (viewController && [adInstance respondsToSelector:@selector(setViewController:)]) {
        [adInstance setViewController:viewController];
    }
}

@end
