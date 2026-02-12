//
//  LMTakuNativeDelegate.m
//  LitemobSDK
//
//  Taku/AnyThink 原生广告代理实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuNativeDelegate.h"
#import "../Base/LMTakuAdapterCommonHeader.h"
#import "../Base/LMTakuBaseAdapter.h"
#import "LMTakuNativeObject.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <LitemobSDK/LMNativeAd.h>
#import <LitemobSDK/LMNativeAdDataObject.h>

@interface LMTakuNativeDelegate ()

/// 是否已关闭（防止重复调用关闭回调）
@property(nonatomic, assign) BOOL isClosed;

@end

@implementation LMTakuNativeDelegate

#pragma mark - LMNativeAdDelegate

/// 自渲染原生广告加载成功
/// @param dataObject LitemobSDK 原生广告数据对象
/// @param nativeAd   LitemobSDK 原生广告实例
- (void)lm_nativeAdLoaded:(nullable LMNativeAdDataObject *)dataObject nativeAd:(LMNativeAd *)nativeAd {
    LMTakuLog(@"Native", @"自渲染原生广告加载成功: dataObject = %@, nativeAd = %@", dataObject, nativeAd);

    if (!dataObject) {
        NSError *error = [NSError errorWithDomain:@"LMTakuNativeDelegate"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"LMNativeAdDataObject 为空"}];
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }

    // 组装 C2S 竞价信息（若需要客户端竞价）
    NSString *ecpm = nil;
    if ([nativeAd respondsToSelector:@selector(getEcpm)]) {
        ecpm = [nativeAd getEcpm];
    }
    NSDictionary *infoDic = ecpm.length > 0 ? [LMTakuBaseAdapter getC2SInfo:ecpm] : @{};

    // 目前一次只加载一个自渲染广告，按 AnyThink 要求仍然以数组形式回调
    NSMutableArray<ATCustomNetworkNativeAd *> *offerArray = [NSMutableArray array];

    // 创建自定义原生广告对象
    LMTakuNativeObject *nativeObject = [[LMTakuNativeObject alloc] init];
    nativeObject.nativeAd = nativeAd;
    nativeObject.dataObject = dataObject;

    // 声明为自渲染类型
    nativeObject.nativeAdRenderType = ATNativeAdRenderSelfRender;

    // 标题与文案
    nativeObject.title = dataObject.title ?: @"";
    nativeObject.mainText = dataObject.desc ?: @"";

    // CTA 文案（Litemob 未显式提供，使用默认值）
    nativeObject.ctaText = @"立即下载";

    // 评分、价格等信息（Litemob 暂未提供评分字段）
    nativeObject.rating = @(0);
    if (dataObject.price >= 0) {
        CGFloat priceInYuan = dataObject.price / 100.0;
        nativeObject.appPrice = [NSString stringWithFormat:@"%.2f", priceInYuan];
    }

    // 视频信息
    nativeObject.isVideoContents = dataObject.isVideo;
    if (dataObject.isVideo && dataObject.materialList.count > 0) {
        // 查找第一个视频物料，补充视频时长
        for (LMNativeAdMaterialObject *material in dataObject.materialList) {
            if (material.isVideo && material.materialDuration > 0) {
                nativeObject.videoDuration = material.materialDuration;
                break;
            }
        }
    }

    // 素材图片信息
    nativeObject.iconUrl = dataObject.iconUrl;

    NSMutableArray<NSString *> *imageUrls = [NSMutableArray array];
    CGFloat mainWidth = 0;
    CGFloat mainHeight = 0;

    if (dataObject.materialList && dataObject.materialList.count > 0) {
        for (LMNativeAdMaterialObject *material in dataObject.materialList) {
            // 只处理非视频素材
            if (!material.isVideo && material.materialUrl.length > 0) {
                [imageUrls addObject:material.materialUrl];
                if (mainWidth <= 0 || mainHeight <= 0) {
                    mainWidth = material.materialWidth;
                    mainHeight = material.materialHeight;
                }
            }
        }
    }

    nativeObject.imageList = imageUrls;
    nativeObject.imageUrl = imageUrls.firstObject;
    nativeObject.mainImageWidth = mainWidth;
    nativeObject.mainImageHeight = mainHeight;

    [offerArray addObject:nativeObject];

    // 通知 AnyThink 原生广告加载成功
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnNativeAdLoadedArray:adExtra:)]) {
        [self.adStatusBridge atOnNativeAdLoadedArray:offerArray adExtra:infoDic];
    } else {
        LMTakuLog(@"Native", @"⚠️ adStatusBridge 为空或未实现 atOnNativeAdLoadedArray:adExtra:");
    }
}

/// 自渲染原生广告加载失败
- (void)lm_nativeAd:(LMNativeAd *)nativeAd didFailWithError:(nullable NSError *)error description:(NSDictionary *)description {
    LMTakuLog(@"Native", @"自渲染原生广告加载失败: %@, error = %@, desc = %@", nativeAd, error, description);
    if (!error) {
        error = [NSError errorWithDomain:@"LMTakuNativeDelegate"
                                    code:-2
                                userInfo:@{NSLocalizedDescriptionKey : @"原生广告加载失败"}];
    }
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdLoadFailed:adExtra:)]) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

/// 自渲染原生广告曝光
- (void)lm_nativeAdViewWillExpose:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    LMTakuLog(@"Native", @"自渲染原生广告即将曝光: %@, adView = %@", nativeAd, adView);
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdShow:)]) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

/// 自渲染原生广告点击
- (void)lm_nativeAdViewDidClick:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView {
    LMTakuLog(@"Native", @"自渲染原生广告被点击: %@, adView = %@", nativeAd, adView);
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdClick:)]) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

/// 原生广告详情页即将展示
- (void)lm_nativeAdDetailViewWillPresentScreen:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    LMTakuLog(@"Native", @"原生广告详情页即将展示: %@, adView = %@", nativeAd, adView);
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdDetailWillShow:)]) {
        [self.adStatusBridge atOnAdDetailWillShow:nil];
    }
}

/// 原生广告详情页关闭
- (void)lm_nativeAdDetailViewClosed:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    LMTakuLog(@"Native", @"原生广告详情页关闭: %@, adView = %@", nativeAd, adView);
    if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnAdDetailClosed:)]) {
        [self.adStatusBridge atOnAdDetailClosed:nil];
    }
}

/// 原生广告关闭
- (void)lm_nativeAdDidClose:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView {
    // 不加回调是因为 Taku SDK 会自动关闭广告，不需要重复调用
}

- (void)dealloc {
    self.adStatusBridge = nil;
    self.adMediationArgument = nil;
    LMTakuLog(@"Native", @"LMTakuNativeDelegate dealloc");
}

@end
