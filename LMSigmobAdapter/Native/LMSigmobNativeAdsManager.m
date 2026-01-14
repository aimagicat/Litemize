//
//  LMSigmobNativeAdsManager.m
//  LitemizeSDK
//
//  Sigmob 自渲染原生广告管理器实现
//

#import "LMSigmobNativeAdsManager.h"
#import "../LMSigmobAdapterLog.h"
#import "LMSigmobNativeAdData.h"
#import "LMSigmobNativeAdViewCreator.h"
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>

@interface LMSigmobNativeAdsManager () <LMNativeAdDelegate>

@property(nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property(nonatomic, weak) id<AWMCustomNativeAdapter> adapter;
@property(nonatomic, strong) NSMutableArray<LMNativeAd *> *nativeAds;
@property(nonatomic, strong) NSArray<LMNativeAd *> *nativeAdDataArray;

@end

@implementation LMSigmobNativeAdsManager

- (instancetype)initWithBridge:(id<AWMCustomAdapterBridge>)bridge adapter:(id<AWMCustomAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = (id<AWMCustomNativeAdapterBridge>)bridge;
        _adapter = (id<AWMCustomNativeAdapter>)adapter;
        _nativeAds = [NSMutableArray array];
    }
    return self;
}

- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)size parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"NativeAdsManager loadAdWithPlacementId: %@, adSize: %@", placementId, NSStringFromCGSize(size));

    self.nativeAdDataArray = nil;

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
    [self.nativeAds removeAllObjects];

    // 创建多个广告实例
    for (NSUInteger i = 0; i < count; i++) {
        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:placementId type:LMAdSlotTypeNative];
        // 设置期望的图片尺寸
        if (size.width > 0 && size.height > 0) {
            slot.imgSize = size;
        }

        // 创建自渲染广告实例
        LMNativeAd *nativeAd = [[LMNativeAd alloc] initWithSlot:slot];
        if (!nativeAd) {
            LMSigmobLog(@"⚠️ NativeAdsManager 创建 LMNativeAd 失败");
            continue;
        }

        // 设置代理
        nativeAd.delegate = self;

        [self.nativeAds addObject:nativeAd];

        // 开始加载广告
        [nativeAd loadAd];
    }

    // 如果没有任何广告实例创建成功，通知失败
    if (self.nativeAds.count == 0) {
        NSError *error = [NSError errorWithDomain:@"LMSigmobNativeAdsManager"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"创建自渲染广告实例失败"}];
        [self.bridge nativeAd:self.adapter didLoadFailWithError:error];
    }
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    LMSigmobLog(@"NativeAdsManager didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：LitemizeSDK 的 LMNativeAd 可能不支持竞价结果上报，这里先保留接口
    // 如果后续 SDK 支持，可以在这里实现

    self.nativeAdDataArray = nil;
}

#pragma mark - LMNativeAdDelegate

- (void)lm_nativeAdLoaded:(nullable LMNativeAdDataObject *)dataObject nativeAd:(LMNativeAd *)nativeAd {
    LMSigmobLog(@"NativeAdsManager 自渲染广告加载成功，dataObject: %@, nativeAd: %@", dataObject, nativeAd);

    // 检查是否所有广告都已加载完成
    NSMutableArray<LMNativeAd *> *loadedAds = [NSMutableArray array];
    for (LMNativeAd *ad in self.nativeAds) {
        if (ad.dataObject) {
            [loadedAds addObject:ad];
        }
    }

    // 如果还没有设置 nativeAdDataArray，说明这是第一次加载成功
    if (!self.nativeAdDataArray || self.nativeAdDataArray.count == 0) {
        self.nativeAdDataArray = [loadedAds copy];

        // 获取第一个广告的 ECPM（用于客户端竞价）
        // 注意：LitemizeSDK 的 getEcpm 返回单位是"元"，ToBid SDK 期望单位是"分"
        LMNativeAd *firstAd = loadedAds.firstObject;
        NSString *price = nil;
        if ([firstAd respondsToSelector:@selector(getEcpm)]) {
            price = [firstAd getEcpm];
        }
        // 从元转换为分（1元 = 100分）
        NSString *ecpmString = [NSString stringWithFormat:@"%.2f", price.floatValue * 100.0];
        // 通知 ToBid SDK 广告数据返回（用于客户端竞价）
        if (ecpmString && ecpmString.length > 0) {
            [self.bridge nativeAd:self.adapter didAdServerResponseWithExt:@{AWMMediaAdLoadingExtECPM : ecpmString}];
        }

        // 构建 AWMMediatedNativeAd 数组
        NSMutableArray *adArray = [[NSMutableArray alloc] init];
        for (LMNativeAd *ad in loadedAds) {
            AWMMediatedNativeAd *mNativeAd = [[AWMMediatedNativeAd alloc] init];
            mNativeAd.data = [[LMSigmobNativeAdData alloc] initWithDataObject:ad.dataObject];
            mNativeAd.originMediatedNativeAd = ad.dataObject;

            // 创建 ViewCreator（需要传入 nativeAd 和 adView）
            // 注意：LitemizeSDK 的自渲染广告可能需要创建相关的视图
            LMSigmobNativeAdViewCreator *viewCreator = [[LMSigmobNativeAdViewCreator alloc] initWithNativeAd:ad];
            mNativeAd.viewCreator = viewCreator;

            [adArray addObject:mNativeAd];
        }

        // 通知 ToBid SDK 广告加载成功
        [self.bridge nativeAd:self.adapter didLoadWithNativeAds:adArray];
    }
}

