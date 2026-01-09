//
//  LMTakuNativeCustomEvent.m
//  LitemizeSDK
//
//  Taku/AnyThink 原生广告 CustomEvent 实现
//

#import "LMTakuNativeCustomEvent.h"
#import <AnyThinkNative/AnyThinkNative.h>
#import <LitemizeSDK/LMAdSDK.h>
#import <LitemizeSDK/LMNativeAd.h>
#import <LitemizeSDK/LMNativeAdDataObject.h>
#import <LitemizeSDK/LMNativeExpressAd.h>

@interface LMTakuNativeCustomEvent ()

/// 是否已经调用过加载成功回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadSuccess;

/// 是否已经调用过加载失败回调（避免重复调用）
@property(nonatomic, assign) BOOL hasCalledLoadFailed;

@end

@implementation LMTakuNativeCustomEvent
- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    if (self = [super initWithInfo:serverInfo localInfo:localInfo]) {
    }
    return self;
}

#pragma mark - LMNativeAdDelegate (自渲染)

/// 自渲染广告数据返回
- (void)lm_nativeAdLoaded:(nullable LMNativeAdDataObject *)dataObject nativeAd:(LMNativeAd *)nativeAd {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeAdLoaded:dataObject: %@", dataObject);
    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        if (!dataObject) {
            NSError *error = [NSError errorWithDomain:@"LMTakuNativeCustomEvent"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey : @"广告数据对象为空"}];
            // 通过 completion block 返回错误
            if (self.requestCompletionBlock) {
                self.requestCompletionBlock(nil, error);
            }
            return;
        }

        // 构建 assets 数组，参考文档示例格式
        NSMutableArray *assets = [NSMutableArray array];

        // 创建单个 asset 字典，映射到 Taku SDK 的格式
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];

        // 必须设置：CustomEvent 对象
        [asset setValue:self forKey:kATAdAssetsCustomEventKey];

        // 必须设置：自定义对象（原生广告数据对象）
        [asset setValue:dataObject forKey:kATAdAssetsCustomObjectKey];

        // 设置：原生自渲染广告标识（默认为自渲染）
        [asset setValue:@(NO) forKey:kATNativeADAssetsIsExpressAdKey];

        // 设置：广告标题
        if (dataObject.title) {
            [asset setValue:dataObject.title forKey:kATNativeADAssetsMainTitleKey];
        }

        // 设置：广告描述
        if (dataObject.desc) {
            [asset setValue:dataObject.desc forKey:kATNativeADAssetsMainTextKey];
        }

        // 设置：广告图标URL
        if (dataObject.iconUrl) {
            [asset setValue:dataObject.iconUrl forKey:kATNativeADAssetsIconURLKey];
        }

        // 设置：广告图标图片（如果有）
        if (dataObject.adIcon) {
            [asset setValue:dataObject.adIcon forKey:kATNativeADAssetsIconImageKey];
        }
        if (dataObject.materialList && dataObject.materialList.count > 0) {
            LMNativeAdMaterialObject *firstMaterial = dataObject.materialList.firstObject;
            if (firstMaterial.materialWidth > 0 && firstMaterial.materialHeight > 0) {
                [asset setValue:@(firstMaterial.materialWidth) forKey:kATNativeADAssetsMainImageWidthKey];
                [asset setValue:@(firstMaterial.materialHeight) forKey:kATNativeADAssetsMainImageHeightKey];
            }
        }

        // 设置：是否视频广告
        [asset setValue:@(dataObject.isVideo) forKey:kATNativeADAssetsContainsVideoFlag];
        if (dataObject.isVideo) {
            // 设置：视频相关属性
            if (dataObject.materialList && dataObject.materialList.count > 0) {
                LMNativeAdMaterialObject *firstMaterial = dataObject.materialList.firstObject;
                if (firstMaterial.materialUrl) {
                    [asset setValue:firstMaterial.materialUrl forKey:kATNativeADAssetsVideoUrlKey];
                }
                // 设置视频时长
                if (firstMaterial.materialDuration > 0) {
                    [asset setValue:@(firstMaterial.materialDuration) forKey:kATNativeADAssetsVideoDurationKey];
                }
                // 设置视频静音类型
                [asset setValue:@(firstMaterial.materialMute) forKey:kATNativeADAssetsVideoMutedTypeKey];
                if (firstMaterial.materialCoverUrl) {
                    [asset setValue:firstMaterial.materialCoverUrl forKey:kATNativeADAssetsImageURLKey];
                }
            }
        } else {
            // 设置：广告物料列表（图片URL）
            if (dataObject.materialList && dataObject.materialList.count > 0) {
                LMNativeAdMaterialObject *firstMaterial = dataObject.materialList.firstObject;
                if (firstMaterial.materialUrl) {
                    [asset setValue:firstMaterial.materialUrl forKey:kATNativeADAssetsImageURLKey];
                }
            }
        }

        // 设置：网络单元ID
        NSString *slotId = self.serverInfo[@"slot_id"];
        if (slotId) {
            [asset setValue:slotId forKey:kATNativeADAssetsUnitIDKey];
        }

        // 将 asset 添加到 assets 数组中
        [assets addObject:asset];

        // 调用 completion block 返回 assets 数组（Taku SDK 会处理后续的 trackNativeAdLoaded）
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock(assets, nil);
            NSLog(@"LMTakuNativeCustomEvent lm_nativeAdLoaded: 已通过 completion block 返回 assets");
        } else {
            NSLog(@"⚠️ LMTakuNativeCustomEvent: requestCompletionBlock 为空");
        }
    }
}

