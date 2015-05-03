//
//  libDebug.h
//  ClientLib
//
//  Created by Yuxi Liu on 3/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#ifndef ClientLib_libDebug_h
#define ClientLib_libDebug_h

#include "../cm/cmBasicTypes.h"
#include "../Loger/log.h"

#define CMLIB_DEBUG  CM_DEBUG


/************************************************************************************/
/** log about **/
/************************************************************************************/

#ifdef CMLIB_DEBUG

extern HSL_Handle g_cmLib_libDebug_handle__;


#define cmLibWarningMsg(msg) SL_WARN_MSG(g_cmLib_libDebug_handle__, msg)
#define cmLibErrorMsg(msg) SL_ERR_MSG(g_cmLib_libDebug_handle__, msg)
#define cmLibInfoMsg(msg) SL_INFO_MSG(g_cmLib_libDebug_handle__, msg)
#define cmLibFatal(msg) SL_FATAL_MSG(g_cmLib_libDebug_handle__, msg)


#define cmLibWarningFmt(fmt, ...) SL_WARN_FMT(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)
#define cmLibErrorFmt(fmt, ...) SL_ERR_FMT(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)
#define cmLibInfoFmt(fmt, ...) SL_INFO_FMT(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)
#define cmLibFatalFmt(fmt, ...) SL_FATAL_FMT(g_cmLib_libDebug_handle__, fmt, __VA_ARGS__)


#else

#define cmLibWarningMsg(msg)
#define cmLibErrorMsg(msg)
#define cmLibInfoMsg(msg)
#define cmLibFatal(msg)

#define cmLibWarningFmt(fmt, ...)
#define cmLibErrorFmt(fmt, ...)
#define cmLibInfoFmt(fmt, ...)
#define cmLibFatalFmt(fmt, ...)
#endif


#endif




/************************************************************************************/
/** Profiling about **/
/************************************************************************************/

#ifdef CMLIB_DEBUG
#define CMLIB_PROFILE 1
#else
#define CMLIB_PROFILE 0
#endif



#if CMLIB_PROFILE

#define cmLib_timeStart() AbsoluteTime start = UpTime()
//duplicate a object. and release it
//#define Profile(img) CFRelease(CGDataProviderCopyData(CGImageGetDataProvider(img)))
#define cmLib_timeEnd(caption) do { Duration time = AbsoluteDeltaToDuration(UpTime(), start); double timef = time < 0 ? time / -1000000.0 : time / 1000.0; NSLog(@"%s Time Taken: %f seconds", caption, timef); } while(0)

#else  //CMLIB_PROFILE

#define cmLib_timeStart()
//#define Profile(img)
#define cmLib_timeEnd(caption)

#endif  //CMLIB_PROFILE



/*for auto debug on 360safe*/
/*Temporary codes*/
#ifdef DEBUG
#define cm_break_on_condition(cond) if(!cond) __asm__("int3")
#define cm_break_force() cm_break_on_condition(0)
#else
#define cm_break_on_condition(cond)
#define cm_break()
#endif












