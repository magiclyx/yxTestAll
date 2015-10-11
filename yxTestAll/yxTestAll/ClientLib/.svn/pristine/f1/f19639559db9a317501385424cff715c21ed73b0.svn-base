//
//  log.c
//  testLog
//
//  Created by Yuxi Liu on 9/25/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <pwd.h>
#include <string.h>
#include <assert.h>

#include "log.h"


#define HSLHANDLE2SLCONTEXT(h) ((_sl_context_ref_)h)

typedef struct __sl_context_{
    aslclient _asl;
    int _log_file_fd;
    int _current_level;
    char _pstrIdent[1024+1];
    char _pstrFacility[1024+1];
    char _dirName[1024+1];
    char _fileName[1024+1];
    
    const char* _log_dir;
}_sl_context_, *_sl_context_ref_;

static const char* _user_log_dir = "~/Library/Logs";
static const char* _sys_log_dir = "/var/log";


static _sl_context_ref_ _init_asl_log(const char *ident, const char *facility, const char* log_file);
static void _asl_log(_sl_context_ref_ context, int level, const char* msg, void *ctx);
static void _uninit_asl_log(_sl_context_ref_ context);

static void _setDirName(_sl_context_ref_ handle, const char* dirName);
static void _setFileName(_sl_context_ref_ handle, const char* fileName);



HSL_Handle SL_InitUserLog(const char *ident, const char *facility, const char* dirName, const char* fileName)
{
    char buff[1024+1]; //i think it's large enought;
    
    //merget a user log path
    uid_t uid = getuid();
    struct passwd* pwd = getpwuid(uid);
    strncpy(buff, pwd->pw_dir, 1024);
    strcat(buff, _user_log_dir+1);// ignore the "~" flag
    
    //verify the authority of the log paths
    if(access(buff, R_OK|W_OK) == -1)
        return NULL;
    
    strcat(buff, "/");
    strcat(buff, dirName);
    
    //verify the dir
    if(access(buff, F_OK) == -1)
    {
        mkdir(buff, S_IRWXU|S_IWUSR);
        if(access(buff, F_OK) == -1)
            return NULL;
        
        if(access(buff, R_OK|W_OK) == -1)
            return NULL;
    }
    
    strcat(buff, "/");
    strcat(buff, fileName);
    

    _sl_context_ref_ context = _init_asl_log(ident, facility, buff);
    if(NULL != context){
        context->_log_dir = _user_log_dir;
        _setDirName(context, dirName);
        _setFileName(context, fileName);
    }
    
    return (HSL_Handle)context;
}


HSL_Handle SL_InitSyeLog(const char *ident, const char *facility, const char* dirName, const char* fileName)
{
    char buff[1024+1];
    strncpy(buff, _sys_log_dir, 1024);
    
    //verify the authority of the log paths
    if(access(buff, R_OK|W_OK) == -1)
        return NULL;
    
    strcat(buff, "/");
    strcat(buff, dirName);
    
    //verify the dir
    if(access(buff, F_OK) == -1)
    {
        mkdir(buff, S_IRWXU|S_IWUSR);
        if(access(buff, F_OK) == -1)
            return NULL;
        
        if(access(buff, R_OK|W_OK) == -1)
            return NULL;
    }
    
    strcat(buff, "/");
    strcat(buff, fileName);
    
    
    _sl_context_ref_ context = _init_asl_log(ident, facility, buff);
    if(NULL != context){
        context->_log_dir = _sys_log_dir;
        _setDirName(context, dirName);
        _setFileName(context, fileName);
    }
    
    
    return (HSL_Handle)context;

}

