//
//  errInfo.h
//  360ClientUI
//
//  Created by Yuxi Liu on 10/31/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#ifndef _60ClientUI_errInfo_h
#define _60ClientUI_errInfo_h

#ifdef __cplusplus
extern "C"{
#endif

    

/*
OSStatus_dummy need <MacTypes.h> files. OSStatus_dummy can help other module do not reference this header file.
*/
    
#ifdef __LP64__
    typedef signed int OSStatus_dummy;
#else
    typedef signed long OSStatus_dummy;
#endif
int OSStatusToErrno(OSStatus_dummy errNum);

    
    
    
    
#ifdef __cplusplus
}
#endif
    
    
    
#endif
