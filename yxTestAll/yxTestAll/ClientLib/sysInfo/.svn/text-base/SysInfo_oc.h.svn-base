//
//  SysInfo_oc.h
//  ClientLib
//
//  Created by Yuxi Liu on 3/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SysInfo_oc : NSObject

+(NSString*)model;

+(NSString*)platform;

+ (NSUInteger)totalMemorySize;
+ (NSUInteger)freeMemorySize;

+ (void)OSVersion:(SInt32*)main :(SInt32*)sub :(SInt32*)rev;
+ (NSString*)KernelVersion;
+ (NSString*)versionDescription;


+ (void)processor:(uint32_t*)cpunum :(uint32_t*)logcpunum :(uint32_t*)freq;
+ (NSString*)processorDescription;

+ (NSString*)hostName;

/*just support in OC lib*/
+ (NSString*)SerialNumber;

/*this two method using cocoa lib*/
+ (unsigned long long)freeDiskSpace:(NSString *)filePath;
+ (unsigned long long)totalDiskSpace:(NSString *)filePath;





@end
