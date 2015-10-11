//
//  threadpool.h
//  TestSelectServer
//
//  Created by Yuxi Liu on 10/18/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#ifndef THREADPOOL_H_
#define THREADPOOL_H_


#ifdef __cplusplus
extern "C"{
#endif


typedef void* HTPthreadPool;
    
//:~ 2 bugs here

//:~ TODO Need a flexible thread pool
//:~ TODO This is a light memory pool, can not auto increment
//:~ TODO Need to reconstruction
HTPthreadPool threadpool_init(int num_of_threads);
int threadpool_add_task(HTPthreadPool handle, void (*routine)(void*), void *data, int blocking);
void threadpool_free(HTPthreadPool* handleRef, int blocking);

    
#ifdef __cplusplus
}
#endif

    
#endif /* THREADPOOL_H_ */
