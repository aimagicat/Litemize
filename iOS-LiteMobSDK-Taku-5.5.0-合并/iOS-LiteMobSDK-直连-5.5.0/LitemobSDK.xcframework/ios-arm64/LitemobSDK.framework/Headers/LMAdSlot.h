//
//  LMAdSlot.h
//  LitemobSDK
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 广告位类型（MVP 精简）
typedef NS_ENUM(NSInteger, LMAdSlotType) {
    LMAdSlotTypeSplash = 0,
    LMAdSlotTypeRewardedVideo,
    LMAdSlotTypeInterstitial,
    LMAdSlotTypeBanner, ///< Banner 横幅广告
    LMAdSlotTypeNativeExpress, ///< 信息流模版渲染广告
    LMAdSlotTypeNative, ///< 信息流自渲染广告
};

/// 广告位配置，参考 BUAdSlot 风格
@interface LMAdSlot : NSObject

@property(nonatomic, copy) NSString *slotId; ///< 广告位 ID
@property(nonatomic, assign) LMAdSlotType slotType; ///< 广告位类型
@property(nonatomic, assign) CGSize imgSize; ///< 期望渲染尺寸（如开屏）

+ (instancetype)slotWithId:(NSString *)slotId type:(LMAdSlotType)type;

@end

NS_ASSUME_NONNULL_END
