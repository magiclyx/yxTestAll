//
//  md5.h
//  FileWalker
//
//  Created by Yuxi Liu on 8/31/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#ifndef FileWalker_md5_h
#define FileWalker_md5_h

#ifdef __cplusplus
extern "C"{
#endif


/************************/
//:~ 1 bug here
/************************/
    
typedef void* MD5Ref;

/////////////////////////////////////////////////////////////
MD5Ref MD5_Init ();
void MD5_Release (unsigned char digest[16], MD5Ref* md5ref);

void MD5_Update (MD5Ref md5ref, unsigned char *input, size_t inputLen);
void MD5_UpdaterString(MD5Ref md5ref, const char *string);
int MD5_FileUpdateFile (MD5Ref md5ref, char *filename);
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
void MD5_String (char *string, unsigned char digest[16]);
int MD5_File (const char *filename, unsigned char digest[16]);

    
#ifdef __cplusplus
}
#endif


#endif
