//
//  LMNativeAdDataObject.h
//  LitemizeSDK
//
//  信息流自渲染广告数据对象（Model）
//  包含 LMNativeAdMaterialObject 和 LMNativeAdDataObject 两个类
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 信息流自渲染广告物料对象
/// - Note: 表示广告中的单个素材（图片、视频等）
@interface LMNativeAdMaterialObject : NSObject

/// 素材宽度（像素），如果广告平台返回则有值
@property(nonatomic, assign) NSInteger materialWidth;

/// 素材高度（像素），如果广告平台返回则有值
@property(nonatomic, assign) NSInteger materialHeight;

/// 素材URL（图片URL或视频URL）
@property(nonatomic, copy, nullable) NSString *materialUrl;

/// 是否视频素材
@property(nonatomic, assign) BOOL isVideo;

/// 视频时长（秒）
@property(nonatomic, assign) NSInteger materialDuration;

/// 视频静音类型
@property(nonatomic, assign) BOOL materialMute;

/// 视频封面图URL
@property(nonatomic, copy, nullable) NSString *materialCoverUrl;

/// 初始化方法
/// - Parameters:
///   - width: 素材宽度
///   - height: 素材高度
///   - url: 素材URL
- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height url:(nullable NSString *)url;

@end

/// 信息流自渲染广告数据对象（Model）
/// - Note: 内部使用MVC模式，此为Model层
@interface LMNativeAdDataObject : NSObject

/// 应用名称（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appName;

/// 应用图标 URL（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appIconUrl;

/// 应用 Bundle ID（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appBundle;

/// 应用大小（字节，来自广告应用信息）
@property(nonatomic, assign) NSUInteger appSize;

/// 开发者名称（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appDeveloper;

/// 权限说明（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appPermission;

/// 隐私政策 URL（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appPrivacyPolicy;

/// 应用描述（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appDesc;

/// 应用版本号（来自广告应用信息）
@property(nonatomic, copy, nullable) NSString *appVersion;

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

/// 广告图标图片（UIImage对象，如果有）
@property(nonatomic, strong, nullable) UIImage *adIcon;

/// 是否视频广告
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