/// 自渲染广告加载失败
- (void)lm_nativeAd:(LMNativeAd *)nativeAd didFailWithError:(nullable NSError *)error description:(NSDictionary *)description {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeAd:didFailWithError: %@, description: %@", error, description);
    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;
        // 通过 completion block 返回错误
        NSError *finalError = error
            ?: [NSError errorWithDomain:@"LMTakuNativeCustomEvent"
                                   code:-1
                               userInfo:@{NSLocalizedDescriptionKey : @"广告加载失败"}];
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock(nil, finalError);
        }
    }
}

/// 自渲染广告曝光回调
- (void)lm_nativeAdViewWillExpose:(LMNativeAd *)nativeAd adView:(UIView *)adView {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeAdViewWillExpose:");
    // 调用 Taku SDK 的曝光回调
    [self trackNativeAdImpression];
}

/// 自渲染广告点击回调
- (void)lm_nativeAdViewDidClick:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeAdViewDidClick:");
    // 调用 Taku SDK 的点击回调
    [self trackNativeAdClick];
}

/// 自渲染广告点击关闭回调
- (void)lm_nativeAdDidClose:(LMNativeAd *)nativeAd adView:(nullable UIView *)adView {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeAdDidClose:");
    // 调用 Taku SDK 的关闭回调
    [self trackNativeAdClosed];
}

#pragma mark - LMNativeExpressAdDelegate (模板渲染)

/// 模板渲染广告加载成功
- (void)lm_nativeExpressAdLoaded:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAdLoaded: 模板广告加载成功");
    if (!self.hasCalledLoadSuccess) {
        self.hasCalledLoadSuccess = YES;

        if (!nativeExpressAd || !nativeExpressAd.expressView) {
            NSError *error = [NSError errorWithDomain:@"LMTakuNativeCustomEvent"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey : @"模板广告实例或视图为空"}];
            // 通过 completion block 返回错误
            if (self.requestCompletionBlock) {
                self.requestCompletionBlock(nil, error);
            }
            return;
        }

        // 构建 assets 数组，参考文档示例格式
        NSMutableArray *assets = [NSMutableArray array];

        // 创建单个 asset 字典，映射到 Taku SDK 的格式
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];

        // 必须设置：CustomEvent 对象
        [asset setValue:self forKey:kATAdAssetsCustomEventKey];

        // 必须设置：自定义对象（模板广告实例）
        [asset setValue:nativeExpressAd forKey:kATAdAssetsCustomObjectKey];

        // 设置：原生模板广告标识（标记为模板渲染）
        [asset setValue:@(YES) forKey:kATNativeADAssetsIsExpressAdKey];

        // 注意：模板广告视图不需要存储在 assets 中
        // Renderer 会直接从 nativeExpressAd.expressView 获取视图
        // 这里如果存储视图会导致 key 冲突（kATNativeADAssetsIsExpressAdKey 应该存储布尔值）

        // 设置：网络单元ID
        NSString *slotId = self.serverInfo[@"slot_id"];
        if (slotId) {
            [asset setValue:slotId forKey:kATNativeADAssetsUnitIDKey];
        }

        // 将 asset 添加到 assets 数组中
        [assets addObject:asset];

        // 调用 completion block 返回 assets 数组（Taku SDK 会处理后续的 trackNativeAdLoaded）
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock(assets, nil);
            NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAdLoaded: 已通过 completion block 返回 assets");
        } else {
            NSLog(@"⚠️ LMTakuNativeCustomEvent: requestCompletionBlock 为空");
        }
    }
}

/// 模板渲染广告加载失败
- (void)lm_nativeExpressAd:(LMNativeExpressAd *)nativeExpressAd didFailWithError:(NSError *)error {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAd:didFailWithError: %@", error);
    if (!self.hasCalledLoadFailed) {
        self.hasCalledLoadFailed = YES;
        // 通过 completion block 返回错误
        NSError *finalError = error
            ?: [NSError errorWithDomain:@"LMTakuNativeCustomEvent"
                                   code:-1
                               userInfo:@{NSLocalizedDescriptionKey : @"模板广告加载失败"}];
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock(nil, finalError);
        }
    }
}

/// 模板渲染广告视图渲染成功
- (void)lm_nativeExpressAdViewRenderSuccess:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAdViewRenderSuccess: 模板广告视图渲染成功");
    // 视图渲染成功，可以在这里进行额外的处理
}

/// 模板渲染广告视图渲染失败
- (void)lm_nativeExpressAdViewRenderFail:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAdViewRenderFail: 模板广告视图渲染失败");
    // 视图渲染失败，可以在这里进行错误处理
}

/// 模板渲染广告曝光回调
- (void)lm_nativeExpressAdViewWillExpose:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAdViewWillExpose: 模板广告曝光");
    // 调用 Taku SDK 的曝光回调
    [self trackNativeAdImpression];
}

/// 模板渲染广告点击回调
- (void)lm_nativeExpressAdViewDidClick:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAdViewDidClick: 模板广告点击");
    // 调用 Taku SDK 的点击回调
    [self trackNativeAdClick];
}

/// 模板渲染广告关闭回调
- (void)lm_nativeExpressAdDidClose:(LMNativeExpressAd *)nativeExpressAd {
    NSLog(@"LMTakuNativeCustomEvent lm_nativeExpressAdDidClose: 模板广告关闭");
    // 调用 Taku SDK 的关闭回调
    [self trackNativeAdClosed];
}

/// 获取网络单元 ID（用于 Taku SDK）
- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"] ?: @"";
}

@end
