//
//  LMSplashSelfRenderAdDataObject.h
//  LitemizeSDK
//
//  开屏自渲染广告数据对象（Model）
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 开屏自渲染广告物料对象
/// - Note: 表示开屏广告中的单个素材（图片、视频等）
@interface LMSplashSelfRenderAdMaterialObject : NSObject

/// 素材宽度（像素），如果广告平台返回则有值
@property(nonatomic, assign) NSInteger materialWidth;

/// 素材高度（像素），如果广告平台返回则有值
@property(nonatomic, assign) NSInteger materialHeight;

/// 素材URL（图片URL或视频URL）
@property(nonatomic, copy, nullable) NSString *materialUrl;

/// 初始化方法
/// - Parameters:
///   - width: 素材宽度
///   - height: 素材高度
///   - url: 素材URL
- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height url:(nullable NSString *)url;

@end

/// 开屏自渲染广告数据对象（Model）
/// - Note: 内部使用MVC模式，此为Model层
@interface LMSplashSelfRenderAdDataObject : NSObject

/// 广告标题
@property(nonatomic, copy, nullable) NSString *title;

/// 广告描述
@property(nonatomic, copy, nullable) NSString *desc;

/// 广告图标URL
@property(nonatomic, copy, nullable) NSString *iconUrl;

/// 广告物料集合（单图、多图、视频）
/// - Note: 开屏广告通常为单图或单视频
@property(nonatomic, strong, nullable) NSArray<LMSplashSelfRenderAdMaterialObject *> *materialList;

/// 广告价格（单位：分）
/// - Note: 如果广告平台返回则有值，否则为 -1
@property(nonatomic, assign) NSInteger price;

/// 是否视频素材
@property(nonatomic, assign) BOOL isVideo;

/// 是否默认静音（视频广告）
/// - Note: YES=默认静音，NO=默认播放声音
///         如果 site.videoSound == 1（有声音），则 defaultMuted = NO
@property(nonatomic, assign) BOOL defaultMuted;

/// 是否自动播放（视频广告）
/// - Note: YES=自动播放，NO=不自动播放
///         根据 site.videoPlay 的值设置：1=WIFI自动播放，2=有网络自动播放，3=不自动播放
@property(nonatomic, assign) BOOL shouldAutoPlay;

/// 初始化方法
/// - Parameters:
///   - title: 广告标题
///   - desc: 广告描述
///   - iconUrl: 图标URL
///   - materialList: 物料列表
- (instancetype)initWithTitle:(nullable NSString *)title
                         desc:(nullable NSString *)desc
                      iconUrl:(nullable NSString *)iconUrl
                 materialList:(nullable NSArray<LMSplashSelfRenderAdMaterialObject *> *)materialList;

@end

NS_ASSUME_NONNULL_END
