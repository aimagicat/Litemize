# LMMockRuntimeHook 使用 LMRuntime 封装后的「最终效果」示例

以下为**假设 LMRuntime 提供对应封装后**，在 `LMMockRuntimeHook` 里的调用方式。便于对比当前手写实现，决定是否落地这些 API。

---

## 1. 基础实例方法 Swizzle（已有能力，可直接用）

**当前**：`swizzleMediaSiteManagerUpdateMediaSiteList`、`swizzleBaseAdSetAdLoaded` 手写 `class_getInstanceMethod` + `class_addMethod` + `method_exchangeImplementations`。

**封装后**：和 `swizzleBUSplashAdDelegateSplashAdClose` 一样，统一用链式 API，C 函数实现保留在 Mock 里只做业务逻辑。

```objc
// LMMediaSiteManager updateMediaSiteList:
+ (void)swizzleMediaSiteManagerUpdateMediaSiteList {
    LMSwizzleResult result = LMSwizzle(@"LMMediaSiteManager")
                                 .instanceMethod(@selector(updateMediaSiteList:))
                                 .withIMP((IMP)lm_mock_updateMediaSiteList)
                                 .swizzleAndSave(&_originalUpdateMediaSiteList);
    if (result == LMSwizzleResultSuccess) {
        LMLogInfo(@"LMMockRuntimeHook", @"已 Hook LMMediaSiteManager updateMediaSiteList:");
    } else {
        LMLogWarning(@"LMMockRuntimeHook", @"Hook 失败或类未加载，结果: %ld", (long)result);
    }
}

// LMBaseAd setAdLoaded:withAdObject:
+ (void)swizzleBaseAdSetAdLoaded {
    LMSwizzleResult result = LMSwizzle(@"LMBaseAd")
                                 .instanceMethod(@selector(setAdLoaded:withAdObject:))
                                 .withIMP((IMP)lm_mock_baseAdSetAdLoaded)
                                 .swizzleAndSave(&_originalBaseAdSetAdLoaded);
    if (result == LMSwizzleResultSuccess) {
        LMLogInfo(@"LMMockRuntimeHook", @"已 Hook LMBaseAd setAdLoaded:withAdObject:");
    } else {
        LMLogWarning(@"LMMockRuntimeHook", @"Hook 失败，结果: %ld", (long)result);
    }
}
```

**效果**：删除两处约 30+ 行手写 runtime 代码，C 函数 `lm_mock_updateMediaSiteList`、`lm_mock_baseAdSetAdLoaded` 不变，只负责「先调原实现 + 业务逻辑」。

---

## 2. Delegate 动态 Hook（setDelegate: 时对 delegate 类打补丁）

**当前**：`swizzleBUSplashAdDelegateSplashAdDidClose` 用 LMSwizzle hook `setDelegate:`，再在 C 函数里手写：判断 delegate 是否响应 `splashAdDidClose:closeType:`、备份 SEL、`class_addMethod`、`method_setImplementation`、NSMutableSet 去重等。

**假设 LMRuntime 提供**：

```objc
// 伪 API：在 setDelegate: 被调用时，对 delegate 的类动态 hook 指定方法（仅一次）
LMSwizzleResult LMHookDelegateMethodOnSetter(NSString *hostClassName,
                                             SEL setterSelector,           // setDelegate:
                                             SEL delegateMethodSelector,  // splashAdDidClose:closeType:
                                             void (^wrapper)(id delegate, NSInvocation *invokeOriginal));
```

**封装后调用效果**：

