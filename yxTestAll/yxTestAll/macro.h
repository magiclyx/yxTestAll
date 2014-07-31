//
//  macro.h
//  yxTestAll
//
//  Created by Yuxi Liu on 7/31/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//


/**
 *  临时放在这里。。。
 *
 */

#ifndef yxTestAll_macro_h
#define yxTestAll_macro_h

///运行时判断运行版本
#define TF_IS_IPAD_RUNTIME [[[UIDevice currentDevice] model] isEqualToString:@"iPad"]
#define TF_IS_IPHONE_RUNTIME [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]
#define TF_IS_IPOD_TOUCH_RUNTIME  [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]

#define TF_CALL_AND_MESSAGE_ABILITY_RUNTIME TF_IS_IPHONE_RUNTIME


///公共库f形式的公共前缀
#undef TFC_PREFIX
#define TFC_PREFIX(a) tfc##a


///摒弃函数提示
#if defined(__GNUC__) && (__GNUC__ >= 4) && defined(__APPLE_CC__) && (__APPLE_CC__ >= 5465)
#define TF_DEPRECATED(_version) __attribute__((deprecated))
#else
#define TF_DEPRECATED(_version)


#define TF_IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


///自定义log提示
#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
    
    void TFNetLog(NSString *format, ...);
    void TFLog(NSString *format, ...);
    
#ifdef __cplusplus
}
#endif // __cplusplus


///release版本屏蔽log
#ifdef DEBUG
#else
#define printf(...)
#define NSLog(...)
#define TFLog(...)
#define TFNetLog(...)
#endif


#endif