- (void)lm_nativeAd:(LMNativeAd *)nativeAd didFailWithError:(nullable NSError *)error description:(NSDictionary *)description {
    LMSigmobLog(@"NativeAdsManager 自渲染广告加载失败，nativeAd: %@, error: %@", nativeAd, error);

    // 检查是否所有广告都加载失败
    BOOL allFailed = YES;
    for (LMNativeAd *ad in self.nativeAds) {
        if (ad.dataObject) {
            allFailed = NO;
            break;
        }
    }

    // 如果所有广告都加载失败，且没有成功加载的广告，才通知失败
    if (allFailed && (!self.nativeAdDataArray || self.nativeAdDataArray.count == 0)) {
        [self.bridge nativeAd:self.adapter
            didLoadFailWithError:error
                ?: [NSError errorWithDomain:@"LMSigmobNativeAdsManager"
                                       code:-2
                                   userInfo:@{NSLocalizedDescriptionKey : @"所有自渲染广告加载失败"}]];
    }
}

- (void)lm_nativeAdViewWillExpose:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    LMSigmobLog(@"NativeAdsManager 自渲染广告即将曝光，nativeAd: %@, adView: %@", nativeAd, adView);
    [self.bridge nativeAd:self.adapter didVisibleWithMediatedNativeAd:nativeAd.dataObject];
}

- (void)lm_nativeAdViewDidClick:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView {
    LMSigmobLog(@"NativeAdsManager 自渲染广告被点击，nativeAd: %@, adView: %@", nativeAd, adView);
    [self.bridge nativeAd:self.adapter didClickWithMediatedNativeAd:nativeAd.dataObject];
}

- (void)lm_nativeAdDetailViewWillPresentScreen:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    LMSigmobLog(@"NativeAdsManager 自渲染广告详情页即将展示，nativeAd: %@, adView: %@", nativeAd, adView);
    [self.bridge nativeAd:self.adapter willPresentFullScreenModalWithMediatedNativeAd:nativeAd.dataObject];
}

- (void)lm_nativeAdDetailViewClosed:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    LMSigmobLog(@"NativeAdsManager 自渲染广告详情页关闭，nativeAd: %@, adView: %@", nativeAd, adView);
    [self.bridge nativeAd:self.adapter didDismissFullScreenModalWithMediatedNativeAd:nativeAd.dataObject];
}

- (void)lm_nativeAdDidClose:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView {
    LMSigmobLog(@"NativeAdsManager 自渲染广告关闭，nativeAd: %@, adView: %@", nativeAd, adView);
    NSMutableArray *reasons = [NSMutableArray array];
    [self.bridge nativeAd:self.adapter didClose:nativeAd.dataObject closeReasons:reasons];
}

- (void)dealloc {
    LMSigmobLog(@"NativeAdsManager dealloc");

    // 清理资源
    for (LMNativeAd *ad in self.nativeAds) {
        ad.delegate = nil;
        [ad close];
    }
    [self.nativeAds removeAllObjects];
}

@end
