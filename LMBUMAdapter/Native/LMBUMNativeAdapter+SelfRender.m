//
//  LMBUMNativeAdapter+SelfRender.m
//  LitemizeSDK
//
//  穿山甲（BUM）信息流自渲染广告处理分类实现
//

#import "LMBUMNativeAdData.h"
#import "LMBUMNativeAdViewCreator.h"
#import "LMBUMNativeAdapter+SelfRender.h"
#import <BUAdSDK/BUAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

/// 分类需要访问主类的私有属性和方法，在此重新声明
@interface LMBUMNativeAdapter ()

/// 当前加载的非模板广告实例列表（一个请求可能返回多个广告）
@property(nonatomic, strong) NSMutableArray<LMNativeAd *> *nativeAds;
/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;
/// 当前请求的广告数量
@property(nonatomic, assign) NSInteger requestedAdCount;
/// 竞价类型（用于判断是否需要传入 ECPM）
@property(nonatomic, assign) NSInteger biddingType;

/// 通知加载失败（私有方法）
- (void)_notifyLoadFailed:(NSError *)error;

@end

@implementation LMBUMNativeAdapter (SelfRender)

#pragma mark - 自渲染广告加载

- (void)selfRender_loadAdsWithSlotID:(NSString *)slotID count:(NSInteger)count size:(CGSize)size imageSize:(CGSize)imageSize {
    NSLog(@"LMBUMNativeAdapter[SelfRender] 开始加载自渲染广告，slotID: %@, count: %ld", slotID, (long)count);

    __weak typeof(self) ws = self;
    NSMutableArray<LMNativeAd *> *loadingAds = [NSMutableArray arrayWithCapacity:count];

    // 创建多个广告实例（一个请求可能返回多个广告）
    for (NSInteger i = 0; i < count; i++) {
        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotID type:LMAdSlotTypeNative];
        // 设置期望的图片尺寸
        if (imageSize.width > 0 && imageSize.height > 0) {
            slot.imgSize = imageSize;
        }

        // 创建自渲染广告实例
        LMNativeAd *nativeAd = [[LMNativeAd alloc] initWithSlot:slot];
        if (!nativeAd) {
            NSLog(@"⚠️ LMBUMNativeAdapter[SelfRender] 创建 LMNativeAd 失败");
            continue;
        }

        // 设置代理
        nativeAd.delegate = self;
        // 设置 viewController（从 bridge 获取）
        if (self.bridge && [self.bridge respondsToSelector:@selector(viewControllerForPresentingModalView)]) {
            nativeAd.viewController = self.bridge.viewControllerForPresentingModalView;
        }

        [loadingAds addObject:nativeAd];
        [self.nativeAds addObject:nativeAd];

        // 开始加载广告
        [nativeAd loadAd];
    }

    // 如果没有任何广告实例创建成功，通知失败
    if (loadingAds.count == 0) {
        NSError *error = [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"创建自渲染广告实例失败"}];
        [self _notifyLoadFailed:error];
    }
}

#pragma mark - 自渲染广告加载成功检查

- (void)selfRender_checkAndNotifyLoadSuccess {
    if (self.hasCalledLoadSuccess) {
        return;
    }

    // 收集所有已加载的广告
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.nativeAds.count];
    NSMutableArray<NSDictionary *> *exts = [NSMutableArray arrayWithCapacity:self.nativeAds.count];

    for (LMNativeAd *ad in self.nativeAds) {
        if (!ad.dataObject) {
            continue;
        }

        // 创建 BUMMediatedNativeAd 对象
        Class BUMMediatedNativeAdClass = NSClassFromString(@"BUMMediatedNativeAd");
        if (!BUMMediatedNativeAdClass) {
            continue;
        }

        BUMMediatedNativeAd *mediatedAd = [[BUMMediatedNativeAdClass alloc] init];
        if (!mediatedAd) {
            continue;
        }

        // 创建 ViewCreator 和 Data
        LMBUMNativeAdViewCreator *viewCreator = [[LMBUMNativeAdViewCreator alloc] initWithNativeAd:ad viewDelegate:self];
        LMBUMNativeAdData *adData = [[LMBUMNativeAdData alloc] initWithDataObject:ad.dataObject];

        // 设置属性
        mediatedAd.viewCreator = viewCreator;
        mediatedAd.originMediatedNativeAd = ad.dataObject;
        mediatedAd.view = [[UIView alloc] init];
        mediatedAd.data = adData;

        [array addObject:mediatedAd];

        // 获取 ECPM（用于客户端竞价）
        NSMutableDictionary *ext = [NSMutableDictionary dictionary];
        NSString *cpm = nil;
        if ([ad respondsToSelector:@selector(getEcpm)]) {
            cpm = [ad getEcpm];
        }
        if (cpm && cpm.length > 0) {
            [ext setValue:cpm forKey:BUMMediaAdLoadingExtECPM];
        } else {
            [ext setValue:@"0" forKey:BUMMediaAdLoadingExtECPM];
        }
        [exts addObject:ext];
    }

    // 如果所有请求的广告都已加载完成，通知成功
    if (array.count >= self.requestedAdCount && array.count > 0) {
        self.hasCalledLoadSuccess = YES;

        // 判断是否为客户端竞价，如果不是则不需要 ECPM
        NSArray *finalExts = @[];
        if (self.biddingType == BUMBiddingTypeClient) {
            finalExts = [exts copy];
        }

        // 通知融合 SDK 广告加载成功
        if (self.bridge && [self.bridge respondsToSelector:@selector(nativeAd:didLoadWithNativeAds:exts:)]) {
            [self.bridge nativeAd:self didLoadWithNativeAds:array exts:finalExts];
        }
    }
}

