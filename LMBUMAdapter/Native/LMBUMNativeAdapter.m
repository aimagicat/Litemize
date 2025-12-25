//
//  LMBUMNativeAdapter.m
//  LitemizeSDK
//
//  穿山甲（BUM）信息流广告 Adapter 实现
//

#import "LMBUMNativeAdapter.h"
#import "LMBUMNativeAdData.h"
#import "LMBUMNativeAdViewCreator.h"
#import "LMBUMNativeAdapter+Express.h"
#import "LMBUMNativeAdapter+SelfRender.h"
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <LitemizeSDK/LMNativeAdViewProtocol.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

// GroMore SDK 相关头文件（如果可用）
#import <BUAdSDK/BUAdSDK.h>

@interface LMBUMNativeAdapter ()

/// 当前加载的非模板广告实例列表（一个请求可能返回多个广告）
@property(nonatomic, strong) NSMutableArray<LMNativeAd *> *nativeAds;
/// 当前加载的模板广告实例列表（一个请求可能返回多个广告）
@property(nonatomic, strong) NSMutableArray<LMNativeExpressAd *> *expressAds;
/// ExpressView 到 ExpressAd 的映射关系（用于通过视图找到对应的广告实例）
@property(nonatomic, strong) NSMapTable<UIView *, LMNativeExpressAd *> *expressViewToAdMap;
/// 广告位 ID
@property(nonatomic, copy, nullable) NSString *slotID;
/// 广告尺寸
@property(nonatomic, assign) CGSize adSize;
/// 图片尺寸
@property(nonatomic, assign) CGSize imageSize;
/// 竞价类型（用于判断是否需要传入 ECPM）
@property(nonatomic, assign) NSInteger biddingType;
/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;
/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;
/// 当前请求的广告数量
@property(nonatomic, assign) NSInteger requestedAdCount;
/// 已加载的广告数量
@property(nonatomic, assign) NSInteger loadedAdCount;

@end

@implementation LMBUMNativeAdapter

#pragma mark - Class Loading

/// 类加载时调用（系统自动调用）
+ (void)load {
    NSLog(@"✅ [LMBUMNativeAdapter] LMBUMNativeAdapter 类已加载到系统");
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _nativeAds = [NSMutableArray array];
        _expressAds = [NSMutableArray array];
        // 使用弱引用 key（UIView），强引用 value（LMNativeExpressAd），避免循环引用
        _expressViewToAdMap = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        _hasCalledLoadSuccess = NO;
        _hasCalledLoadFailed = NO;
    }
    return self;
}

#pragma mark - BUMCustomNativeAdapter Protocol Implementation

/// 加载信息流广告
/// @param slotID network广告位ID
/// @param size 广告展示尺寸
/// @param imageSize 广告中图片的展示尺寸
/// @param parameter 广告请求的参数信息
- (void)loadNativeAdWithSlotID:(NSString *)slotID
                       andSize:(CGSize)size
                     imageSize:(CGSize)imageSize
                     parameter:(NSDictionary *)parameter {
    NSLog(@"LMBUMNativeAdapter loadNativeAdWithSlotID: %@, size: %@, imageSize: %@, parameter: %@", slotID,
          NSStringFromCGSize(size), NSStringFromCGSize(imageSize), parameter);

    if (!slotID || slotID.length == 0) {
        NSLog(@"⚠️ loadNativeAdWithSlotID: slotID 为空");
        NSError *error = [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"slotID 为空"}];
        [self _notifyLoadFailed:error];
        return;
    }

    // 获取广告加载数量
    NSInteger count = 1;
    if (parameter && parameter[BUMAdLoadingParamNALoadAdCount]) {
        count = [parameter[BUMAdLoadingParamNALoadAdCount] integerValue];
        if (count <= 0) {
            count = 1;
        }
    }
    self.requestedAdCount = count;

    // 获取是否需要加载模板广告
    BOOL express = YES;

    // 获取竞价类型
    NSInteger biddingType = 0;
    if (parameter && parameter[BUMAdLoadingParamBiddingType]) {
        biddingType = [parameter[BUMAdLoadingParamBiddingType] integerValue];
    }
    self.biddingType = biddingType;

    self.slotID = slotID;
    self.adSize = size;
    self.imageSize = imageSize;
    self.hasCalledLoadSuccess = NO;
    self.hasCalledLoadFailed = NO;
    self.loadedAdCount = 0;

    // 清空之前的广告
    [self.nativeAds removeAllObjects];
    [self.expressAds removeAllObjects];

    __weak typeof(self) ws = self;

    // 在主线程创建并加载广告
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(ws) self = ws;
        if (!self) {
            return;
        }

        if (express) {
            // 加载模板广告（使用分类方法）
            [self express_loadAdsWithSlotID:slotID count:count size:size imageSize:imageSize];
        } else {
            // 加载自渲染广告（使用分类方法）
            [self selfRender_loadAdsWithSlotID:slotID count:count size:size imageSize:imageSize];
        }
    });
}

