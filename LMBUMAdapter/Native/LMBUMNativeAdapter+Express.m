//
//  LMBUMNativeAdapter+Express.m
//  LitemizeSDK
//
//  穿山甲（BUM）信息流模板广告处理分类实现
//

#import "LMBUMNativeAdapter+Express.h"
#import <BUAdSDK/BUAdSDK.h>
#import <LitemizeSDK/LMAdSlot.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

/// 分类需要访问主类的私有属性和方法，在此重新声明
@interface LMBUMNativeAdapter ()

/// 当前加载的模板广告实例列表（一个请求可能返回多个广告）
@property(nonatomic, strong) NSMutableArray<LMNativeExpressAd *> *expressAds;
/// ExpressView 到 ExpressAd 的映射关系（用于通过视图找到对应的广告实例）
@property(nonatomic, strong) NSMapTable<UIView *, LMNativeExpressAd *> *expressViewToAdMap;
/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;
/// 当前请求的广告数量
@property(nonatomic, assign) NSInteger requestedAdCount;
/// 竞价类型（用于判断是否需要传入 ECPM）
@property(nonatomic, assign) NSInteger biddingType;

/// 通知加载失败（私有方法）
- (void)_notifyLoadFailed:(NSError *)error;

@end

@implementation LMBUMNativeAdapter (Express)

#pragma mark - 模板广告加载

- (void)express_loadAdsWithSlotID:(NSString *)slotID count:(NSInteger)count size:(CGSize)size imageSize:(CGSize)imageSize {
    NSLog(@"LMBUMNativeAdapter[Express] 开始加载模板广告，slotID: %@, count: %ld", slotID, (long)count);

    NSMutableArray<LMNativeExpressAd *> *loadingAds = [NSMutableArray arrayWithCapacity:count];

    // 创建多个广告实例（一个请求可能返回多个广告）
    for (NSInteger i = 0; i < count; i++) {
        // 创建广告位配置
        LMAdSlot *slot = [LMAdSlot slotWithId:slotID type:LMAdSlotTypeNativeExpress];

        // 创建模板广告实例
        LMNativeExpressAd *expressAd = [[LMNativeExpressAd alloc] initWithSlot:slot];
        if (!expressAd) {
            NSLog(@"⚠️ LMBUMNativeAdapter[Express] 创建 LMNativeExpressAd 失败");
            continue;
        }

        // 设置代理
        expressAd.delegate = self;
        // 设置 viewController（从 bridge 获取）
        if (self.bridge && [self.bridge respondsToSelector:@selector(viewControllerForPresentingModalView)]) {
            expressAd.viewController = self.bridge.viewControllerForPresentingModalView;
        }

        [loadingAds addObject:expressAd];
        [self.expressAds addObject:expressAd];

        // 开始加载广告
        [expressAd loadAd];
    }

    // 如果没有任何广告实例创建成功，通知失败
    if (loadingAds.count == 0) {
        NSError *error = [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey : @"创建模板广告实例失败"}];
        [self _notifyLoadFailed:error];
    }
}

#pragma mark - 模板广告加载成功检查

- (void)express_checkAndNotifyLoadSuccess {
    if (self.hasCalledLoadSuccess) {
        return;
    }

    // 收集所有已加载的广告视图（直接使用 expressView）
    NSMutableArray *loadedViews = [NSMutableArray array];
    for (LMNativeExpressAd *ad in self.expressAds) {
        if (ad.expressView) {
            // 保存 expressView -> expressAd 的映射关系
            [self.expressViewToAdMap setObject:ad forKey:ad.expressView];
            [loadedViews addObject:ad.expressView];
        }
    }

    // 如果所有请求的广告都已加载完成，通知成功
    if (loadedViews.count >= self.requestedAdCount && loadedViews.count > 0) {
        self.hasCalledLoadSuccess = YES;

        // 判断是否为客户端竞价
        NSArray *exts = @[];
        if (self.biddingType == BUMBiddingTypeClient) {
            // 收集所有广告的 ECPM
            NSMutableArray *ecpmExts = [NSMutableArray arrayWithCapacity:loadedViews.count];
            for (UIView *expressView in loadedViews) {
                NSString *ecpm = @"0";
                LMNativeExpressAd *expressAd = [self.expressViewToAdMap objectForKey:expressView];
                if (expressAd) {
                    ecpm = [expressAd getEcpm] ?: @"0";
                }
                [ecpmExts addObject:@{BUMMediaAdLoadingExtECPM : ecpm}];
            }
            exts = [ecpmExts copy];
        }

        // 通知融合 SDK 广告加载成功
        if (self.bridge && [self.bridge respondsToSelector:@selector(nativeAd:didLoadWithExpressViews:exts:)]) {
            [self.bridge nativeAd:self didLoadWithExpressViews:[loadedViews copy] exts:exts];
        }
    }
}