#pragma mark - 自渲染广告回调处理

- (void)selfRender_handleAdLoaded:(LMNativeAdDataObject *)dataObject nativeAd:(LMNativeAd *)nativeAd {
    NSLog(@"LMBUMNativeAdapter[SelfRender] 广告加载成功，dataObject: %@, nativeAd: %@", dataObject, nativeAd);

    if (!dataObject || !nativeAd) {
        NSLog(@"⚠️ LMBUMNativeAdapter[SelfRender] handleAdLoaded: dataObject 或 nativeAd 为空");
        return;
    }

    // 检查并通知加载成功
    [self selfRender_checkAndNotifyLoadSuccess];
}

- (void)selfRender_handleAdLoadFailed:(LMNativeAd *)nativeAd error:(NSError *)error description:(NSDictionary *)description {
    NSLog(@"LMBUMNativeAdapter[SelfRender] 广告加载失败，nativeAd: %@, error: %@", nativeAd, error);

    // 检查是否所有广告都加载失败
    BOOL allFailed = YES;
    for (LMNativeAd *ad in self.nativeAds) {
        if (ad.dataObject) {
            allFailed = NO;
            break;
        }
    }

    // 如果所有广告都加载失败，且没有成功加载的广告，才通知失败
    if (allFailed && !self.hasCalledLoadSuccess) {
        // 再等待一小段时间，确保所有回调都处理完成
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 再次检查
            BOOL stillAllFailed = YES;
            for (LMNativeAd *ad in self.nativeAds) {
                if (ad.dataObject) {
                    stillAllFailed = NO;
                    break;
                }
            }
            if (stillAllFailed && !self.hasCalledLoadSuccess) {
                [self _notifyLoadFailed:error
                          ?: [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                                 code:-4
                                             userInfo:@{NSLocalizedDescriptionKey : @"所有自渲染广告加载失败"}]];
            }
        });
    }
}

- (void)selfRender_handleAdWillExpose:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMBUMNativeAdapter[SelfRender] 广告即将曝光，nativeAd: %@, adView: %@", nativeAd, adView);

    // 通知融合 SDK 广告曝光
    if (self.bridge && [self.bridge respondsToSelector:@selector(nativeAd:didVisibleWithMediatedNativeAd:)]) {
        // native广告请传递原始数据（即BUMMediatedNativeAd.originMediatedNativeAd）
        [self.bridge nativeAd:self didVisibleWithMediatedNativeAd:nativeAd.dataObject];
    }
}

- (void)selfRender_handleAdDidClick:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMBUMNativeAdapter[SelfRender] 广告被点击，nativeAd: %@, adView: %@", nativeAd, adView);

    // 通知融合 SDK 广告点击
    if (self.bridge) {
        if ([self.bridge respondsToSelector:@selector(nativeAd:didClickWithMediatedNativeAd:)]) {
            [self.bridge nativeAd:self didClickWithMediatedNativeAd:nativeAd.dataObject];
        }
        // 通知融合 SDK 广告将展示全屏内容
        if ([self.bridge respondsToSelector:@selector(nativeAd:willPresentFullScreenModalWithMediatedNativeAd:)]) {
            [self.bridge nativeAd:self willPresentFullScreenModalWithMediatedNativeAd:nativeAd.dataObject];
        }
    }
}

- (void)selfRender_handleAdDetailViewWillPresent:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMBUMNativeAdapter[SelfRender] 广告详情页即将展示，nativeAd: %@, adView: %@", nativeAd, adView);

    // 通知融合 SDK 广告将展示全屏内容
    if (self.bridge && [self.bridge respondsToSelector:@selector(nativeAd:willPresentFullScreenModalWithMediatedNativeAd:)]) {
        [self.bridge nativeAd:self willPresentFullScreenModalWithMediatedNativeAd:nativeAd.dataObject];
    }
}

- (void)selfRender_handleAdDetailViewClosed:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMBUMNativeAdapter[SelfRender] 广告详情页关闭，nativeAd: %@, adView: %@", nativeAd, adView);

    // 注意：BUMCustomNativeAdapterBridge 协议中没有 willDismissFullScreenModalWithMediatedNativeAd 方法
    // 详情页关闭时不需要通知 bridge，因为详情页的展示和关闭由广告 SDK 内部管理
}

@end
