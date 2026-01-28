//
//  LMBUMNativeAdData.h
//  LitemobSDK
//
//  穿山甲（BUM）信息流广告数据适配类
//  实现 BUMMediatedNativeAdData 协议，将 LMNativeAdDataObject 转换为 BUM 所需格式
//

#import <BUAdSDK/BUAdSDK.h>
#import <Foundation/Foundation.h>
#import <LitemobSDK/LMNativeAdDataObject.h>

NS_ASSUME_NONNULL_BEGIN

/// 穿山甲信息流广告数据适配类
/// 实现 BUMMediatedNativeAdData 协议，将 LMNativeAdDataObject 转换为 BUM 所需格式
@interface LMBUMNativeAdData : NSObject <BUMMediatedNativeAdData>

/// 初始化方法
/// @param dataObject 原始广告数据对象
- (instancetype)initWithDataObject:(LMNativeAdDataObject *)dataObject;

@end

NS_ASSUME_NONNULL_END
