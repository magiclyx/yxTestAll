
//
//  FileScaner.cpp
//  FileWalker
//
//  Created by Yuxi Liu on 8/31/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#include <unistd.h>
#include <dirent.h>

#include <pthread.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "FileScaner.h"
#include "../cm/cmMem.h"
#include "../md5/md5.h"
#include "../sysInfo/SysInfo.h"


/* File operator */
static const int FO_F = 1;
static const int FO_D = 2;
static const int FO_DNR = 3;
static const int FO_NS = 4;



typedef  int FS_BOOL;
static const FS_BOOL FS_FALSE = 0;
static const FS_BOOL FS_TRUE = !(0);



typedef struct _filePack
{
    unsigned char md5[16];
    const char* path;
    size_t size;
    unsigned long long last_modified; //it's too long to...
    FS_FileType type;
}filePack, *filePackRef;


typedef struct __fileScaner_contex
{
    char* pszFullPath;
    size_t pathLen;
    filePack* curFilePack;  //current file pack
    FS_callback_directory_start cb_directory_start;
    FS_callback_directory_end cb_directory_end;
    FS_callback_file cb_file;
    FS_callback_error cb_error;
    unsigned long fileTypeMask;
    FS_BOOL fRun;
    FS_BOOL fPause;
    pthread_mutex_t pauseFlag;
    size_t nSizeLimited;
    long long llMdbLimited;
    void* userData;
}fileScan_context, *fileScan_context_Ref;

#define HScanerToImpl(handle) (fileScan_context_Ref)handle
#define HCurosorToImpl(handle) (filePackRef)handle



static int _fileWalker(fileScan_context_Ref pContext, char* pszPath);
static int _fileAnaly(fileScan_context_Ref pContext, const char* pszPath, const struct stat* statptr, int FO_TYPE/*operaton type*/);
static int _packFileInfo(fileScan_context_Ref pContext, const char* pszPath, FS_FileType type, const struct stat* statptr);
static FS_FileType _fileTypeMapping(const struct stat* statptr);


///////////////////////////////////////////////////////////////////////////////////////////
/// About Scanner
HFS_SCaner FS_Init(unsigned long FileTypeMask, size_t nSizeLimit, FS_callback_directory_start cb_directory_start, FS_callback_directory_end cb_directory_end, FS_callback_file cb_file, FS_callback_error cb_error)
{
    fileScan_context_Ref context = (fileScan_context_Ref)MALLOC(sizeof(fileScan_context));
    context->pszFullPath = NULL;
    context->pathLen = -1;
    context->cb_directory_start = cb_directory_start;
    context->cb_directory_end = cb_directory_end;
    context->cb_file = cb_file;
    context->cb_error = cb_error;
    context->fileTypeMask = FileTypeMask;
    context->fRun = FS_TRUE;
    context->fPause = FS_FALSE;
    context->nSizeLimited = nSizeLimit;
    context->llMdbLimited = -1;
    context->userData = NULL;
    
    if(0 != pthread_mutex_init(&(context->pauseFlag), NULL))
        goto errout;
        
    
//    FS_BOOL fPause;
//    pthread_mutex_t pauseFlag;
    
    return (HFS_SCaner)context;
    
errout:
    
    if(NULL == context){
        FREE(context);
        context = NULL;
    }
    
    
    return NULL;
}


void FS_Release(HFS_SCaner* pHandle)
{
    fileScan_context_Ref context = HScanerToImpl(*pHandle);
    *pHandle = NULL;
    
    
    pthread_mutex_destroy(&context->pauseFlag);
    
    if(NULL != context->pszFullPath)
        FREE(context->pszFullPath);
    
    FREE(context);
    
}

void FS_Md5Limited(HFS_SCaner* pHandle, long long fileSize)
{
    fileScan_context_Ref context = HScanerToImpl(*pHandle);
    context->llMdbLimited = fileSize;
}

