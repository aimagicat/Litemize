#import <Foundation/Foundation.h>

NS_INLINE BOOL LMSigmobBridgeCanRespond(id _Nullable bridge, SEL _Nonnull selector) {
    return bridge && [(id)bridge respondsToSelector:selector];
}
