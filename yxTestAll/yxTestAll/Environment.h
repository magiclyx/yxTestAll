//
//  Environment.h
//  testNavigation
//
//  Created by Yuxi Liu on 6/17/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Environment : NSObject

+ (id)sharedManager;
- (BOOL) isIPhone5;

@end



#if __IPHONE_8_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#define IF_IOS8_OR_GREATER(...) if ([[UIDevice currentDevice] wbt_systemMainVersion] >= 8) { __VA_ARGS__ }
#else
#define IF_IOS8_OR_GREATER(...)
#endif

#if __IPHONE_7_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define IF_IOS7_OR_GREATER(...) if ([[UIDevice currentDevice] wbt_systemMainVersion] >= 7) { __VA_ARGS__ }
#else
#define IF_IOS7_OR_GREATER(...)
#endif

#if __IPHONE_6_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
#define IF_IOS6_OR_GREATER(...) if ([[UIDevice currentDevice] wbt_systemMainVersion] >= 6.0) { __VA_ARGS__ }
#else
#define IF_IOS6_OR_GREATER(...)
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
#define IF_IOS5_OR_GREATER(...) if ([[UIDevice currentDevice] wbt_systemMainVersion] >= 5.0) { __VA_ARGS__ }
#else
#define IF_IOS5_OR_GREATER(...)
#endif