int FS_Scaner(HFS_SCaner hScaner, const char* pszPath, void* userData)
{
    fileScan_context_Ref scanRef = HScanerToImpl(hScaner);
    scanRef->fRun = FS_TRUE;
    scanRef->userData = userData;
    
    scanRef->pathLen = sys_MaxPath();
    scanRef->pszFullPath = (char*)malloc(scanRef->pathLen * sizeof(char));
    
    strncpy(scanRef->pszFullPath, pszPath, scanRef->pathLen);
    if(scanRef->pszFullPath[0] == '~')
        strncpy(scanRef->pszFullPath, expandPathTitle(scanRef->pszFullPath), scanRef->pathLen);
    
    
    scanRef->pszFullPath[scanRef->pathLen-1] = 0;

    
    int ret = _fileWalker(scanRef, scanRef->pszFullPath);
    
    if((NULL != scanRef->cb_error) && (ret == FS_Err_Canceled) )
        scanRef->cb_error(NULL, FS_Err_Canceled, scanRef->userData);
    
    return ret;
}

int FS_Stop(HFS_SCaner hScaner)
{
    fileScan_context_Ref scanRef = HScanerToImpl(hScaner);
    scanRef->fRun = FS_FALSE;
    
    return 0;
}

int FS_Pause(HFS_SCaner hScaner){
    fileScan_context_Ref scanRef = HScanerToImpl(hScaner);
    
    if(FS_FALSE == scanRef->fPause){
        pthread_mutex_trylock(&(scanRef->pauseFlag));
        scanRef->fPause = FS_TRUE;
    }
    
    return 0;
}