/// 渲染广告，为模板广告时会回调该方法
/// @param expressAdView 模板广告的视图（应该是 wrapper）
- (void)renderForExpressAdView:(UIView *)expressAdView {
    NSLog(@"LMBUMNativeAdapter renderForExpressAdView: %@", expressAdView);

    // 使用分类方法处理模板广告渲染
    [self express_handleRenderForView:expressAdView];
}

/// 为模板广告设置控制器
/// @param viewController 广告点击事件跳转控制器
/// @param expressAdView 模板广告的视图
- (void)setRootViewController:(UIViewController *)viewController forExpressAdView:(UIView *)expressAdView {
    NSLog(@"LMBUMNativeAdapter setRootViewController: %@ forExpressAdView: %@", viewController, expressAdView);

    // 通过 expressView 查找对应的 LMNativeExpressAd 实例并设置 viewController
    LMNativeExpressAd *expressAd = [self.expressViewToAdMap objectForKey:expressAdView];
    if (expressAd) {
        expressAd.viewController = viewController;
    }
}

/// 为非模板广告设置控制器
/// @param viewController 广告点击事件跳转控制器
/// @param nativeAd 非模板广告的广告对象
- (void)setRootViewController:(UIViewController *)viewController forNativeAd:(id)nativeAd {
    NSLog(@"LMBUMNativeAdapter setRootViewController: %@ forNativeAd: %@", viewController, nativeAd);

    // nativeAd 应该是 LMNativeAdDataObject 或 LMNativeAd
    // 需要找到对应的 LMNativeAd 实例并设置 viewController
    if ([nativeAd isKindOfClass:[LMNativeAdDataObject class]]) {
        LMNativeAdDataObject *dataObject = (LMNativeAdDataObject *)nativeAd;
        // 从 nativeAds 中找到对应的实例
        for (LMNativeAd *ad in self.nativeAds) {
            if (ad.dataObject == dataObject) {
                ad.viewController = viewController;
                break;
            }
        }
    } else if ([nativeAd isKindOfClass:[LMNativeAd class]]) {
        LMNativeAd *ad = (LMNativeAd *)nativeAd;
        ad.viewController = viewController;
    }
}

