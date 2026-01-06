//
//  LMSigmobNativeExpressAdManager.m
//  LitemizeSDK
//
//  Sigmob 模板渲染原生广告管理器实现
//

#import "LMSigmobNativeExpressAdManager.h"
#import "../LMSigmobAdapterLog.h"
#import "LMSigmobNativeAdViewCreator.h"
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

@interface LMSigmobNativeExpressAdManager () <LMNativeExpressAdDelegate>

@property(nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property(nonatomic, weak) id<AWMCustomNativeAdapter> adapter;
@property(nonatomic, strong) NSMutableArray<LMNativeExpressAd *> *expressAds;
@property(nonatomic, strong) NSArray<LMNativeExpressAd *> *adViews;

@end

@implementation LMSigmobNativeExpressAdManager

- (instancetype)initWithBridge:(id<AWMCustomAdapterBridge>)bridge adapter:(id<AWMCustomAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = (id<AWMCustomNativeAdapterBridge>)bridge;
        _adapter = (id<AWMCustomNativeAdapter>)adapter;
        _expressAds = [NSMutableArray array];
    }
    return self;
}

- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)size parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"NativeExpressAdManager loadAdWithPlacementId: %@, adSize: %@", placementId, NSStringFromCGSize(size));

    self.adViews = nil;

    // 获取广告加载数量
    NSUInteger count = 1;
    if (parameter.isHeaderBidding) {
        count = 1;
    } else {
        count = [[parameter.extra objectForKey:AWMAdLoadingParamNALoadAdCount] integerValue];
        if (count <= 0) {
            count = 1;
        }
    }

    // 清空之前的广告
    [self.expressAds removeAllObjects];

    // 创建多个广告实例
    for (NSUInteger i = 0; i < count; i++) {
        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:placementId type:LMAdSlotTypeNativeExpress];
        // 设置期望的图片尺寸
        if (size.width > 0 && size.height > 0) {
            slot.imgSize = size;
        }

        // 创建模板广告实例
        LMNativeExpressAd *expressAd = [[LMNativeExpressAd alloc] initWithSlot:slot];
        if (!expressAd) {
            LMSigmobLog(@"⚠️ NativeExpressAdManager 创建 LMNativeExpressAd 失败");
            continue;
        }

        // 设置代理
        expressAd.delegate = self;

        [self.expressAds addObject:expressAd];

        // 开始加载广告
        [expressAd loadAd];
    }

    // 如果没有任何广告实例创建成功，通知失败
    if (self.expressAds.count == 0) {
        NSError *error = [NSError errorWithDomain:@"LMSigmobNativeExpressAdManager"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"创建模板广告实例失败"}];
        [self.bridge nativeAd:self.adapter didLoadFailWithError:error];
    }
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    LMSigmobLog(@"NativeExpressAdManager didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：LitemizeSDK 的 LMNativeExpressAd 可能不支持竞价结果上报，这里先保留接口
    // 如果后续 SDK 支持，可以在这里实现

    self.adViews = nil;
}

#pragma mark - LMNativeExpressAdDelegate

- (void)lm_nativeExpressAdLoaded:(LMNativeExpressAd *)nativeExpressAd {
    LMSigmobLog(@"NativeExpressAdManager 模板广告加载成功，nativeExpressAd: %@", nativeExpressAd);

    // 检查是否所有广告都已加载完成
    NSMutableArray<LMNativeExpressAd *> *loadedAds = [NSMutableArray array];
    for (LMNativeExpressAd *ad in self.expressAds) {
        if (ad.expressView) {
            [loadedAds addObject:ad];
        }
    }

    // 如果还没有设置 adViews，说明这是第一次加载成功
    if (!self.adViews || self.adViews.count == 0) {
        self.adViews = [loadedAds copy];

        // 获取第一个广告的 ECPM（用于客户端竞价）
        LMNativeExpressAd *firstAd = loadedAds.firstObject;
        NSString *price = nil;
        if ([firstAd respondsToSelector:@selector(getEcpm)]) {
            price = [firstAd getEcpm];
        }

        // 通知 ToBid SDK 广告数据返回（用于客户端竞价）
        if (price && price.length > 0) {
            [self.bridge nativeAd:self.adapter didAdServerResponseWithExt:@{AWMMediaAdLoadingExtECPM : price}];
        }

        // 构建 AWMMediatedNativeAd 数组
        NSMutableArray *adArray = [[NSMutableArray alloc] init];
        for (LMNativeExpressAd *ad in loadedAds) {
            AWMMediatedNativeAd *mNativeAd = [[AWMMediatedNativeAd alloc] init];
            mNativeAd.originMediatedNativeAd = ad.expressView;
            mNativeAd.view = ad.expressView;

            // // 模板广告可以创建 ViewCreator（可选）
            // LMSigmobNativeAdViewCreator *viewCreator = [[LMSigmobNativeAdViewCreator alloc]
            // initWithExpressAdView:ad.expressView]; mNativeAd.viewCreator = viewCreator;

            [adArray addObject:mNativeAd];
        }

        // 通知 ToBid SDK 广告加载成功
        [self.bridge nativeAd:self.adapter didLoadWithNativeAds:adArray];
    }
}

