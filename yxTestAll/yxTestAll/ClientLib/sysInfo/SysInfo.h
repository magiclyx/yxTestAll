//
//  Header.h
//  FileWalker
//
//  Created by Yuxi Liu on 8/30/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#ifndef FileWalker_Header_h
#define FileWalker_Header_h

#ifdef __cplusplus
extern "C"{
#endif
    
    
#include "../debug/libDebug.h"
#import <CoreFoundation/CoreFoundation.h>

//define the local loger
#define sysInfo_warning(msg) cmLibWarningMsg(msg)  //not use
#define sysInfo_error(msg) cmLibErrorMsg(msg)  
#define sysInfo_info(msg) cmLibInfoMsg(msg)  //not use
#define sysInfo_fatal(msg) cmLibFatal(msg)  //not use
    
#define sysInfo_warningFmt(fmt, ...) cmLibWarningFmt(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)  //not use
#define sysInfo_errorFmt(fmt, ...) cmLibErrorFmt(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)  //not use
#define sysInfo_infoFmt(fmt, ...) cmLibInfoFmt(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)  //not use
#define sysInfo_fatalFmt(fmt, ...) cmLibFatalFmt(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)  //not use

//define the local debug flag
#define SYSINFO_DEBUG CM_DEBUG
    

    
extern const char* g_config_directory;
extern const char* g_config_file;


long sys_MaxPath();
    
/*model info*/
const char* sys_model(char* buff, size_t* buffLen);
    
/*platform info*/
const char* sys_platform(char* buff, size_t* buffLen);

/*memory info*/
int64_t sys_totalMemorySpace();
int64_t sys_freeMemorySpace();

/*OS version info*/
void sys_OSVersion(SInt32* ver_main, SInt32* ver_sub, SInt32* ver_rev);
const char* sys_kernelVersion(char* buff, size_t* buffLen);
const char* sys_version_description(char* buff, size_t buffLen);
    
/*processor info*/
void sys_processor(uint32_t* cpunum, uint32_t* logcpunum, uint32_t* freq);
const char* sys_processor_description(char* buff, size_t buffLen);

/*host name*/
const char* sys_hostName(char* buff, size_t* buffLen);
    
//CFStringRef sys_serialNumber();
    
/*disk info*/
unsigned long long sys_freeDiskSpace(const char* path);
unsigned long long sys_totalDiskSpace(const char* path);
    
    


    
//:~ Depreciated
const char* getConfigPath();
    
//:~ Comment : not here, this is string related
const char* expandPathTitle(const char* pcszPath);

#ifdef __cplusplus
}
#endif



#endif
