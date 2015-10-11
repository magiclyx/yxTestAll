//
//  test.h
//  testSystemReport
//
//  Created by Yuxi Liu on 10/30/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#ifndef testSystemReport_test_h
#define testSystemReport_test_h

#ifdef __cplusplus
extern "C"{
#endif


typedef void* HPOPOPEN;


//:~ bugs here
//:~ TODO current version just support the "r" or "w" operation.
//you can't use this two types at the same time. It is possible to support the "rw" operation.


HPOPOPEN posix_popen(const char *cmdstring, const char *type);
//return child's termination status
int posix_pclose(HPOPOPEN* handleRef);

int posix_pwrite(HPOPOPEN handle, const void *buf, size_t bufSize, size_t *bytesWritten);
int posix_pread(HPOPOPEN handle, void *buf, size_t bufSize, size_t *bytesRead);

    
    
#ifdef __cplusplus
}
#endif
    
    
#endif
