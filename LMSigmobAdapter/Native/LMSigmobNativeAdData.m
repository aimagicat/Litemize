//
//  LMSigmobNativeAdData.m
//  LitemobSDK
//
//  Sigmob 原生广告数据适配类实现
//

#import "LMSigmobNativeAdData.h"
#import <LitemobSDK/LMNativeAdDataObject.h>

@interface LMSigmobNativeAdData ()

@property(nonatomic, strong) LMNativeAdDataObject *dataObject;

@end

@implementation LMSigmobNativeAdData

// 声明动态属性，避免自动合成警告
@dynamic title, desc, iconUrl, callToAction, rating, imageUrlList, adMode, adType, interactionType, networkId, videoCoverImage,
    videoUrl, imageModelList;

- (instancetype)initWithDataObject:(LMNativeAdDataObject *)dataObject {
    if (self = [super init]) {
        _dataObject = dataObject;
    }
    return self;
}

#pragma mark - AWMMediatedNativeAdData

- (NSString *)title {
    return self.dataObject.title ?: @"";
}

- (NSString *)desc {
    return self.dataObject.desc ?: @"";
}

- (NSString *)iconUrl {
    return self.dataObject.iconUrl ?: @"";
}

- (NSString *)callToAction {
    // LitemobSDK 没有提供 callToAction 字段，使用默认值
    return @"立即下载";
}

- (double)rating {
    // LitemobSDK 没有提供 rating 字段，返回默认值 0
    return 0.0;
}

- (AWMMediatedNativeAdMode)adMode {
    // 根据素材类型判断广告模式
    if (self.dataObject.isVideo) {
        // 视频广告
        return AWMMediatedNativeAdModeVideo;
    } else if (self.dataObject.materialList && self.dataObject.materialList.count > 1) {
        // 多图
        return AWMMediatedNativeAdModeGroupImage;
    } else if (self.dataObject.materialList && self.dataObject.materialList.count == 1) {
        // 单图
        return AWMMediatedNativeAdModeLargeImage;
    }
    // 默认大图
    return AWMMediatedNativeAdModeLargeImage;
}

- (NSArray<NSString *> *)imageUrlList {
    // 返回图片 URL 列表（只包含非视频素材）
    NSMutableArray<NSString *> *imageUrls = [NSMutableArray array];
    if (self.dataObject.materialList && self.dataObject.materialList.count > 0) {
        for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
            // 只处理非视频素材（图片）
            if (!material.isVideo && material.materialUrl && material.materialUrl.length > 0) {
                [imageUrls addObject:material.materialUrl];
            }
        }
    }
    return imageUrls;
}

- (AWMNativeAdSlotAdType)adType {
    // 广告类型（普通广告，通常枚举值从 0 开始）
    // LitemobSDK 没有提供 adType 字段，返回默认值 0
    return (AWMNativeAdSlotAdType)0;
}

- (AWMNativeAdInteractionType)interactionType {
    // 交互类型（下载，通常枚举值从 0 开始，1 表示下载）
    // LitemobSDK 没有提供 interactionType 字段，返回默认值 1（下载）
    return (AWMNativeAdInteractionType)1;
}

- (WindMillAdn)networkId {
    // 网络 ID（标识广告来源网络）
    // 返回自定义网络标识
    return WindMillAdnCustom; // 对应 ToBid SDK 中的自定义网络
}

- (NSString *)videoCoverImage {
    // 视频封面图 URL
    if (self.dataObject.isVideo && self.dataObject.materialList.count > 0) {
        // 查找第一个视频物料的封面图
        for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
            if (material.isVideo && material.materialCoverUrl && material.materialCoverUrl.length > 0) {
                return material.materialCoverUrl;
            }
        }
    }
    return nil;
}

- (NSString *)videoUrl {
    // 视频 URL
    if (self.dataObject.isVideo && self.dataObject.materialList.count > 0) {
        // 查找第一个视频物料
        for (LMNativeAdMaterialObject *material in self.dataObject.materialList) {
            if (material.isVideo && material.materialUrl && material.materialUrl.length > 0) {
                return material.materialUrl;
            }
        }
    }
    return nil;
}

- (NSArray *)imageModelList {
    // 图片模型列表（返回包含图片信息的对象数组）
    // 如果 ToBid SDK 需要特定的图片模型对象，这里需要根据实际需求实现
    // 暂时返回 nil，使用 imageUrlList 代替
    return nil;
}

@end
