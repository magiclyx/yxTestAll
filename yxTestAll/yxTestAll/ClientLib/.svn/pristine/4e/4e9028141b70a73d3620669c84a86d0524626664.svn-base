//
//  log.h
//  testLog
//
//  Created by Yuxi Liu on 9/25/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//



#ifndef testLog_log_h
#define testLog_log_h

#include <asl.h>

typedef void* HSL_Handle;
typedef int SL_BOOL;
#define SL_FALSE 0
#define SL_TRUE (!(0))


HSL_Handle SL_InitUserLog(const char *ident, const char *facility, const char* dirName, const char* fileName);
HSL_Handle SL_InitSyeLog(const char *ident, const char *facility, const char* dirName, const char* fileName);


int SL_bindLogFile(HSL_Handle handle, const char* dirName, const char* fileName);

void SL_setIdent(HSL_Handle handle, const char* ident);
void SL_setFacility(HSL_Handle handle, const char* facility);

const char* SL_Identifier(HSL_Handle handle);
const char* SL_Facility(HSL_Handle handle);
const char* SL_DirName(HSL_Handle handle);
const char* SL_FileName(HSL_Handle handle);


void SL_ReleaseUserLog(HSL_Handle* handleRef);
void SL_Log(HSL_Handle handle, int level, const char* msg);
void SL_LogFmt(HSL_Handle handle, int level, const char* fmt, ...);
void SL_SetLevel(HSL_Handle handle, int level);


//int asl_set(aslmsg msg, const char *key, const char *value);
//int SL_SetContext(HSL_Handle handle, const char *key, const char *value);


#define SL_ERR_MSG(handle, msg)      SL_Log(handle, ASL_LEVEL_ERR, msg);
#define SL_WARN_MSG(handle, msg)     SL_Log(handle, ASL_LEVEL_WARNING, msg);
#define SL_DEBUG_MSG(handle, msg)    SL_Log(handle, ASL_LEVEL_DEBUG, fmt, msg);
#define SL_INFO_MSG(handle, msg)     SL_Log(handle, ASL_LEVEL_INFO, fmt, msg);
#define SL_FATAL_MSG(handle, msg)    SL_Log(handle, ASL_LEVEL_CRIT, fmt, msg);


#define SL_ERR_FMT(handle, fmt, ...)      SL_LogFmt(handle, ASL_LEVEL_ERR, fmt, __VA_ARGS__);
#define SL_WARN_FMT(handle, fmt, ...)     SL_LogFmt(handle, ASL_LEVEL_WARNING, fmt, __VA_ARGS__);
#define SL_DEBUG_FMT(handle, fmt, ...)    SL_LogFmt(handle, ASL_LEVEL_DEBUG, fmt, __VA_ARGS__);
#define SL_INFO_FMT(handle, fmt, ...)     SL_LogFmt(handle, ASL_LEVEL_INFO, fmt, __VA_ARGS__);
#define SL_FATAL_FMT(handle, fmt, ...)    SL_LogFmt(handle, ASL_LEVEL_CRIT, fmt, __VA_ARGS__);


#endif //testLog_log_h
                                                                                                                          



