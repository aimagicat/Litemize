//
//  LMSigmobNativeAdData.h
//  LitemobSDK
//
//  Sigmob 原生广告数据适配类
//  实现 AWMMediatedNativeAdData 协议，将 LMNativeAdDataObject 转换为 ToBid 所需格式
//

#import <Foundation/Foundation.h>
#import <LitemobSDK/LMNativeAdDataObject.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// Sigmob 原生广告数据适配类
/// 实现 AWMMediatedNativeAdData 协议，将 LMNativeAdDataObject 转换为 ToBid 所需格式
@interface LMSigmobNativeAdData : NSObject <AWMMediatedNativeAdData>

/// 初始化方法
/// @param dataObject 原始广告数据对象
- (instancetype)initWithDataObject:(LMNativeAdDataObject *)dataObject;

@end

NS_ASSUME_NONNULL_END

