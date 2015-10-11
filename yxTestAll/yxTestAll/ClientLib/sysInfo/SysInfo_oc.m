//
//  SysInfo_oc.m
//  ClientLib
//
//  Created by Yuxi Liu on 3/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#include <sys/sysctl.h>
//#include <servers/bootstrap.h>
#include <mach/mach.h>
//#include <libproc.h>
#include <Security/Security.h>
//#include <CoreServices/CoreServices.h>
//#include <DirectoryService/DirectoryService.h>

#import "SysInfo_oc.h"


uint32_t processor_freq()
{
    int mib[2] = {CTL_HW, HW_CPU_FREQ};
    uint32_t freq = 0;
    size_t len = sizeof(freq);
    
    sysctl(mib, 2, &freq, &len, NULL, 0);
    
    return freq;
}



@implementation SysInfo_oc


- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}




+(NSString*)platform
{
    NSString *ret = @"";
    int mib[2] = {CTL_HW, HW_MACHINE};
    size_t len;
    char *machine = NULL;
    
    
    if(sysctl(mib, 2, NULL, &len, NULL, 0) != 0)
    {
        goto END_POINT;
    }
    
    machine = malloc(sizeof(char) * (len + 1));
    
    if(machine == NULL)
    {
        goto END_POINT;
    }
    
    if(sysctl(mib, 2, machine, &len, NULL, 0) != 0)
    {
        goto END_POINT;
    }
    
    ret = [NSString stringWithCString : machine
                             encoding : NSUTF8StringEncoding
           ];
    
END_POINT:
    if(machine)
    {
        free(machine);
        machine = NULL;
    }
    
    return ret;
    
    
}


+(NSString*)model
{
    NSString *ret = @"";
    int mib[2] = {CTL_HW, HW_MODEL};
    size_t len;
    char *model = NULL;    
    
    
    if(sysctl(mib, 2, NULL, &len, NULL, 0) != 0)
    {
        goto END_POINT;
    }
    
    model = malloc(sizeof(char) * (len + 1));
    
    if(model == NULL)
    {
        goto END_POINT;
    }
    
    if(sysctl(mib, 2, model, &len, NULL, 0) != 0)
    {
        goto END_POINT;
    }
    
    ret = [NSString stringWithCString : model
                             encoding : NSUTF8StringEncoding
           ];
    
END_POINT:
    if(model)
    {
        free(model);
        model = NULL;
    }
    
    return ret;
}


+(NSString*)hostName
{
    NSString *ret = @"";
    int mib[2] = {CTL_KERN, KERN_HOSTNAME};
    size_t len;
    char *hostname = NULL;    
    
    
    if(sysctl(mib, 2, NULL, &len, NULL, 0) != 0)
    {
        goto END_POINT;
    }
    
    hostname = malloc(sizeof(char) * (len + 1));
    
    if(hostname == NULL)
    {
        goto END_POINT;
    }
    
    if(sysctl(mib, 2, hostname, &len, NULL, 0) != 0)
    {
        goto END_POINT;
    }
    
    ret = [NSString stringWithCString : hostname
                             encoding : NSUTF8StringEncoding
           ];
    
END_POINT:
    if(hostname)
    {
        free(hostname);
        hostname = NULL;
    }
    
    return ret;
    
}


+ (void)processor:(uint32_t*)cpunum :(uint32_t*)logcpunum :(uint32_t*)freq{
    int mib[2] = {CTL_HW, HW_CPU_FREQ};
    
    //HW_NCPU
    
    size_t len;
    
    if(NULL != freq){
        len = sizeof(freq);
        sysctl(mib, 2, freq, &len, NULL, 0);
    }

    
    mib[1] = HW_NCPU;
    
    if(NULL != cpunum){
        len = sizeof(cpunum);
        sysctlbyname("hw.physicalcpu", cpunum, &len, NULL, 0);
    }

    if(NULL != logcpunum){
        len = sizeof(logcpunum);
        sysctlbyname("hw.logicalcpu", logcpunum, &len, NULL, 0);
    }
    
}

+(NSString*)processorDescription
{
    char buf[100];
    size_t buflen = 100;
    sysctlbyname("machdep.cpu.brand_string", &buf, &buflen, NULL, 0);
    return [NSString stringWithFormat : @"%s", buf];
}


