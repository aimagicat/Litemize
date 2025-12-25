//
//  LMBUMExpressNativeViewWrapper.m
//  LitemizeSDK
//
//  穿山甲（BUM）信息流模板广告视图包装器实现
//

#import "LMBUMExpressNativeViewWrapper.h"
#import "LMBUMNativeAdapter.h"
#import <LitemizeSDK/LMNativeExpressAd.h>

@implementation LMBUMExpressNativeViewWrapper

- (instancetype)initWithExpressAd:(LMNativeExpressAd *)expressAd adapter:(LMBUMNativeAdapter *)adapter {
    self = [super init];
    if (self) {
        _expressAd = expressAd;
        _adapter = adapter;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"LMBUMExpressNativeViewWrapper dealloc");
}

@end
