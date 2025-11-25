//
//  LMNativeAdMaterialObject.h
//  LiteMobCXHSDK
//
//  信息流自渲染广告物料对象
//

#import <Foundation/Foundation.h>

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

/// 初始化方法
/// - Parameters:
///   - width: 素材宽度
///   - height: 素材高度
///   - url: 素材URL
- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height url:(nullable NSString *)url;

@end

NS_ASSUME_NONNULL_END
