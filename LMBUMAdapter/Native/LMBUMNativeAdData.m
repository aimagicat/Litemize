//
//  LMBUMNativeAdData.m
//  LitemizeSDK
//
//  穿山甲（BUM）信息流广告数据适配类实现
//

#import "LMBUMNativeAdData.h"

@interface LMBUMNativeAdData ()

@property(nonatomic, strong) LMNativeAdDataObject *dataObject;

@end

@implementation LMBUMNativeAdData

- (instancetype)initWithDataObject:(LMNativeAdDataObject *)dataObject {
    if (self = [super init]) {
        _dataObject = dataObject;
    }
    return self;
}

#pragma mark - BUMMediatedNativeAdData

- (BUMMediatedNativeAdCallToType)callToType {
    return BUMMediatedNativeAdCallToTypeOthers;
}

- (NSArray<BUMImage *> *)imageList {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    if (self.dataObject.materialList && self.dataObject.materialList.count > 0) {
        for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
            // 只处理非视频素材（图片）
            if (!material.isVideo && material.materialUrl) {
                BUMImage *aImg = [[BUMImage alloc] init];
                aImg.width = material.materialWidth > 0 ? material.materialWidth : 0;
                aImg.height = material.materialHeight > 0 ? material.materialHeight : 0;
                aImg.scale = 1;
                aImg.imageURL = [NSURL URLWithString:material.materialUrl];
                aImg.image = nil; // 图片需要异步加载
                [images addObject:aImg];
            }
        }
    }
    return images;
}

- (BUMImage *)icon {
    BUMImage *aIcon = [[BUMImage alloc] init];
    if (self.dataObject.iconUrl) {
        aIcon.imageURL = [NSURL URLWithString:self.dataObject.iconUrl];
    }
    if (self.dataObject.adIcon) {
        aIcon.image = self.dataObject.adIcon;
    }
    // 如果没有设置宽高，使用默认值
    aIcon.width = 0;
    aIcon.height = 0;
    aIcon.scale = 1;
    return aIcon;
}

- (NSString *)adTitle {
    return self.dataObject.title ?: @"";
}

- (NSString *)adDescription {
    return self.dataObject.desc ?: @"";
}

- (NSString *)source {
    return @"广告"; // LitemizeSDK 没有提供 source 字段，使用默认值
}

- (NSString *)buttonText {
    return @"立即下载"; // LitemizeSDK 没有提供 buttonText 字段，使用默认值
}

- (NSString *)appPrice {
    if (self.dataObject.price >= 0) {
        // price 单位是分，转换为元
        CGFloat priceInYuan = self.dataObject.price / 100.0;
        return [NSString stringWithFormat:@"%.2f", priceInYuan];
    }
    return nil;
}

- (NSString *)videoUrl {
    if (self.dataObject.isVideo && self.dataObject.materialList.count > 0) {
        // 查找第一个视频物料
        for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
            if (material.isVideo && material.materialUrl) {
                return material.materialUrl;
            }
        }
    }
    return nil;
}

- (BUMMediatedNativeAdMode)imageMode {
    // 参考 XXXKsNativeAdData 的实现方式
    if (self.dataObject.isVideo) {
        return BUMMediatedNativeAdModeLandscapeVideo; // 视频广告
    } else if (self.dataObject.materialList.count > 1) {
        return BUMMediatedNativeAdModeGroupImage; // 多图
    } else if (self.dataObject.materialList.count == 1) {
        return BUMMediatedNativeAdModeLargeImage; // 单图
    }
    return BUMMediatedNativeAdModeLargeImage; // 默认大图
}

- (NSInteger)score {
    return 0; // LitemizeSDK 没有提供 score 字段
}

- (NSInteger)commentNum {
    return 0; // LitemizeSDK 没有提供 commentNum 字段
}

- (NSInteger)appSize {
    return 0; // LitemizeSDK 没有提供 appSize 字段
}

- (NSInteger)videoDuration {
    if (self.dataObject.isVideo && self.dataObject.materialList.count > 0) {
        // 查找第一个视频物料
        for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
            if (material.isVideo && material.materialDuration > 0) {
                return material.materialDuration;
            }
        }
    }
    return 0;
}

- (CGFloat)videoAspectRatio {
    if (self.dataObject.isVideo && self.dataObject.materialList.count > 0) {
        // 查找第一个视频物料
        for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
            if (material.isVideo && material.materialWidth > 0 && material.materialHeight > 0) {
                return (CGFloat)material.materialWidth / (CGFloat)material.materialHeight;
            }
        }
    }
    return 0;
}

- (NSDictionary *)mediaExt {
    return nil; // LitemizeSDK 没有提供 mediaExt 字段
}

- (BUMImage *)adLogo {
    // LitemizeSDK 没有提供 adLogo 字段
    BUMImage *sdkLogo = [[BUMImage alloc] init];
    return sdkLogo;
}

- (NSString *)brandName {
    return self.dataObject.title ?: @""; // 使用标题作为品牌名
}

@end
