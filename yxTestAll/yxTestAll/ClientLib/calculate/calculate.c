//
//  calculate.c
//  360ClientUI
//
//  Created by Yuxi Liu on 11/9/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#include <stdio.h>
#include <assert.h>

#include "calculate.h"

void descriptDataSizeWithBlockAndPrecision(size_t aSize, char* pszBuff, size_t bufSize, int dataSize, unsigned int precision){
    assert(NULL != pszBuff);
    
    if(precision > 5)
        precision = 5;
    
    static unsigned int oldPrecision = 100;
    static char precisionFormat[100];
    if(precision != oldPrecision){
        sprintf(precisionFormat, "%%.%dlf %%s", precision);
        oldPrecision = precision;
    }
    
    
    static const char* pcszFlag[] = {"Byte", "KB", "MB", "GB", "TB", "unknown"};
    int curFlag=0;
    
    
    double size=aSize;
    for(; ((size>=calculate_datasize_flag)&&(curFlag<sizeof(pcszFlag)/sizeof(pcszFlag[0]))); size=size/dataSize, curFlag++);
    
    if(curFlag > 4){
        assert(0);
        curFlag = 5;
    }
    
    snprintf(pszBuff, bufSize, precisionFormat, size, pcszFlag[curFlag]);
}

void descriptDataSize(size_t aSize, char* pszBuff, size_t bufSize){
    descriptDataSizeWithBlockAndPrecision(aSize, pszBuff, bufSize, calculate_datasize_flag, calculate_precision_flag);
}

void descriptDataSizeWithPrecision(size_t aSize, char* pszBuff, size_t bufSize, unsigned int precision){
    descriptDataSizeWithBlockAndPrecision(aSize, pszBuff, bufSize, calculate_datasize_flag, precision);
}

void descriptDataSizeWithBlock(size_t aSize, char* pszBuff, size_t bufSize, int dataSize){   
    descriptDataSizeWithBlockAndPrecision(aSize, pszBuff, bufSize, dataSize, calculate_precision_flag);
}