#pragma mark - 模板广告渲染处理

- (void)express_handleRenderForView:(UIView *)expressAdView {
    NSLog(@"LMBUMNativeAdapter[Express] 处理模板广告渲染，expressAdView: %@", expressAdView);

    // BUM SDK 调用 renderForExpressAdView 时，传入的是 expressView
    // 我们需要通过 expressView 找到对应的 LMNativeExpressAd 实例，然后触发渲染
    LMNativeExpressAd *expressAd = [self.expressViewToAdMap objectForKey:expressAdView];

    if (expressAd && expressAd.expressView == expressAdView) {
        // LitemizeSDK 的模板广告需要调用 showInView: 来触发渲染
        // showInView: 会将 expressView 添加到容器中，并触发渲染
        // expressView 的 superview 应该是带内边距的容器视图（由 demo 创建）
        UIView *containerView = expressAdView.superview;
        if (!containerView) {
            NSLog(@"⚠️ LMBUMNativeAdapter[Express] expressView 还没有父视图，无法渲染");
            return;
        }
        // showInView: 会检查如果 expressView 已经在 containerView 中，会重新设置约束填充容器
        [expressAd showInView:containerView];
        // 回调渲染成功
        [self express_handleRenderSuccess:expressAd];
        NSLog(@"LMBUMNativeAdapter[Express] 调用 showInView 触发渲染，expressView: %@, container: %@", expressAdView,
              containerView);
    } else {
        NSLog(@"⚠️ LMBUMNativeAdapter[Express] 无法找到 expressAdView 对应的 expressAd");
    }
}

#pragma mark - 模板广告回调处理

- (void)express_handleAdLoaded:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter[Express] 广告加载成功，nativeExpressAd: %@", nativeExpressAd);

    if (!nativeExpressAd || !nativeExpressAd.expressView) {
        NSLog(@"⚠️ LMBUMNativeAdapter[Express] handleAdLoaded: nativeExpressAd 或 expressView 为空");
        return;
    }

    // 保存 expressView -> expressAd 的映射关系
    [self.expressViewToAdMap setObject:nativeExpressAd forKey:nativeExpressAd.expressView];

    // 检查并通知加载成功
    [self express_checkAndNotifyLoadSuccess];
}

- (void)express_handleAdLoadFailed:(LMNativeExpressAd *)nativeExpressAd
                             error:(NSError *)error
                       description:(NSDictionary *)description {
    NSLog(@"LMBUMNativeAdapter[Express] 广告加载失败，nativeExpressAd: %@, error: %@", nativeExpressAd, error);

    // 检查是否所有广告都加载失败
    BOOL allFailed = YES;
    for (LMNativeExpressAd *ad in self.expressAds) {
        if (ad.expressView) {
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
            for (LMNativeExpressAd *ad in self.expressAds) {
                if (ad.expressView) {
                    stillAllFailed = NO;
                    break;
                }
            }
            if (stillAllFailed && !self.hasCalledLoadSuccess) {
                [self _notifyLoadFailed:error
                          ?: [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                                 code:-5
                                             userInfo:@{NSLocalizedDescriptionKey : @"所有模板广告加载失败"}]];
            }
        });
    }
}

