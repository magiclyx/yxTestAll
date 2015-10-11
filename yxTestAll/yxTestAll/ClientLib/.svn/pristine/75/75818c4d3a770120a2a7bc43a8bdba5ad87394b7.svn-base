//
//  encryByRandomDict.c
//  encryptionOnTable
//
//  Created by Yuxi Liu on 12/20/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <math.h>

#include <limits.h>


#include "../cm/cmMem.h"
#include "encryByRandomDict.h"


const unsigned int encryByRandomDict_max_key_base = 100;




// Small prime number used as a multiplier in the supplied hash functions
const unsigned int RANDOM_DICT_HASH_MULTIPLIER = 101;

#define RANDOM_DICT_HASH_SHIFT_MULTIPLY  //force to use MULTIPLY

#ifdef RANDOM_DICT_HASH_SHIFT_MULTIPLY
# define RANDOM_DICT_HASH_MULTIPLY(dw)   (((dw) << 7) - (dw))
#else
# define RANDOM_DICT_HASH_MULTIPLY(dw)   ((dw) * RANDOM_DICT_HASH_MULTIPLIER)
#endif


#define random_dict_setEncrypt(context_ptr, tableNum, index, code) ((((context_ptr->dict)[tableNum]).encry_table)[index] = code)
#define random_dict_setDecrypt(context_ptr, tableNum, index, code) ((((context_ptr->dict)[tableNum]).decrypt_table)[index] = code)
#define random_dict_encrypt(contex_ptr, char, tableNum) ((((contex_ptr->dict)[tableNum]).encry_table)[char])
#define random_dict_decrypt(contex_ptr, char, tableNum) ((((contex_ptr->dict)[tableNum]).decrypt_table)[char])

#define random_dict_handle2contextRef(handle)  ((_random_dict_encry_context_ref)handle)

typedef struct{
    unsigned char encry_table[256];
    unsigned char decrypt_table[256];
}_random_dict_, *_random_dict_ref_;

typedef struct{
    unsigned int seed;
    unsigned int currentKey;
    unsigned int dictNum;
    _random_dict_ref_ dict;
}_random_dict_encry_context, *_random_dict_encry_context_ref;




static int _nativeKeyIterator (unsigned int *key);
static void _initDict(_random_dict_encry_context_ref context, int tableNum);



HERandomDict ERD_createRandomDictEncryption(unsigned int seedKey, unsigned int dictNum){
    
    _random_dict_ref_ table = NULL;
    _random_dict_encry_context_ref context = NULL;
    
    
    context = (_random_dict_encry_context_ref)MALLOC(sizeof(_random_dict_encry_context));
    if(NULL == context)
        goto errout;
    
    
    table = (_random_dict_ref_)MALLOC(sizeof(_random_dict_)*dictNum);
    if(NULL == table)
        goto errout;
    
    
    context->dictNum = dictNum;
    context->seed = seedKey;
    context->currentKey = seedKey;
    context->dict = table;
    
    
    for(int i=0; i<dictNum; i++)
        _initDict(context, i);
    
    
    
    return (HERandomDict)context;
    
errout:
    
    if(NULL != table)
        FREE(table);

    if (NULL != context)
        FREE(context);
    
    return NULL;
    
}
void ERD_releaseRandomDictEncryption(HERandomDict* pHandle){

    if(NULL == pHandle || NULL == *pHandle)
        return;
    
    
    _random_dict_encry_context_ref context = random_dict_handle2contextRef(*pHandle);
    *pHandle = NULL;
    
    
    FREE(context->dict);
    FREE(context);
    
}

unsigned int ERD_seedKeyFromString(const char* key, unsigned int keyBase){
    
    if(NULL == key)
        return (unsigned int)(time(NULL));
    
    
    keyBase = (0==keyBase? strlen(key)+17 : keyBase) % encryByRandomDict_max_key_base;
    
    
    // force compiler to use unsigned arithmetic
    const unsigned char* upsz = (const unsigned char*) key;
    
    for ( ; *upsz; ++upsz)
        keyBase = RANDOM_DICT_HASH_MULTIPLY(keyBase) + *upsz;
    
    return keyBase;
}


unsigned int ERD_currentSeedKey(HERandomDict handle){
    
    assert(NULL != handle);
    
    _random_dict_encry_context_ref context = random_dict_handle2contextRef(handle);
    return context->seed;
}

void ERD_encrypt(HERandomDict handle, unsigned char* pszDst, const unsigned char* pszSrc, size_t len){
    
    assert(NULL != pszDst);
    assert(NULL != pszSrc);
    assert(NULL != handle);
    
    _random_dict_encry_context_ref context = random_dict_handle2contextRef(handle);
    int dictNum = context->dictNum;
    
    
    int index = 0;
    while (index<len){
        for(int currentDict = 0; index<len && currentDict<dictNum; currentDict++){
            pszDst[index] = random_dict_encrypt(context, pszSrc[index], currentDict);
            index++;
        }
    }
    
}
void ERD_decrypt(HERandomDict handle, unsigned char* pszDst, const unsigned char* pszSrc, size_t len){
    assert(NULL != pszDst);
    assert(NULL != pszSrc);
    assert(NULL != handle);
    
    _random_dict_encry_context_ref context = random_dict_handle2contextRef(handle);
    int dictNum = context->dictNum;
    
    int index = 0;
    while (index<len){
        for(int currentDict = 0; index<len && currentDict<dictNum; currentDict++){
            pszDst[index] = random_dict_decrypt(context, pszSrc[index], currentDict);
            index++;
        }
    }
    
}






static int _nativeKeyIterator (unsigned int *key)
{
    
    assert(sizeof(unsigned int) == 4);
    
    unsigned int next = *key;
    int nexKey;
    
    next *= 1103515245; //10 bit
    next += 12345; //5 bit Aha, ha~~ha~~~~
    nexKey = (unsigned int) (next / 65536) % 2048;
    
    next *= 1103515245;
    next += 12345;
    nexKey <<= 10;
    nexKey ^= (unsigned int) (next / 65536) % 1024;
    
    next *= 1103515245;
    next += 12345;
    nexKey <<= 10;
    nexKey ^= (unsigned int) (next / 65536) % 1024;
    
    *key = next;
    
    return nexKey;
}



static void _initDict(_random_dict_encry_context_ref context, int tableNum){
    
    char flag[256];
    memset(flag, 0, 256);
    
    for(int i=0; i<256; i++){
        
        _nativeKeyIterator(&(context->currentKey));
        unsigned char code = (unsigned char)(context->currentKey % 256);
        while (0 != flag[code])
            code = abs((code+1) % 256);
        
        flag[code] = 1;
        random_dict_setEncrypt(context, tableNum, i, code);
        random_dict_setDecrypt(context, tableNum, code, i);
    }
    
}