int SL_bindLogFile(HSL_Handle handle, const char* dirName, const char* fileName){
    
    _sl_context_ref_ context = HSLHANDLE2SLCONTEXT(handle);
    
    int newFileFd = -1;
    char buff[1024+1];
    strncpy(buff, context->_log_dir, 1024);
    
    //verify the authority of the log paths
    if(access(buff, R_OK|W_OK) == -1)
        return -1;
    
    strcat(buff, "/");
    strcat(buff, dirName);
    
    //verify the dir
    if(access(buff, F_OK) == -1)
    {
        mkdir(buff, S_IRWXU|S_IWUSR);
        if(access(buff, F_OK) == -1)
            return -1;
        
        if(access(buff, R_OK|W_OK) == -1)
            return -1;
    }
    
    strcat(buff, "/");
    strcat(buff, fileName);
    
    
    
    
    newFileFd = open(buff, O_RDWR | O_CREAT | O_APPEND, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
    if(newFileFd == -1)
        return -1;
    
    
    if(-1 != context->_log_file_fd){
        asl_remove_log_file(context->_asl, context->_log_file_fd);
        context->_log_file_fd = newFileFd;
        
        _setDirName(context, dirName);
        _setFileName(context, fileName);
        asl_add_log_file(context->_asl, context->_log_file_fd);
    }
    
    return 0;
}


void SL_ReleaseUserLog(HSL_Handle* handleRef)
{
    _sl_context_ref_ context = *handleRef;
    _uninit_asl_log(context);
    
    *handleRef = NULL;
    
}

void SL_SetLevel(HSL_Handle handle, int level)
{
    _sl_context_ref_ context = handle;
    context->_current_level = level;
}


void SL_Log(HSL_Handle handle, int level, const char* msg)
{
    if(NULL != handle)
    {
        _asl_log(handle, level, msg, NULL);
    }
    else
    {       
        
        char* logTitle = NULL;
        switch (level) {
            case ASL_LEVEL_EMERG:
                logTitle = ASL_STRING_EMERG;
                break;
            case ASL_LEVEL_ALERT:
                logTitle = ASL_STRING_ALERT;
                break;
            case ASL_LEVEL_CRIT:
                logTitle = ASL_STRING_CRIT;
                break;
            case ASL_LEVEL_ERR:
                logTitle = ASL_STRING_ERR;
                break;
            case ASL_LEVEL_WARNING:
                logTitle = ASL_STRING_WARNING;
                break;
            case ASL_LEVEL_NOTICE:
                logTitle = ASL_STRING_NOTICE;
                break;
            case ASL_LEVEL_INFO:
                logTitle = ASL_STRING_INFO;
                break;
            case ASL_LEVEL_DEBUG:
                logTitle = ASL_STRING_DEBUG;
                break;
            default:
            {
                char buff[30+1];
                sprintf(buff, "unknown sl level :%d", level);
                SL_Log(handle, ASL_LEVEL_WARNING, buff);
            }
                
        }
        
        unsigned long buffLen = 50 + strlen(msg); //50 is reserved for the logTitle string
        char* buff = (char*)malloc(buffLen + 1);
        snprintf(buff, buffLen, "cmLib_sl_[%s] :%s", logTitle, msg);
        buff[buffLen] = '\0';
        
        printf("%s", buff);
        
    }
    
}

void SL_LogFmt(HSL_Handle handle, int level, const char* fmt, ...)
{
    char buf[1024+1];
    
    va_list argptr;
    
    va_start(argptr, fmt);
    vsnprintf(buf, 1024, fmt, argptr);
    va_end(argptr);
    
    SL_Log(handle, level, buf);
}



void SL_setIdent(HSL_Handle handle, const char* ident){
    
    assert(NULL != ident);
    
    _sl_context_ref_ context = HSLHANDLE2SLCONTEXT(handle);
    
    strncpy(context->_pstrIdent, ident, 1024);
    context->_pstrIdent[1024] = '\0';
    
    
}
void SL_setFacility(HSL_Handle handle, const char* facility){
    
    assert(NULL != facility);
    
    _sl_context_ref_ context = HSLHANDLE2SLCONTEXT(handle);
    
    strncpy(context->_pstrFacility, facility, 1024);
    context->_pstrFacility[1024] = '\0';
}







const char* SL_Identifier(HSL_Handle handle){
    _sl_context_ref_ context = HSLHANDLE2SLCONTEXT(handle);
    return context->_pstrIdent;
}
const char* SL_Facility(HSL_Handle handle){
    _sl_context_ref_ context = HSLHANDLE2SLCONTEXT(handle);
    return context->_pstrFacility;
}


const char* SL_DirName(HSL_Handle handle){
    _sl_context_ref_ context = HSLHANDLE2SLCONTEXT(handle);
    
    return context->_dirName;
}
const char* SL_FileName(HSL_Handle handle){
    _sl_context_ref_ context = HSLHANDLE2SLCONTEXT(handle);
    
    return context->_fileName;
}










static _sl_context_ref_ _init_asl_log(const char *ident, const char *facility, const char* log_file)
{
    //AR_path_create_path
    
    SL_BOOL fSuccess = SL_FALSE;
    _sl_context_ref_ contextRef = NULL;
    
    do
    {
        contextRef = (_sl_context_ref_)malloc(sizeof(_sl_context_));
        if(NULL == contextRef)
            break;
        
        //init
        contextRef->_log_file_fd = -1;
        contextRef->_asl = NULL;
        contextRef->_current_level = ASL_LEVEL_ERR;/*init the level to ASL_LEVEL_ERR -> 3*/
        
        contextRef->_asl = asl_open(ident, facility, ASL_OPT_STDERR|ASL_OPT_NO_DELAY);
        if(NULL == contextRef->_asl)
            break;
        
        contextRef->_log_file_fd = open(log_file, O_RDWR | O_CREAT | O_APPEND, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
        if(contextRef->_log_file_fd == -1)
            break;
        
        asl_add_log_file(contextRef->_asl, contextRef->_log_file_fd);
        
        
        strncpy(contextRef->_pstrIdent, ident, 1024);
        contextRef->_pstrIdent[1024] = '\0';
        
        strncpy(contextRef->_pstrFacility, facility, 1024);
        contextRef->_pstrFacility[1024] = '\0';
        
        
        fSuccess = SL_TRUE;
        
    }while (0);
    
    //clean up 
    if(fSuccess != SL_TRUE && NULL != contextRef)
    {
        
        if(contextRef->_asl != NULL)
        {
            asl_close(contextRef->_asl);
            contextRef->_asl = NULL;
        }
        
        
        if(contextRef->_log_file_fd != -1)
        {
            close(contextRef->_log_file_fd);
            contextRef->_log_file_fd = -1;
        }
        
        free(contextRef);
        contextRef = NULL;
    }
    
    
    return contextRef;
}


static void _uninit_asl_log(_sl_context_ref_ context)
{
    if(context->_asl)
    {
        asl_close(context->_asl);
        context->_asl = NULL;
    }
    
    if(context->_log_file_fd != -1)
    {
        close(context->_log_file_fd);
        context->_log_file_fd = -1;
    }
}



static void _asl_log(_sl_context_ref_ context, int level, const char* msg, void *ctx)
{
    aslmsg log_msg = asl_new(ASL_TYPE_MSG);
    
    if(NULL == msg)
        return;
    
    
    if(context->_current_level < level)
        return;
    
    
    if(context->_asl == NULL || log_msg == NULL)
        return;

    
    
    //log_msg = asl_new(ASL_TYPE_MSG);
    asl_set(log_msg, ASL_KEY_SENDER, context->_pstrIdent);
    asl_set(log_msg, ASL_KEY_FACILITY, context->_pstrFacility);
    
    asl_log(context->_asl, log_msg, level, "%s", msg);
    if(level == ASL_LEVEL_CRIT)
        exit(-1);
    
    
    if(log_msg)
    {
        asl_free(log_msg);
        log_msg = NULL;
    }
}


static void _setDirName(_sl_context_ref_ context, const char* dirName){    
    strncpy(context->_dirName, dirName, 1024);
    context->_dirName[1024] = '\0';
}
static void _setFileName(_sl_context_ref_ context, const char* fileName){
    strncpy(context->_fileName, fileName, 1024);
    context->_fileName[1024] = '\0';
}