```objc
+ (void)swizzleBUSplashAdDelegateSplashAdDidClose {
    LMSwizzleResult result = LMHookDelegateMethodOnSetter(
        @"BUSplashAd",
        @selector(setDelegate:),
        @selector(splashAdDidClose:closeType:),
        ^(id delegate, NSInvocation *invokeOriginal) {
            // 业务：先打日志/弹窗，再决定何时 invokeOriginal
            id splashAd = nil;
            long long closeType = 0;
            [invokeOriginal getArgument:&splashAd atIndex:2];
            [invokeOriginal getArgument:&closeType atIndex:3];
            LMLogInfo(@"LMMockRuntimeHook", @"[BUSplashAdDelegate] splashAdDidClose:closeType: delegate=%@ closeType=%lld", delegate, closeType);
            dispatch_async(dispatch_get_main_queue(), ^{
                [LMMockRuntimeHook presentDebugLMSplashAfterThirdPartyCloseWithOriginalCloseBlock:^{
                    [invokeOriginal invoke];
                }];
            });
        });
    if (result == LMSwizzleResultSuccess) {
        LMLogInfo(@"LMMockRuntimeHook", @"已 Hook BUSplashAd setDelegate: → splashAdDidClose:closeType:");
    }
}
```

**效果**：不再需要 `_lm_backupSplashAdDidCloseCloseTypeSelector`、`_swizzledBUSplashDelegateClasses`、`lm_mock_BUSplashAd_setDelegate_`、`lm_mock_splashAdDidClose_closeType_` 等 C 函数和静态变量，全部由 LMRuntime 内部处理。

---

## 3. 弹窗确认后再调原实现（Wrap + 主线程弹窗）

**当前**：`swizzleABUCsjSplashAdDidClose`、`swizzleCSJSplashViewPSkipTapped`、`replaceJTHardwareShakeManagerRegistDetectionWithEmpty` 各自写 C 函数：打日志、`dispatch_async(main)` 弹窗、点确定后调原实现或 no-op。

**假设 LMRuntime 提供**：

```objc
// 伪 API：替换为「主线程弹窗，点确定后执行原实现」
LMSwizzleResult LMWrapInstanceMethodWithConfirmAlert(NSString *className,
                                                     SEL selector,
                                                     NSString *alertTitle,
                                                     NSString *alertMessage,
                                                     void (^ _Nullable beforeInvokeOriginal)(id self, NSInvocation *inv));

// 仅弹窗、不调原实现的版本（用于 JTHardwareShakeManager）
LMSwizzleResult LMReplaceInstanceMethodWithAlert(NSString *className,
                                                 SEL selector,
                                                 NSString *alertTitle,
                                                 NSString *alertMessage);
```

**封装后调用效果**：

```objc
// ABUCsjSplashAdapter splashAdDidClose:closeType:
+ (void)swizzleABUCsjSplashAdDidClose {
    LMSwizzleResult result = LMWrapInstanceMethodWithConfirmAlert(
        @"ABUCsjSplashAdapter",
        @selector(splashAdDidClose:closeType:),
        @"开屏广告已关闭 (Csj)",
        @"点击确定后继续执行原回调",
        ^(id self, NSInvocation *inv) {
            id splashAd = nil;
            long long closeType = 0;
            [inv getArgument:&splashAd atIndex:2];
            [inv getArgument:&closeType atIndex:3];
            LMLogInfo(@"LMMockRuntimeHook", @"[ABUCsjSplashAdapter] splashAdDidClose:closeType: closeType=%lld", closeType);
        });
    // ...
}

// CSJSplashView p_skipTapped:
+ (void)swizzleCSJSplashViewPSkipTapped {
    LMWrapInstanceMethodWithConfirmAlert(
        @"CSJSplashView",
        @selector(p_skipTapped:),
        @"CSJSplashView 跳过",
        @"点击了开屏「跳过」，点击确定后继续执行原逻辑",
        nil);
}

// JTHardwareShakeManager 仅弹窗、不调原实现
+ (void)replaceJTHardwareShakeManagerRegistDetectionWithEmpty {
    LMReplaceInstanceMethodWithAlert(
        @"JTHardwareShakeManager",
        @selector(registDetectionWithDelegate:threshold:),
        @"推啊sdk摇一摇检测",
        @"推啊摇一摇检测功能 已被禁用");
}
```

**效果**：删除 `lm_mock_ABUCsjSplashAdapter_splashAdDidClose_closeType_`、`lm_mock_CSJSplashView_p_skipTapped_`、`lm_alert_registDetectionWithDelegate_threshold_` 三个 C 函数及对应静态 IMP 变量，只保留「配置类名 + SEL + 文案」。

