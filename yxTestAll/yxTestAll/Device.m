//
//  Device.m
//  yxTestAll
//
//  Created by Yuxi Liu on 12/20/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "Device.h"
#include <mach-o/arch.h>

@interface Device(){
    NSString* _cpuArchDescription;
}
@end

@implementation Device

+ (id)sharedManager
{
    static dispatch_once_t  onceToken;
    static Device* sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (NSString*)CPUArch
{
    if (nil == _cpuArchDescription) {
        
        const NXArchInfo* archInfo = NXGetLocalArchInfo();
        if (NULL != archInfo  &&  NULL != archInfo->name) {
            _cpuArchDescription = [NSString stringWithUTF8String:archInfo->name];
        }
        else
        {
            _cpuArchDescription = @"unknown";
        }
    }
    
    return _cpuArchDescription;
}



@end