+ (void)OSVersion:(SInt32*)main :(SInt32*)sub :(SInt32*)rev{
    
    assert(0);
    
//    if(NULL != main){
//        Gestalt(gestaltSystemVersionMajor, main);
//    }
//    
//    if(NULL != sub){
//        Gestalt(gestaltSystemVersionMinor, sub);
//    }
//    
//    if(NULL != rev){
//        Gestalt(gestaltSystemVersionBugFix, rev);
//    }

}

+ (NSString*)KernelVersion{
    NSString *ver = nil;
    char buf[1024];
    int mib[2];
    size_t len;
    char *kern_osver = NULL;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_OSVERSION;
    
    if(sysctl(mib, 2, NULL, &len, NULL, 0) != 0)
        goto errout;
    
    
    kern_osver = (char*)malloc(sizeof(char) * (len+1));
    
    if(kern_osver == NULL)
        goto errout;
    
    if(sysctl(mib, 2, kern_osver, &len, NULL, 0) != 0)
        goto errout;
    
    
    ver = [NSString stringWithCString : buf
                             encoding : NSUTF8StringEncoding
           ];
    
    if(kern_osver)
    {
        free(kern_osver);
        kern_osver = NULL;
    }
    

    return ver;
    
    
errout:
    return nil;
}

+ (NSString*)versionDescription{
    SInt32 main_ver = 0, sub_ver = 0, rev_ver = 0;
    NSString* kernelVersion = nil;
    
    [SysInfo_oc OSVersion:&main_ver :&sub_ver :&rev_ver];
    kernelVersion = [SysInfo_oc KernelVersion];
    
    return [NSString stringWithFormat:@"%d.%d.%d (%@)", (int)main_ver, (int)sub_ver, (int)rev_ver, kernelVersion];
}


+(NSString*)SerialNumber
{
//    NSString *sn = @"";
//    
//    io_service_t    platformExpert;
//    
//    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
//    
//    if(platformExpert == (io_service_t)0)
//    {
//        goto END_POINT;
//    }
//    
//    CFStringRef serialNumberAsCFString = (CFStringRef)IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
//    
//    if(serialNumberAsCFString == NULL)
//    {
//        goto END_POINT;
//    }
//    
//    sn = (NSString*)serialNumberAsCFString;
//    // sn = [NSString stringWithString : (NSString*)serialNumberAsCFString];
//    
//    
//END_POINT:
//    if(platformExpert)
//    {
//        IOObjectRelease(platformExpert);
//        platformExpert = (io_service_t)0;
//    }
//    
//    return sn;
    
    return @"unsupport in ios";
}




+ (unsigned long long)freeDiskSpace:(NSString *)filePath{ 
    NSError* err = nil; 
    NSFileManager * manager = [NSFileManager defaultManager];  
    NSDictionary * fsattrs = [manager attributesOfFileSystemForPath:filePath error:&err];  
    return [[fsattrs objectForKey:NSFileSystemFreeSize] unsignedLongLongValue]; 
}


+(unsigned long long)totalDiskSpace:(NSString *)filePath{ 
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
//    struct statfs tStats; 
//    statfs([filePath UTF8String], &tStats); 
//    unsigned long long totalSpace = (unsigned long long)(tStats.f_blocks * tStats.f_bsize); 
//    
//    return totalSpace;
    return 0;
}




+ (NSUInteger) totalMemorySize
{
    int mib[2] = {CTL_HW, HW_MEMSIZE};
    int64_t memsize= 0;
    size_t len = sizeof(memsize);
    
    if(sysctl(mib, 2, &memsize, &len, NULL, 0) != 0)
        goto errout;
    
    return (NSUInteger)memsize;
    
errout:
    return 0;
}

+ (NSUInteger) freeMemorySize
{
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t     vm_stat;
    
    host_page_size(host_port, &pagesize);
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");
    
    //    natural_t   mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t   mem_free = vm_stat.free_count * ((unsigned int)pagesize);
    //    natural_t   mem_total = mem_used + mem_free;
    
    return mem_free;
}

@end
