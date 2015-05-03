//
//  test.c
//  testRemoveFileOrFolder
//
//  Created by Yuxi Liu on 3/15/13.
//  Copyright (c) 2013 Yuxi Liu. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fileSys.h"
#include "FileScaner.h"


const static char* _sys_tmp_dir_env = "TMPDIR";
const static char* _sys_tmp_pre_fix = "asd";

char* tempFilePath(char* buff, size_t len){
    
    int isDone = 0;
    
    char* tmpDir = getenv(_sys_tmp_dir_env);
    if(NULL != tmpDir){
        char* tmpFile = tempnam(tmpDir, _sys_tmp_pre_fix);
        if(NULL != tmpFile){
            strncpy(buff, tmpFile, len-1);
            buff[len-1] = '\0';
            isDone = 1;
        }
    }
    
    if(0 == isDone){
        char tmpFile[L_tmpnam];
        if(NULL != tmpnam(tmpFile)){
            strncpy(buff, tmpFile, len-1);
            buff[len-1] = '\0';
            isDone = 1;
        }
    }
    
    
    return (1 == isDone)? buff : NULL;
}



//removeFileOrDirectory
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////



const static unsigned int _max_file_path_buff_len = 1024*10;





static void callback_rmFileOrDirectory_directory_end(const char* pszPath, const struct stat* statptr, void* userData);
static void callback_rmFileOrDirectory_file(HFS_Cursor hCursor, void* userData);
static void callback_rmFileOrDirectory_error(const char* pszPath, FS_Error erryrType, void* userData);

int removeFileOrDirectory(const char* path){
    HFS_SCaner handle = FS_Init(FS_FileType_ALL, 0, NULL, callback_rmFileOrDirectory_directory_end, callback_rmFileOrDirectory_file, callback_rmFileOrDirectory_error);
    FS_Scaner(handle, path, NULL);
    FS_Release(&handle);
    
    return 0;
}



static void callback_rmFileOrDirectory_directory_end(const char* pszPath, const struct stat* statptr, void* userData){
    remove(pszPath);
}
static void callback_rmFileOrDirectory_file(HFS_Cursor hCursor, void* userData){
    
    char buff[_max_file_path_buff_len+1];
    FS_GetPath(hCursor, buff, _max_file_path_buff_len);
    buff[_max_file_path_buff_len] = '\0';
    
    remove(buff);
}
static void callback_rmFileOrDirectory_error(const char* pszPath, FS_Error erryrType, void* userData){
    remove(pszPath);
}


///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////