//
//  FileScaner.h
//  FileWalker
//
//  Created by Yuxi Liu on 8/31/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//


#ifndef __FileWalker__FileScaner__
#define __FileWalker__FileScaner__

#include <sys/stat.h>

#ifdef __cplusplus
extern "C"{
#endif

typedef void* HFS_SCaner;
typedef void* HFS_Cursor; 

//////////////////////////////////////////////////////////////////////////////
typedef enum {FS_Err_Success=0, FS_Err_Stat, FS_Err_FileUnreadable, FS_Err_DirectoryUnreadable, FS_Err_Canceled}FS_Error;

//////////////////////////////////////////////////////////////////////////////
typedef enum {FS_FileType_Regular=1, FS_FileType_Pipe=2, FS_FileType_CharacterSpecial=4
    , FS_FileType_Directory=8, FS_FileType_BlockSpecial=16, FS_FileType_SymbolLink=32
    , FS_FileType_Socket=64, FS_FileType_Other=128, FS_FileType_ALL=65535}FS_FileType;

//Some call_back function
typedef void (*FS_callback_directory_start)(const char* pszPath, const struct stat* statptr, void* userData); //found a directory
typedef void (*FS_callback_directory_end)(const char* pszPath, const struct stat* statptr, void* userData);  //leave a directory
typedef void (*FS_callback_file)(HFS_Cursor hCursor, void* userData); //found a file
typedef void (*FS_callback_error)(const char* pszPath, FS_Error erryrType, void* userData); //error!



/////////////////////////////////////////////////////////////////////////////
//About the Scanner

HFS_SCaner FS_Init(unsigned long FileTypeMask, size_t nSizeLimit, FS_callback_directory_start cb_directory_start, FS_callback_directory_end cb_directory_end, FS_callback_file cb_file, FS_callback_error cb_error);
void FS_Release(HFS_SCaner* pHandle);



void FS_Md5Limited(HFS_SCaner* pHandle, long long fileSize);
int FS_Scaner(HFS_SCaner hScaner, const char* pszPath, void* userData);
int FS_Stop(HFS_SCaner hScaner);
int FS_Pause(HFS_SCaner hScaner);
int FS_Resume(HFS_SCaner hScaner);





/////////////////////////////////////////////////////////////////////////////
//About the Cursor -- You should not save the cursor
void FS_GetMd5(HFS_Cursor hCursor, unsigned char md5[16]);
void FS_GetPath(HFS_Cursor hCursor, char* pszPath, size_t len);
size_t FS_GetSize(HFS_Cursor hCursor);
unsigned long long getLastModified(HFS_Cursor hCursor);
FS_FileType getType(HFS_Cursor hCursor);

#ifdef __cplusplus
}
#endif

#endif /* defined(__FileWalker__FileScaner__) */











