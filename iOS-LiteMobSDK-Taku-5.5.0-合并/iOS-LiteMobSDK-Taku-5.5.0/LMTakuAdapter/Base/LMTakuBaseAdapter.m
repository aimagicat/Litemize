//
//  LMTakuBaseAdapter.m
//  LitemobSDK
//
//  Taku/AnyThink 基础适配器实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuBaseAdapter.h"
#import "LMTakuInitAdapter.h"

@implementation LMTakuBaseAdapter

#pragma mark - ATBaseMediationAdapter Implementation

/// 返回初始化适配器的类名
/// @return 初始化适配器类
- (Class)initializeClassName {
    return [LMTakuInitAdapter class];
}

/// 获取 C2S 竞价扩展信息
/// @param ecpmString LitemobSDK 返回的 ECPM 字符串（单位：分）
/// @discussion 将价格封装为 AnyThink 所需的扩展字段，币种统一使用人民币分
+ (NSDictionary<NSString *, id> *)getC2SInfo:(NSString *)ecpmString {
    if (ecpmString.length == 0) {
        return @{};
    }

    // 防御：价格不能为负
    if ([ecpmString doubleValue] < 0) {
        ecpmString = @"0";
    }

    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    // 价格（单位：分）
    [infoDic AT_setDictValue:ecpmString key:ATAdSendC2SBidPriceKey];
    // 币种：人民币分
    [infoDic AT_setDictValue:@(ATBiddingCurrencyTypeCNYCents) key:ATAdSendC2SCurrencyTypeKey];
    return [infoDic copy];
}

@end