- (void)express_handleRenderSuccess:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter[Express] 广告渲染成功，nativeExpressAd: %@", nativeExpressAd);

    if (!nativeExpressAd || !nativeExpressAd.expressView) {
        NSLog(@"⚠️ LMBUMNativeAdapter[Express] express_handleRenderSuccess: expressView 为空");
        return;
    }

    UIView *expressView = nativeExpressAd.expressView;

    // 通知融合 SDK 模板广告渲染成功
    // 直接传递 expressView，这样 BUM SDK 才能在 nativeAdExpressSuccessRender 回调中正确存储到 adViewMap
    // 仅限模板广告，在渲染成功或者模板广告的尺寸更新时调用，直接调用即可，无需做响应判断
    if (self.bridge) {
        NSLog(@"LMBUMNativeAdapter[Express] 通知渲染成功，expressView: %@, frame: %@", expressView,
              NSStringFromCGRect(expressView.frame));
        [self.bridge nativeAd:self renderSuccessWithExpressView:expressView];
    }
}

- (void)express_handleRenderFail:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter[Express] 广告渲染失败，nativeExpressAd: %@", nativeExpressAd);

    // 通知融合 SDK 模板广告渲染失败
    // 仅限模板广告，在渲染失败调用，直接调用即可，无需做响应判断
    if (self.bridge) {
        UIView *expressView = nativeExpressAd.expressView;
        if (!expressView) {
            expressView = nativeExpressAd.expressView.superview;
        }
        NSError *error = [NSError errorWithDomain:@"LMBUMNativeAdapter"
                                             code:-6
                                         userInfo:@{NSLocalizedDescriptionKey : @"模板广告渲染失败"}];
        [self.bridge nativeAd:self renderFailWithExpressView:expressView ?: [[UIView alloc] init] andError:error];
    }
}

- (void)express_handleAdWillExpose:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter[Express] 广告即将曝光，nativeExpressAd: %@", nativeExpressAd);

    // 通知融合 SDK 广告曝光
    if (self.bridge && [self.bridge respondsToSelector:@selector(nativeAd:didVisibleWithMediatedNativeAd:)]) {
        // express广告请传递上报GroMore的UIView
        UIView *expressView = nativeExpressAd.expressView;
        if (!expressView) {
            expressView = nativeExpressAd.expressView.superview;
        }
        if (expressView) {
            [self.bridge nativeAd:self didVisibleWithMediatedNativeAd:expressView];
        }
    }
}

- (void)express_handleAdDidClick:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter[Express] 广告被点击，nativeExpressAd: %@", nativeExpressAd);

    // 通知融合 SDK 广告点击
    if (self.bridge) {
        UIView *expressView = nativeExpressAd.expressView;
        if (!expressView) {
            expressView = nativeExpressAd.expressView.superview;
        }
        if (expressView) {
            if ([self.bridge respondsToSelector:@selector(nativeAd:didClickWithMediatedNativeAd:)]) {
                [self.bridge nativeAd:self didClickWithMediatedNativeAd:expressView];
            }
            // 通知融合 SDK 广告将展示全屏内容
            if ([self.bridge respondsToSelector:@selector(nativeAd:willPresentFullScreenModalWithMediatedNativeAd:)]) {
                [self.bridge nativeAd:self willPresentFullScreenModalWithMediatedNativeAd:expressView];
            }
        }
    }
}

- (void)express_handleAdDidClose:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMBUMNativeAdapter[Express] 广告关闭，nativeExpressAd: %@", nativeExpressAd);

    // 通知融合 SDK 广告关闭
    // 仅限模板广告，在模板广告关闭的时候调用，直接调用即可，无需做响应判断
    if (self.bridge) {
        UIView *expressView = nativeExpressAd.expressView;
        if (!expressView) {
            expressView = nativeExpressAd.expressView.superview;
            NSLog(@"LMBUMNativeAdapter[Express] 通知广告关闭，expressView: %@, expressView.superview: %@", expressView,
                  expressView.superview);
        }
        // 获取关闭原因（如果有的话）
        NSArray<NSString *> *closeReasons = nil; // 可以从 nativeExpressAd 获取关闭原因
        NSLog(@"LMBUMNativeAdapter[Express] 通知广告关闭，expressView: %@, closeReasons: %@", expressView, closeReasons);
        [self.bridge nativeAd:self didCloseWithExpressView:expressView ?: [[UIView alloc] init] closeReasons:closeReasons];
    }
}

@end