int FS_Resume(HFS_SCaner hScaner){
    fileScan_context_Ref scanRef = HScanerToImpl(hScaner);
    
    if(FS_TRUE ==  scanRef->fPause){
        scanRef->fPause = FS_FALSE;
        pthread_mutex_unlock(&(scanRef->pauseFlag));
    }
    
    return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////
/// About Cursor
void FS_GetMd5(HFS_Cursor hCursor, unsigned char md5[16])
{
    filePackRef pPack = HCurosorToImpl(hCursor);
    memcpy(md5, pPack->md5, sizeof(unsigned char)*16);
}
void FS_GetPath(HFS_Cursor hCursor, char* pszPath, size_t len)
{
    filePackRef pPack = HCurosorToImpl(hCursor);
    strncpy(pszPath, pPack->path, len);
}
size_t FS_GetSize(HFS_Cursor hCursor)
{
    filePackRef pPack = HCurosorToImpl(hCursor);
    return pPack->size;
}
unsigned long long getLastModified(HFS_Cursor hCursor)
{
    filePackRef pPack = HCurosorToImpl(hCursor);
    return pPack->last_modified;
}
FS_FileType getType(HFS_Cursor hCursor)
{
    filePackRef pPack = HCurosorToImpl(hCursor);
    return pPack->type;
}


///////////////////////////////////////////////////////////////////////////////////////////
/// native function
static int _fileWalker(fileScan_context_Ref pContext, char* pszPath)
{
    struct stat statbuf;
    struct dirent* dirp;
    DIR* dp;
    int ret = FS_Err_Success;
    char* ptr;
    
    if(pContext->fRun == FS_FALSE)
        return FS_Err_Canceled;
    
    if(FS_TRUE == pContext->fPause){
        if(0 == pthread_mutex_lock(&(pContext->pauseFlag))){
            pthread_mutex_unlock(&(pContext->pauseFlag));
        }
    }
    
    /*stat error*/
    if(lstat(pszPath, &statbuf) < 0)
        return _fileAnaly(pContext, pszPath, &statbuf, FO_NS);
    
    /*not a directory*/
    if(S_ISDIR(statbuf.st_mode) == 0)
        return _fileAnaly(pContext, pszPath, &statbuf, FO_F);
    
    
    /*is a directory*/
    if((ret = _fileAnaly(pContext, pszPath, &statbuf, FO_D)) != 0)
        return ret;
    
    
    /*pointer to the end of the full path*/
    ptr = pszPath + strlen(pszPath);
    *ptr++ = '/';
    *ptr = 0;
    
    /*we cannot read this directory*/
    if((dp = opendir(pszPath)) == NULL)
        return(_fileAnaly(pContext, pszPath, &statbuf, FO_DNR));
    
    while((dirp = readdir(dp)) != NULL)
    {

        
        /*dot & dot-dot*/
        if( (strcmp(dirp->d_name, ".") == 0) || (strcmp(dirp->d_name, "..") == 0) )
            continue;
        
        /*appending name after slash*/
        strcpy(ptr, dirp->d_name);
        
        if((ret = _fileWalker(pContext, pszPath)) != 0)
            break;
        
        //stop scanner
        ret = (pContext->fRun == FS_FALSE)? FS_Err_Canceled : FS_Err_Success;
        if(ret != FS_Err_Success)
            break;
        
        
        if(FS_TRUE == pContext->fPause){
            if(0 == pthread_mutex_lock(&(pContext->pauseFlag))){
                pthread_mutex_unlock(&(pContext->pauseFlag));
            }
        }
    }
    
    
    ptr[-1] = 0;
    
    if(closedir(dp) < 0)
        printf("cannot close directory %s", pszPath);
    
    if(NULL != pContext->cb_directory_end)
        pContext->cb_directory_end(pszPath, &statbuf, pContext->userData);
    
    
    return ret;
}



static int _fileAnaly(fileScan_context_Ref pContext, const char* pszPath, const struct stat* statptr, int FO_TYPE)
{
    //When use swith-case, the compiler will complain "Case label does not reduce to an integer constant"
    //However, clang is OK on this
    if(FO_TYPE == FO_F)
    {
        //Size filtering
        if((pContext->nSizeLimited==0) || (pContext->nSizeLimited >= statptr->st_size))
        {
            //mask
            FS_FileType type = _fileTypeMapping(statptr);
            if( (type & pContext->fileTypeMask) )
            {
                _packFileInfo(pContext, pszPath, type, statptr);
            }
        }
    }
    else if(FO_TYPE == FO_D)
    {
        if(NULL != pContext->cb_directory_start)
            pContext->cb_directory_start(pszPath, statptr, pContext->userData);
    }
    else if(FO_TYPE == FO_DNR)
    {
        if(NULL != pContext->cb_error)
            pContext->cb_error(pszPath, FS_Err_DirectoryUnreadable, pContext->userData);
    }
    else if(FO_TYPE == FO_NS)
    {
        if(NULL != pContext->cb_error)
            pContext->cb_error(pszPath, FS_Err_Stat, pContext->userData);
    }
    else
    {
        printf("WARNIGN: unknown type %d for pathname %s", FO_TYPE, pszPath);
    }
    
    
    
    return 0;
}

static int _packFileInfo(fileScan_context_Ref pContext, const char* pszPath, FS_FileType type, const struct stat* statptr)
{
    filePack pack;
    
    pack.path = pszPath;
    pack.size = (size_t)(statptr->st_size);
    
#if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
    pack.last_modified = (unsigned long long)statptr->st_mtimespec.tv_sec;
#else
    pack.last_modified = (unsigned long long)(statptr->st_mtime);
#endif //!defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
    
    pack.type = type;
    
    if((long long)(pack.size) <= (pContext->llMdbLimited) || 0 == (pContext->llMdbLimited))
    {
        MD5_File (pszPath, pack.md5);
    }
    
    
    if(NULL != pContext->cb_file)
        pContext->cb_file((HFS_Cursor)(&pack), pContext->userData);
    
    return 0;
}

static FS_FileType _fileTypeMapping(const struct stat* statptr)
{
    FS_FileType type;
    switch (statptr->st_mode & S_IFMT) {
        case S_IFIFO: /* named pipe (fifo) */
            type = FS_FileType_Pipe;
            break;
        case S_IFCHR: /* character special */
            type = FS_FileType_CharacterSpecial;
            break;
        case S_IFDIR: /* directory */
            type = FS_FileType_Directory;
            break;
        case S_IFBLK: /* block special */
            type = FS_FileType_BlockSpecial;
            break;
        case S_IFREG: /* regular */
            type = FS_FileType_Regular;
            break;
        case S_IFLNK: /* symbolck link */
            type = FS_FileType_SymbolLink;
            break;
        case S_IFSOCK: /* socket */
            type = FS_FileType_Socket;
            break;
        case S_IFWHT: /* whitout */
        default:
            type = FS_FileType_Other;
    }
    
    return type;
}