/// 非模板广告注册容器和可点击区域
/// @param containerView 非模板广告的GroMore层级视图
/// @param views 媒体请求注册为点击区域的视图集合
/// @param nativeAd 非模板广告的广告对象
- (void)registerContainerView:(__kindof UIView *)containerView
            andClickableViews:(NSArray<__kindof UIView *> *)views
                  forNativeAd:(id)nativeAd {
    NSLog(@"LMBUMNativeAdapter registerContainerView: %@ andClickableViews: %@ forNativeAd: %@", containerView, views, nativeAd);

    // 找到对应的 LMNativeAd 实例并注册视图
    LMNativeAd *ad = nil;
    if ([nativeAd isKindOfClass:[LMNativeAdDataObject class]]) {
        LMNativeAdDataObject *dataObject = (LMNativeAdDataObject *)nativeAd;
        for (LMNativeAd *a in self.nativeAds) {
            if (a.dataObject == dataObject) {
                ad = a;
                break;
            }
        }
    } else if ([nativeAd isKindOfClass:[LMNativeAd class]]) {
        ad = (LMNativeAd *)nativeAd;
    }

    if (ad && containerView) {
        // 创建映射配置，一次性完成所有配置（包括视图层级调整）
        LMNativeAdViewMapping *mapping = nil;
        if (views && views.count > 0) {
            mapping = [LMNativeAdViewMapping mappingWithCloseButton:nil yaoyiyaoView:nil viewsToBringToFront:views];
        }

        // 注册广告视图（用于曝光监听和点击上报）
        // 如果提供了 mapping，会自动处理 viewsToBringToFront 中的视图层级
        [ad registerAdView:containerView withMapping:mapping];
    }
}

/// 收到竞价结果信息时可能触发
/// @param result 竞价结果模型
- (void)didReceiveBidResult:(BUMMediaBidResult *)result {
    NSLog(@"LMBUMNativeAdapter didReceiveBidResult: %@", result);

    // 处理竞价结果
    // 注意：此方法是否触发由 `-[BUAdSlot.mediation bidNotify]` 结果决定
    if (result) {
        // 获取竞价价格（如果 result 有 bidPrice 属性）
        if ([result respondsToSelector:@selector(bidPrice)]) {
            NSInteger bidPrice = [result performSelector:@selector(bidPrice)];
            NSLog(@"收到竞价结果，价格：%ld", (long)bidPrice);
        }
    }
}

#pragma mark - Private Methods

/// 通知加载失败
- (void)_notifyLoadFailed:(NSError *)error {
    if (self.hasCalledLoadFailed) {
        return;
    }
    self.hasCalledLoadFailed = YES;

    // 通知融合 SDK 广告加载失败
    if (self.bridge && [self.bridge respondsToSelector:@selector(nativeAd:didLoadFailWithError:)]) {
        [self.bridge nativeAd:self didLoadFailWithError:error];
    }

    // 清理资源
    [self _cleanupAds];
}

/// 清理广告资源
- (void)_cleanupAds {
    for (LMNativeAd *ad in self.nativeAds) {
        ad.delegate = nil;
        [ad close];
    }
    [self.nativeAds removeAllObjects];

    for (LMNativeExpressAd *ad in self.expressAds) {
        ad.delegate = nil;
        [ad close];
    }
    [self.expressAds removeAllObjects];
}

#pragma mark - LMNativeAdDelegate

/// 广告数据返回（自渲染广告）
- (void)lm_nativeAdLoaded:(nullable LMNativeAdDataObject *)dataObject nativeAd:(LMNativeAd *)nativeAd {
    NSLog(@"LMBUMNativeAdapter lm_nativeAdLoaded: %@, nativeAd: %@", dataObject, nativeAd);

    // 使用分类方法处理自渲染广告加载成功
    [self selfRender_handleAdLoaded:dataObject nativeAd:nativeAd];
}

/// 信息流自渲染加载失败
- (void)lm_nativeAd:(LMNativeAd *)nativeAd didFailWithError:(nullable NSError *)error description:(NSDictionary *)description {
    NSLog(@"LMBUMNativeAdapter lm_nativeAd:didFailWithError: %@, description: %@", error, description);

    // 使用分类方法处理自渲染广告加载失败
    [self selfRender_handleAdLoadFailed:nativeAd
                                  error:error
                                      ?: [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                                             code:-4
                                                         userInfo:@{NSLocalizedDescriptionKey : @"广告加载失败"}]
                            description:description];
}

/// 广告曝光回调（自渲染广告）
- (void)lm_nativeAdViewWillExpose:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMBUMNativeAdapter lm_nativeAdViewWillExpose: %@, adView: %@", nativeAd, adView);

    // 使用分类方法处理自渲染广告曝光
    [self selfRender_handleAdWillExpose:nativeAd adView:adView];
}

