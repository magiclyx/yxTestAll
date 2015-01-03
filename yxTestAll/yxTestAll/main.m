//
//  main.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/12/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "LoggerClient.h"
#import "crashManager.h"

int main(int argc, char * argv[])
{
    
    LoggerSetViewerHost(NULL, CFSTR("127.0.0.1"), (UInt32)50000);
    LoggerSetOptions(NULL,						// configure the default logger
                     kLoggerOption_BufferLogsUntilConnection |
                     kLoggerOption_UseSSL);
    
    LogMessageRaw(@"set up");
    
    [[crashManager sharedManager] registCrashMonitor];
    
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    
//    @try {
//        @autoreleasepool {
//            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@", exception);
//    }
//    
}
