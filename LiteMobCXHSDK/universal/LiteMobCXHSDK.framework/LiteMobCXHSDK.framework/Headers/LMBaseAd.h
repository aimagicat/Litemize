//
//  LMBaseAd.h
//  LiteMobCXHSDK
//
//  广告基类，管理广告共通部分
//

#import <Foundation/Foundation.h>
#import <LiteMobCXHSDK/LMAdSlot.h>
#import <UIKit/UIKit.h>

@class LMAdBid;

NS_ASSUME_NONNULL_BEGIN

/// 广告基类，提供共通功能和属性
@interface LMBaseAd : NSObject

/// 广告位配置（只读）
@property(nonatomic, strong, readonly) LMAdSlot *adSlot;

/// 是否已加载
@property(nonatomic, assign, readonly) BOOL isLoaded;

/// 广告竞价信息（只读）
@property(nonatomic, strong, readonly, nullable) LMAdBid *adBid;

/// 广告是否有效（未过期）
/// @return YES 表示广告有效，NO 表示已过期
- (BOOL)isAdValid;

/// 初始化方法
/// @param adSlot 广告位配置
/// @return 如果 adSlot 为空或类型不正确，返回 nil
- (nullable instancetype)initWithSlot:(LMAdSlot *)adSlot;

@end

NS_ASSUME_NONNULL_END
