# 异常检测模块 (CrashMonitor)

## 概述

异常检测模块用于捕获应用崩溃异常并在崩溃前上报信息。MVP 版本提供基础的崩溃捕获和上报功能。

## 功能特性

- ✅ 捕获 NSException 异常
- ✅ 捕获 Signal 信号崩溃（SIGABRT、SIGBUS、SIGFPE、SIGILL、SIGSEGV、SIGTRAP）
- ✅ 收集崩溃堆栈信息
- ✅ 收集设备信息、应用版本等上下文信息
- ✅ 支持自定义上报回调
- ✅ 支持代理模式监听崩溃事件

## 使用方法

### 1. 基础使用（在应用启动时启动监控）

```objc
// 在 AppDelegate 的 didFinishLaunchingWithOptions 中
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 启动崩溃监控
    [[LMCrashMonitor sharedMonitor] startMonitoring];
    
    return YES;
}
```

### 2. 使用类方法快速启用

```objc
// 启用崩溃监控
[LMCrashMonitor setEnabled:YES];

// 禁用崩溃监控
[LMCrashMonitor setEnabled:NO];
```

### 3. 自定义上报回调

```objc
// 设置自定义上报回调（例如：上传到服务器）
[LMCrashMonitor setReportHandler:^(LMCrashInfo *crashInfo) {
    // 将崩溃信息转换为 JSON
    NSDictionary *crashDict = @{
        @"type": @(crashInfo.crashType),
        @"reason": crashInfo.reason ?: @"",
        @"timestamp": @(crashInfo.timestamp),
        @"appVersion": crashInfo.appVersion ?: @"",
        @"deviceInfo": crashInfo.deviceInfo ?: @"",
        @"stackSymbols": crashInfo.stackSymbols ?: @[],
        @"extraInfo": crashInfo.extraInfo ?: @{}
    };
    
    // 上传到服务器（示例）
    // [YourNetworkManager uploadCrashInfo:crashDict];
    
    // 或保存到本地文件
    // [self saveCrashInfoToFile:crashDict];
}];
```

### 4. 使用代理模式

```objc
@interface YourClass : NSObject <LMCrashMonitorDelegate>
@end

@implementation YourClass

- (void)setupCrashMonitor {
    LMCrashMonitor *monitor = [LMCrashMonitor sharedMonitor];
    monitor.delegate = self;
    [monitor startMonitoring];
}

- (void)crashMonitorDidDetectCrash:(LMCrashInfo *)crashInfo {
    // 处理崩溃信息
    NSLog(@"检测到崩溃: %@", crashInfo.reason);
}

@end
```

### 5. 手动上报崩溃信息（用于测试）

```objc
LMCrashInfo *testCrashInfo = [[LMCrashInfo alloc] initWithType:LMCrashTypeException 
                                                         reason:@"测试崩溃"];
testCrashInfo.stackSymbols = @[@"测试堆栈1", @"测试堆栈2"];
[[LMCrashMonitor sharedMonitor] reportCrashInfo:testCrashInfo];
```

## 崩溃信息模型 (LMCrashInfo)

| 属性 | 类型 | 说明 |
|------|------|------|
| crashType | LMCrashType | 崩溃类型（Exception/Signal/Uncaught） |
| reason | NSString | 崩溃原因 |
| stackSymbols | NSArray<NSString *> | 崩溃堆栈信息 |
| timestamp | NSTimeInterval | 崩溃时间戳 |
| appVersion | NSString | 应用版本 |
| deviceInfo | NSString | 设备信息 |
| extraInfo | NSDictionary | 额外信息 |

## 注意事项

1. **启动时机**：应在应用启动时尽早启动崩溃监控，建议在 `didFinishLaunchingWithOptions` 中调用
2. **线程安全**：崩溃监控是线程安全的，可以在任何线程调用
3. **性能影响**：崩溃监控对应用性能影响极小，可以放心使用
4. **上报方式**：MVP 版本默认只记录日志，如需实际上报请设置自定义上报回调

## MVP 版本限制

- 默认上报方式为日志输出
- 不支持崩溃信息持久化存储
- 不支持崩溃信息批量上报
- 不支持崩溃信息去重

## 后续优化方向

- [ ] 崩溃信息本地持久化
- [ ] 崩溃信息批量上报
- [ ] 崩溃信息去重
- [ ] 崩溃趋势分析
- [ ] 崩溃信息加密传输

