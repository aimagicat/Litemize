//
//  LMSigmobNativeAdapter.m
//  LitemizeSDK
//
//  Sigmob Native 原生广告 Adapter 实现
//

#import "LMSigmobNativeAdapter.h"
#import "../LMSigmobAdapterLog.h"
#import "LMSigmobAdProtocol.h"
#import "LMSigmobNativeAdsManager.h"
#import "LMSigmobNativeExpressAdManager.h"

@interface LMSigmobNativeAdapter ()

@property(nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property(nonatomic, strong) id<LMSigmobAdProtocol> nativeAdManager;

@end

@implementation LMSigmobNativeAdapter

#pragma mark - AWMCustomNativeAdapter Protocol Implementation

- (instancetype)initWithBridge:(id<AWMCustomNativeAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)size parameter:(AWMParameter *)parameter {
    LMSigmobLog(@"Native loadAdWithPlacementId: %@, adSize: %@, parameter: %@", placementId, NSStringFromCGSize(size), parameter);

    // 根据 templateType 参数判断使用自渲染还是模板渲染
    // templateType == 1 表示自渲染，其他值表示模板渲染
    int templateType = [[parameter.customInfo objectForKey:@"templateType"] intValue];
    if (templateType == 1) {
        // 使用自渲染广告管理器
        self.nativeAdManager = [[LMSigmobNativeAdsManager alloc] initWithBridge:self.bridge adapter:self];
    } else {
        // 使用模板渲染广告管理器
        self.nativeAdManager = [[LMSigmobNativeExpressAdManager alloc] initWithBridge:self.bridge adapter:self];
    }

    // 调用 Manager 的加载方法
    [self.nativeAdManager loadAdWithPlacementId:placementId adSize:size parameter:parameter];
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    LMSigmobLog(@"Native didReceiveBidResult: %@", result);
    [self.nativeAdManager didReceiveBidResult:result];
}

- (BOOL)mediatedAdStatus {
    // 返回广告是否准备好
    // 由于具体的广告状态由 Manager 管理，这里返回 YES 表示已初始化
    // 实际的广告状态检查由 Manager 内部处理
    return self.nativeAdManager != nil;
}

- (void)dealloc {
    LMSigmobLog(@"Native dealloc");
}

@end
