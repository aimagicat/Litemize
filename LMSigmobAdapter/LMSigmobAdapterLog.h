//
//  LMSigmobAdapterLog.h
//  LitemobSDK
//
//  LMSigmobAdapter 日志宏定义
//

#import <Foundation/Foundation.h>

// 日志前缀宏，用于区分不同的 adapter
// Debug 模式下输出日志，Release 模式下不输出
#ifdef DEBUG
#define LMSigmobLog(fmt, ...) NSLog(@"[LMSigmob] " fmt, ##__VA_ARGS__)
#else
#define LMSigmobLog(fmt, ...)
#endif