---

## 4. UIView 子类过滤 Hook（仅对某子类生效）

**当前**：`forceHideJTAdBaseViewShakeView` 保存 `_targetShakeViewClass`，对 `UIView` 的 `setHidden:`、`willMoveToSuperview:`、`setAlpha:` 做 LMSwizzle，三个 C 函数里都写 `if (_targetShakeViewClass && [self isKindOfClass:_targetShakeViewClass]) { ... } else { 调原实现 }`。

**假设 LMRuntime 提供**：

```objc
// 伪 API：对 UIView 的实例方法做 hook，仅当 receiver 是 targetSubclass 或其子类时走 customBlock，否则调原实现
LMSwizzleResult LMHookUIViewMethodForSubclass(NSString *targetSubclassClassName,
                                              SEL selector,
                                              void (^customBlock)(id view, void (^callOriginal)(void)));
```

**封装后调用效果**：

```objc
+ (void)forceHideJTAdBaseViewShakeView {
    // setHidden: → 对 JTAdBaseViewShakeView 及其子类强制 YES
    LMHookUIViewMethodForSubclass(@"JTAdBaseViewShakeView", @selector(setHidden:),
        ^(id view, void (^callOriginal)(void)) {
            callOriginal();  // 但传入 YES，由 LMRuntime 在内部封装时写死
        });
    // willMoveToSuperview: → 有 superview 时移除
    LMHookUIViewMethodForSubclass(@"JTAdBaseViewShakeView", @selector(willMoveToSuperview:),
        ^(id view, void (^callOriginal)(void)) {
            // 仅当 newSuperview != nil 时不调原实现，直接移除；否则 callOriginal
            // 具体语义可由 API 设计时用枚举或 block 参数区分
        });
    // setAlpha: → 强制 0
    LMHookUIViewMethodForSubclass(@"JTAdBaseViewShakeView", @selector(setAlpha:),
        ^(id view, void (^callOriginal)(void)) {
            callOriginal();  // 内部传 0
        });
}
```

或更简化为「预设行为」：

```objc
LMSwizzleResult LMForceHideSubclassOfUIView(NSString *shakeViewClassName);
// 内部对 setHidden:/willMoveToSuperview:/setAlpha: 做统一处理，调用方一行搞定
+ (void)forceHideJTAdBaseViewShakeView {
    LMForceHideSubclassOfUIView(@"JTAdBaseViewShakeView");
}
```

**效果**：删除 `_targetShakeViewClass`、`lm_mock_setHidden_`、`lm_mock_willMoveToSuperview_`、`lm_mock_setAlpha_` 及三处 LMSwizzle 重复代码。

---

## 5. 小结（按优先级）

| 能力 | 当前代码量（约） | 封装后调用 | 说明 |
|------|------------------|------------|------|
| 基础实例方法 swizzle | 手写 ~35 行/处 × 2 | 链式 5～8 行/处 | **已有 LMSwizzle**，只需把 LMMediaSiteManager / LMBaseAd 改成链式 + withIMP + swizzleAndSave，无需新 API。 |
| Delegate 动态 hook | ~80 行 + 多个静态变量 | 一个配置 + 一个 block | 需 LMRuntime 新增 `LMHookDelegateMethodOnSetter`。 |
| 弹窗后调原实现 | ~60 行/处 × 3 | 类名 + SEL + title + message | 需 LMRuntime 新增 `LMWrapInstanceMethodWithConfirmAlert` / `LMReplaceInstanceMethodWithAlert`。 |
| UIView 子类过滤 | ~90 行 | 一行或三行配置 | 需 LMRuntime 新增 `LMHookUIViewMethodForSubclass` 或 `LMForceHideSubclassOfUIView`。 |

**建议**：先做 **1（直接用现有 LMSwizzle）** 减少手写；若后续 Mock 场景增多，再按需实现 2、3、4 的封装，这样「最终效果」就会和上面示例一致。
