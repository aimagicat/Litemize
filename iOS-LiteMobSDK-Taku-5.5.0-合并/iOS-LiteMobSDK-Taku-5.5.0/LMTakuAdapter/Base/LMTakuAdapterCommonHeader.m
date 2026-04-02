//
//  LMTakuAdapterCommonHeader.m
//  LitemobSDK
//
//  Taku/AnyThink 适配器公共头文件实现
//
//  Created by Neko on 2026/01/28.
//

#import "LMTakuAdapterCommonHeader.h"

NSString * const LMTakuAdapterVersion = @"1.0.0";

NSString * _Nonnull LMTakuSDKVersion(void) {
    // 获取 AnyThink SDK 版本号
    // 注意：这里需要根据实际的 AnyThink SDK API 来获取版本号
    // 如果 SDK 提供了版本号获取方法，应该调用相应的方法
    Class apiClass = NSClassFromString(@"ATAPI");
    if (apiClass && [apiClass respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [apiClass performSelector:@selector(sdkVersion)];
        if (version && version.length > 0) {
            return version;
        }
    }
    // 如果无法获取，返回默认值
    return @"6.4.94";
}
