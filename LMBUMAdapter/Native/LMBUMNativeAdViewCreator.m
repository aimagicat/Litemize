//
//  LMBUMNativeAdViewCreator.m
//  LitemizeSDK
//
//  穿山甲（BUM）信息流广告视图创建器实现
//

#import "LMBUMNativeAdViewCreator.h"

@interface LMBUMNativeAdViewCreator ()

@property(nonatomic, strong) LMNativeAd *nativeAd;
@property(nonatomic, strong) UIView *mediaView;
@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation LMBUMNativeAdViewCreator

- (instancetype)initWithNativeAd:(LMNativeAd *)nativeAd viewDelegate:(id)delegate {
    if (self = [super init]) {
        _nativeAd = nativeAd;
        // 设置代理
        if (nativeAd && delegate) {
            nativeAd.delegate = delegate;
        }

        // 创建媒体视图（用于展示图片或视频）
        _mediaView = [[UIView alloc] init];
        _mediaView.backgroundColor = [UIColor clearColor];

        // 创建标题标签
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = nativeAd.dataObject.title;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 2;
    }
    return self;
}

#pragma mark - BUMMediatedNativeAdViewCreator

- (UIView *)mediaView {
    return _mediaView;
}

- (UILabel *)titleLabel {
    return _titleLabel;
}

@end
