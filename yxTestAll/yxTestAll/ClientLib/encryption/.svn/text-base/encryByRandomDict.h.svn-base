//
//  encryByRandomDict.h
//  encryptionOnTable
//
//  Created by Yuxi Liu on 12/20/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#ifndef cmlib_encryByRandomDict_h
#define cmlib_encryByRandomDict_h


#ifdef __cplusplus
extern "C"{
#endif

/************************/
//:~ low perform without my mempool->localPool
/************************/


typedef void* HERandomDict;

extern const unsigned int encryByRandomDict_max_key_base;


//if key is NULL, use current time as it's key.
HERandomDict ERD_createRandomDictEncryption(unsigned int seedKey, unsigned int dictNum);
void ERD_releaseRandomDictEncryption(HERandomDict* pHandle);

unsigned int ERD_seedKeyFromString(const char* key, unsigned int keyBase);
unsigned int ERD_currentSeedKey(HERandomDict handle);


//the src and the dist can be the same buff
void ERD_encrypt(HERandomDict handle, unsigned char* pszDst, const unsigned char* pszSrc, size_t len);
void ERD_decrypt(HERandomDict handle, unsigned char* pszDst, const unsigned char* pszSrc, size_t len);

#ifdef __cplusplus
}
#endif


#endif
