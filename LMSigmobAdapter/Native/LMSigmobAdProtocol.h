//
//  LMSigmobAdProtocol.h
//  LitemobSDK
//
//  Sigmob Native 广告协议
//  定义自渲染和模板渲染广告管理器的统一接口
//

#import <Foundation/Foundation.h>
#import <WindMillSDK/WindMillSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// Sigmob Native 广告协议
/// 用于统一自渲染和模板渲染广告管理器的接口
@protocol LMSigmobAdProtocol <NSObject>

/// 加载广告
/// @param placementId 广告位ID
/// @param size 广告尺寸
/// @param parameter 请求参数
- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)size parameter:(AWMParameter *)parameter;

/// 接收竞价结果
/// @param result 竞价结果
- (void)didReceiveBidResult:(AWMMediaBidResult *)result;

@end

NS_ASSUME_NONNULL_END
