//
//  runtime.m
//  yxTestAll
//
//  Created by Yuxi Liu on 12/20/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "runtime.h"

#import <mach/mach_init.h>
#import <mach/mach_types.h>
#import <mach/mach_error.h>
#import <mach/task.h>
#import <mach-o/dyld.h>

#import <execinfo.h>

#import <sys/sysctl.h>

@interface runtime()
/**
 *  根据镜像的header信息，返回header后第一个命令锁在的地址
 */
-(uintptr_t)_firstCommandAfterImageHeader:(const struct mach_header* const) header;
@end


@implementation runtime


+ (id)sharedManager
{
    static dispatch_once_t  onceToken;
    static runtime* sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}




- (NSString*)executablePath
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* infoDict = [mainBundle infoDictionary];
    NSString *excutablePath = [infoDict objectForKey:@"CFBundleExecutablePath"];
    
    if (!excutablePath)
    {
        excutablePath = [mainBundle executablePath];
    }
    
    return excutablePath;
}

- (NSString*)uuid
{
    NSString* uuidString = nil;
    
    NSString* appPath = [self executablePath];
    if (nil != appPath)
    {
        const uint8_t *uuidBytes = [self uuidBytesOfImage:appPath shouldFullMatch:YES];
        CFUUIDRef uuidRef = CFUUIDCreateFromUUIDBytes(NULL, *((CFUUIDBytes*)uuidBytes));
        uuidString = (NSString*)CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        [uuidString autorelease];
    }
    
    return uuidString;
}

- (NSString*)loadAddress
{
    NSString* addressString = nil;
    NSString* appPath = [self executablePath];
    
    if (nil != appPath)
    {
        const uintptr_t address = [self addressOfImage:appPath shouldFullMatch:YES];
        
        addressString = [NSString stringWithFormat:@"0x%08llX",(long long)address];
    }
    
    return addressString;

}

- (int)threadIndex
{
    int index = -1;
    const thread_t currentThread = mach_thread_self();
    const task_t currentTask = mach_task_self();
    thread_act_array_t threads;
    mach_msg_type_number_t threadWBount;
    kern_return_t kr;
    
    /* Get a list of all threads */
    if ((kr = task_threads(currentTask, &threads, &threadWBount)) != KERN_SUCCESS) {
        NSLog(@"task_threads: %s", mach_error_string(kr));
        threadWBount = 0;
    }
    
    for (mach_msg_type_number_t i = 0; i < threadWBount; i++) {
        if (threads[i] == currentThread) {
            index = i;
            break;
        }
    }
    
    return index;
}

- (NSArray*)callStacks
{
    void* callstack[128];
    const int numFrames = backtrace(callstack, 128);
    char **symbols = backtrace_symbols(callstack, numFrames);
    
    NSMutableArray *callStacksArray = [NSMutableArray arrayWithCapacity:numFrames];
    for (int i = 0; i < numFrames; ++i)
    {
        [callStacksArray addObject:[NSString stringWithUTF8String:symbols[i]]];
    }
    
    free(symbols);

    return callStacksArray;
}



- (BOOL)isJailBroken
{
    return (UINT32_MAX != [self indexOfImage:@"MobileSubstrate" shouldFullMatch:NO])? YES : NO;
}


- (NSDate*)systemBootTime
{
    NSDate* result = nil;
    
    NSString* name = @"kern.boottime";
    
    
    struct timeval value = {0};
    size_t size = sizeof(value);
    
    if(0 == sysctlbyname([name UTF8String], &value, &size, NULL, 0))
    {
        if(!(value.tv_sec == 0 && value.tv_usec == 0))
        {
            result = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)value.tv_sec];
        }
    }
    
    return result;
}

- (NSString*)appVersion
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* infoDict = [mainBundle infoDictionary];
    
    return [infoDict objectForKey:@"CFBundleShortVersionString"];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

- (UInt32)indexOfImage:(NSString*)imageName shouldFullMatch:(BOOL)fullMathch
{
    const uint32_t imageCount = _dyld_image_count();
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++)
    {
        const char* name = _dyld_get_image_name(iImg);
        if(YES == fullMathch)
        {
            if(strcmp(name, [imageName UTF8String]) == 0)
            {
                return iImg;
            }
        }
        else
        {
            if(strstr(name, [imageName UTF8String]) != NULL)
            {
                return iImg;
            }
        }
    }
    return UINT32_MAX;
}

- (const uint8_t*) uuidBytesOfImage:(NSString*)imageName shouldFullMatch:(BOOL)fullMathch
{
    const uint32_t iImg = [self indexOfImage:imageName shouldFullMatch:fullMathch];
    if(iImg != UINT32_MAX)
    {
        const struct mach_header* header = _dyld_get_image_header(iImg);
        if(header != NULL)
        {
            uintptr_t cmdPtr = [self _firstCommandAfterImageHeader:header];
            if(cmdPtr != 0)
            {
                for(uint32_t iCmd = 0;iCmd < header->ncmds; iCmd++)
                {
                    const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                    if(loadCmd->cmd == LC_UUID)
                    {
                        struct uuid_command* uuidCmd = (struct uuid_command*)cmdPtr;
                        return uuidCmd->uuid;
                    }
                    cmdPtr += loadCmd->cmdsize;
                }
            }
        }
    }
    return NULL;
}

- (const uintptr_t) addressOfImage:(NSString*)imageName shouldFullMatch:(BOOL)fullMathch
{
    const uint32_t iImg = [self indexOfImage:imageName shouldFullMatch:fullMathch];
    if(iImg != UINT32_MAX)
    {
        const struct mach_header* header = _dyld_get_image_header(iImg);
        if(header != NULL)
        {
            uintptr_t binaryAddress = (uintptr_t)header;
            return binaryAddress;
        }
    }
    return 0;
}

#pragma mark private
-(uintptr_t)_firstCommandAfterImageHeader:(const struct mach_header* const) header
{
    switch(header->magic)
    {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            // Header is corrupt
            return 0;
    }
}


@end