/// 广告点击回调（自渲染广告）
- (void)lm_nativeAdViewDidClick:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView {
    NSLog(@"LMBUMNativeAdapter lm_nativeAdViewDidClick: %@, adView: %@", nativeAd, adView);

    // 使用分类方法处理自渲染广告点击
    [self selfRender_handleAdDidClick:nativeAd adView:adView];
}

/// 广告详情页面即将展示回调（自渲染广告）
- (void)lm_nativeAdDetailViewWillPresentScreen:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMBUMNativeAdapter lm_nativeAdDetailViewWillPresentScreen: %@, adView: %@", nativeAd, adView);

    // 使用分类方法处理自渲染广告详情页展示
    [self selfRender_handleAdDetailViewWillPresent:nativeAd adView:adView];
}

/// 广告详情页关闭回调（自渲染广告）
- (void)lm_nativeAdDetailViewClosed:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMBUMNativeAdapter lm_nativeAdDetailViewClosed: %@, adView: %@", nativeAd, adView);

    // 使用分类方法处理自渲染广告详情页关闭
    [self selfRender_handleAdDetailViewClosed:nativeAd adView:adView];
}

#pragma mark - LMNativeExpressAdDelegate

/// 广告数据加载成功回调（模板广告）
- (void)lm_nativeExpressAdLoaded:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter lm_nativeExpressAdLoaded: %@", nativeExpressAd);

    // 使用分类方法处理模板广告加载成功
    [self express_handleAdLoaded:nativeExpressAd];
}

/// 广告加载失败（模板广告）
- (void)lm_nativeExpressAd:(LMNativeExpressAd *)nativeExpressAd
          didFailWithError:(nullable NSError *)error
               description:(NSDictionary *)description {
    NSLog(@"LMBUMNativeAdapter lm_nativeExpressAd:didFailWithError: %@, description: %@", error, description);

    // 使用分类方法处理模板广告加载失败
    [self express_handleAdLoadFailed:nativeExpressAd
                               error:error
                                   ?: [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                                          code:-5
                                                      userInfo:@{NSLocalizedDescriptionKey : @"模板广告加载失败"}]
                         description:description];
}

/// 信息流广告渲染成功（模板广告）
- (void)lm_nativeExpressAdViewRenderSuccess:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter lm_nativeExpressAdViewRenderSuccess: %@", nativeExpressAd);

    // 使用分类方法处理模板广告渲染成功
    [self express_handleRenderSuccess:nativeExpressAd];
}

/// 信息流广告渲染失败（模板广告）
- (void)lm_nativeExpressAdViewRenderFail:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter lm_nativeExpressAdViewRenderFail: %@", nativeExpressAd);

    // 使用分类方法处理模板广告渲染失败
    [self express_handleRenderFail:nativeExpressAd];
}

/// 广告即将曝光（模板广告）
- (void)lm_nativeExpressAdViewWillExpose:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter lm_nativeExpressAdViewWillExpose: %@", nativeExpressAd);

    // 使用分类方法处理模板广告曝光
    [self express_handleAdWillExpose:nativeExpressAd];
}

/// 广告被点击（模板广告）
- (void)lm_nativeExpressAdViewDidClick:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter lm_nativeExpressAdViewDidClick: %@", nativeExpressAd);

    // 使用分类方法处理模板广告点击
    [self express_handleAdDidClick:nativeExpressAd];
}

/// 广告关闭回调（模板广告）
- (void)lm_nativeExpressAdDidClose:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter lm_nativeExpressAdDidClose: %@", nativeExpressAd);

    // 使用分类方法处理模板广告关闭
    [self express_handleAdDidClose:nativeExpressAd];
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"LMBUMNativeAdapter dealloc");

    // 确保清理资源
    [self _cleanupAds];
}

@end
