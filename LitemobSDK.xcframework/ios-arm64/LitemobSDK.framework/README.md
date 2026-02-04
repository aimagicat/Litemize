# LMGCDKit

优雅的 GCD 封装库，避免中括号调用，支持链式调用。

## 特性

- ✅ 链式调用，避免中括号
- ✅ 可取消的任务对象
- ✅ 自动处理弱引用
- ✅ 类型安全，API 清晰
- ✅ 不依赖 RunLoop，更可靠

## 快速开始

### 基础用法

```objc
// 主线程执行
LMGCD.main(^{
    NSLog(@"主线程执行");
});

// 后台线程执行
LMGCD.background(^{
    NSLog(@"后台线程执行");
});
```

### 延迟执行（可取消）

```objc
// 便捷方法
LMGCDTask *task = LMGCD.mainAfter(3.0, ^{
    NSLog(@"3秒后执行");
});
[task cancel]; // 取消任务

// 链式调用
LMGCDTask *task2 = LMGCD.main.after(2.0).execute(^{
    NSLog(@"2秒后执行");
});
```

### 定时器/轮询

```objc
// 基础定时器（每秒执行）
LMGCDTimer *timer = LMGCD.timer(1.0, ^{
    NSLog(@"定时器触发");
});

// 取消定时器
[timer cancel];

// 暂停和恢复
[timer suspend];
[timer resume];

// 轮询：延迟3秒后开始，每1秒执行一次，最多执行5次
LMGCDTimer *pollTimer = LMGCD.poll(1.0, 3.0, 5, ^{
    NSLog(@"轮询执行，已执行次数：%lu", (unsigned long)pollTimer.executionCount);
});

// 无限轮询（延迟2秒后开始，每2秒执行一次）
LMGCDTimer *infinitePoll = LMGCD.poll(2.0, 2.0, 0, ^{
    NSLog(@"无限轮询");
});

// 状态查询
if (pollTimer.isRunning) {
    NSLog(@"定时器正在运行");
}
if (pollTimer.isSuspended) {
    NSLog(@"定时器已暂停");
}
NSLog(@"已执行次数：%lu", (unsigned long)pollTimer.executionCount);
```

### 弱引用（自动处理循环引用）

```objc
// 弱引用执行
LMGCDTask *task = LMGCD.mainWeak(self, ^(typeof(self) strongSelf) {
    if (strongSelf) {
        NSLog(@"对象存在");
    }
});

// 弱引用延迟执行
LMGCDTask *task2 = LMGCD.mainAfter(3.0).weak(self, ^(typeof(self) strongSelf) {
    if (strongSelf) {
        NSLog(@"3秒后执行");
    }
});
```

### 同步执行

```objc
// 同步主线程
LMGCD.syncMain(^{
    NSLog(@"同步主线程执行");
});

// 同步后台线程
LMGCD.syncBackground(^{
    NSLog(@"同步后台线程执行");
});
```

### 指定队列

```objc
// 指定队列 + 延迟 + 执行
LMGCDTask *task = LMGCD.queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
    .after(1.5)
    .execute(^{
        NSLog(@"1.5秒后在高优先级队列执行");
    });
```

### 保持任务存活（keepAlive）

在某些场景下，需要确保 `LMGCDTask` 在执行完成前不会被释放（例如在 `+load` 方法中使用延迟执行）。`keepAlive` 方法可以自动管理 task 的生命周期。

#### 不调用 keepAlive（默认行为）

如果不调用 `keepAlive` 方法，task 的生命周期由调用者管理：

```objc
// 不调用 keepAlive，task 的生命周期由调用者管理
LMGCDTask *task = LMGCD.main.after(0.5).execute(^{
    // 如果调用者没有强引用 task，task 可能会在 block 执行前被释放
    // 建议：如果需要在 block 执行前保持 task 存活，请使用 keepAlive
});

// 如果需要保持 task 存活，需要手动强引用
self.myTask = task; // 手动管理生命周期
```

**注意：** 在 `+load` 方法或类似场景中，如果不使用 `keepAlive`，task 可能会被提前释放，导致 block 无法执行。

