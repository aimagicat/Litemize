//
//  LMNativeAdDataObject.h
//  LiteMobCXHSDK
//
//  信息流自渲染广告数据对象（Model）
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <LiteMobCXHSDK/LMNativeAdMaterialObject.h>

NS_ASSUME_NONNULL_BEGIN

/// 广告平台枚举
typedef NS_ENUM(NSInteger, LMNativeAdPlatform) {
  LMNativeAdPlatform_Unknown = 0, ///< 未知
  LMNativeAdPlatform_MVlion,      ///< 瑞狮
  LMNativeAdPlatform_GDT,         ///< 广点通
  LMNativeAdPlatform_CSJ,         ///< 穿山甲
  LMNativeAdPlatform_JD,           ///< 京东
};

/// 信息流自渲染广告数据对象（Model）
/// - Note: 内部使用MVC模式，此为Model层
@interface LMNativeAdDataObject : NSObject

/// 广告标题
@property(nonatomic, copy, nullable) NSString *title;

/// 广告描述
@property(nonatomic, copy, nullable) NSString *desc;

/// 广告图标URL
@property(nonatomic, copy, nullable) NSString *iconUrl;

/// 广告物料集合（单图、多图、视频）
/// - Note: 目前只有图片，暂不考虑视频
@property(nonatomic, strong, nullable) NSArray<LMNativeAdMaterialObject *> *materialList;

/// 广告价格（单位：分）
/// - Note: 如果广告平台返回则有值，否则为 -1
@property(nonatomic, assign) NSInteger price;

/// 广告平台
@property(nonatomic, assign) LMNativeAdPlatform platform;

/// 各个广告平台的adIcon（瑞狮、广点通、穿山甲、京东等）
/// - Note: 如果这些广告平台返回adIcon则有值，否则则没有
///         特别的：当platform = LMNativeAdPlatform_MVlion时，如果对Menta广告平台的广告不满意，
///         可以从文档中自行下载瑞狮icon，然后自定义布局
@property(nonatomic, strong, nullable) UIImage *adIcon;

/// 是否视频素材
@property(nonatomic, assign) BOOL isVideo;

/// 初始化方法
/// - Parameters:
///   - title: 广告标题
///   - desc: 广告描述
///   - iconUrl: 图标URL
///   - materialList: 物料列表
- (instancetype)initWithTitle:(nullable NSString *)title
                          desc:(nullable NSString *)desc
                       iconUrl:(nullable NSString *)iconUrl
                  materialList:(nullable NSArray<LMNativeAdMaterialObject *> *)materialList;

@end

NS_ASSUME_NONNULL_END