- (void)lm_nativeExpressAd:(LMNativeExpressAd *)nativeExpressAd
          didFailWithError:(nullable NSError *)error
               description:(NSDictionary *)description {
    LMSigmobLog(@"NativeExpressAdManager 模板广告加载失败，nativeExpressAd: %@, error: %@", nativeExpressAd, error);

    // 检查是否所有广告都加载失败
    BOOL allFailed = YES;
    for (LMNativeExpressAd *ad in self.expressAds) {
        if (ad.expressView) {
            allFailed = NO;
            break;
        }
    }

    // 如果所有广告都加载失败，且没有成功加载的广告，才通知失败
    if (allFailed && (!self.adViews || self.adViews.count == 0)) {
        [self.bridge nativeAd:self.adapter
            didLoadFailWithError:error
                ?: [NSError errorWithDomain:@"LMSigmobNativeExpressAdManager"
                                       code:-2
                                   userInfo:@{NSLocalizedDescriptionKey : @"所有模板广告加载失败"}]];
    }
}

- (void)lm_nativeExpressAdViewRenderSuccess:(LMNativeExpressAd *)nativeExpressAd {
    LMSigmobLog(@"NativeExpressAdManager 模板广告渲染成功，nativeExpressAd: %@", nativeExpressAd);
    [self.bridge nativeAd:self.adapter renderSuccessWithExpressView:nativeExpressAd.expressView];
}

- (void)lm_nativeExpressAdViewRenderFail:(LMNativeExpressAd *)nativeExpressAd {
    LMSigmobLog(@"NativeExpressAdManager 模板广告渲染失败，nativeExpressAd: %@", nativeExpressAd);
    NSError *error = [NSError errorWithDomain:@"LMSigmobNativeExpressAdManager"
                                         code:-3
                                     userInfo:@{NSLocalizedDescriptionKey : @"模板广告渲染失败"}];
    [self.bridge nativeAd:self.adapter renderFailWithExpressView:nativeExpressAd.expressView andError:error];
}

- (void)lm_nativeExpressAdViewWillExpose:(LMNativeExpressAd *)nativeExpressAd {
    LMSigmobLog(@"NativeExpressAdManager 模板广告即将曝光，nativeExpressAd: %@", nativeExpressAd);
    [self.bridge nativeAd:self.adapter didVisibleWithMediatedNativeAd:nativeExpressAd.expressView];
}

- (void)lm_nativeExpressAdViewDidClick:(LMNativeExpressAd *)nativeExpressAd {
    LMSigmobLog(@"NativeExpressAdManager 模板广告被点击，nativeExpressAd: %@", nativeExpressAd);
    [self.bridge nativeAd:self.adapter didClickWithMediatedNativeAd:nativeExpressAd.expressView];
}

- (void)lm_nativeExpressAdDidClose:(LMNativeExpressAd *)nativeExpressAd {
    LMSigmobLog(@"NativeExpressAdManager 模板广告关闭，nativeExpressAd: %@", nativeExpressAd);
    NSMutableArray *reasons = [NSMutableArray array];
    [self.bridge nativeAd:self.adapter didClose:nativeExpressAd.expressView closeReasons:reasons];
}

- (void)dealloc {
    LMSigmobLog(@"NativeExpressAdManager dealloc");

    // 清理资源
    for (LMNativeExpressAd *ad in self.expressAds) {
        ad.delegate = nil;
        [ad close];
    }
    [self.expressAds removeAllObjects];
}

@end