#### 调用 keepAlive（自动管理生命周期）

```objc
// 使用默认超时时间（30秒）- 传递 0 或使用常量
LMGCD.main.after(0.5).keepAlive(0).execute(^{
    // task 会自动保持存活直到此 block 执行完成或30秒后
});

// 使用常量（推荐，更语义化）
LMGCD.main.after(0.5).keepAlive(LMGCDKeepAliveDefaultTimeout).execute(^{
    // task 会自动保持存活直到此 block 执行完成或30秒后
});

// 自定义超时时间（10秒）
LMGCD.main.after(0.5).keepAlive(10.0).execute(^{
    // task 会自动保持存活直到此 block 执行完成或10秒后
});

// 无限时间（不会因为超时而释放）
LMGCD.main.after(0.5).keepAlive(LMGCDKeepAliveInfinite).execute(^{
    // task 会自动保持存活直到此 block 执行完成，不会超时
});
```

**注意事项：**
- **不调用 `keepAlive`**：task 的生命周期由调用者管理，如果调用者没有强引用，task 可能会被提前释放
- **调用 `keepAlive`**：task 会自动保持存活直到 block 执行完成或超时，无需手动管理
- `keepAlive` 会自动在 block 执行完成或超时后释放 task，避免内存泄漏
- 默认超时时间为 30 秒
- 传递 `0` 或 `LMGCDKeepAliveDefaultTimeout` 会使用默认超时时间（30秒）
- 传递 `-1` 或 `LMGCDKeepAliveInfinite` 表示无限时间，不会因为超时而释放
- 传递正数表示自定义超时时间（秒）
- 由于 Objective-C 的 block 语法限制，必须传递一个参数（使用常量更语义化）

## API 对比

### 改造前（原生 GCD）

```objc
dispatch_async(dispatch_get_main_queue(), ^{
    // 代码
});

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), 
               dispatch_get_main_queue(), ^{
    // 代码
});
```

### 改造后（LMGCDKit）

```objc
LMGCD.main(^{
    // 代码
});

LMGCD.mainAfter(3.0, ^{
    // 代码
});
```

## 实际应用示例

### 在 LMBiddingManager 中使用

```objc
// 启动超时定时器
self.timeoutTask = LMGCD.mainAfter(self.biddingTimeout, ^{
    [self handleBiddingTimeout];
});

// 取消定时器
if (self.timeoutTask) {
    [self.timeoutTask cancel];
    self.timeoutTask = nil;
}
```

## 轮询功能

### 基础轮询

```objc
// 每1秒执行一次，立即开始，无限次执行
LMGCDTimer *timer = LMGCD.timer(1.0, ^{
    NSLog(@"轮询执行");
});
```

### 高级轮询（带初始延迟和次数限制）

```objc
// 延迟3秒后开始，每1秒执行一次，最多执行5次后自动停止
LMGCDTimer *pollTimer = LMGCD.poll(1.0, 3.0, 5, ^{
    NSLog(@"轮询执行");
});

// 在后台队列轮询
LMGCDTimer *backgroundPoll = LMGCD.pollOnQueue(2.0, 1.0, 10,
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"后台轮询");
});
```

### 轮询状态管理

```objc
// 查询状态
BOOL isRunning = pollTimer.isRunning;      // 是否正在运行
BOOL isSuspended = pollTimer.isSuspended;  // 是否已暂停
BOOL isCancelled = pollTimer.isCancelled;  // 是否已取消
NSUInteger count = pollTimer.executionCount; // 已执行次数

// 控制轮询
[pollTimer suspend];  // 暂停
[pollTimer resume];   // 恢复
[pollTimer cancel];   // 取消
```

## 注意事项

1. `LMGCDTask` 只能取消未执行的任务
2. `LMGCDTimer` 需要手动调用 `cancel` 避免内存泄漏
3. 弱引用方法会自动处理循环引用，但需要检查对象是否存在
4. 轮询定时器达到最大执行次数后会自动取消
5. 使用 `poll` 方法时，`maxCount` 为 0 表示无限次执行
