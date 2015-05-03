//
//  targetProxy.m
//  remoteCall_server
//
//  Created by Yuxi Liu on 10/28/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <pthread.h>

#import "targetProxy.h"


//@interface targetProxy(){
//    //target table
//    NSMutableDictionary* _targetDict;
//    pthread_rwlock_t _targetRWLock;
//}
//@end


@implementation targetProxy


-(void)registerTarget:(id)newTarget{
    pthread_rwlock_wrlock(&_targetRWLock);
    [_targetDict setObject:newTarget forKey:[NSNumber numberWithUnsignedLong:(unsigned long)newTarget]];
    pthread_rwlock_unlock(&_targetRWLock);
}


-(void)removeTarget:(id)target{
    pthread_rwlock_wrlock(&_targetRWLock);
    [_targetDict removeObjectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)target]];
    pthread_rwlock_unlock(&_targetRWLock);
}




-(id)init{
    _targetDict = [[NSMutableDictionary alloc] init];
    pthread_rwlock_init(&_targetRWLock, NULL);
    
    return self;
}



-(void)dealloc{
    pthread_rwlock_destroy(&_targetRWLock);
    
    [super dealloc];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *sig = nil;
    
    pthread_rwlock_rdlock(&_targetRWLock);
    NSArray* objs = [_targetDict allValues];
    for(id obj in objs){
        
        if(nil != (sig = [obj methodSignatureForSelector:aSelector]))
            break;
    }
    pthread_rwlock_unlock(&_targetRWLock);
    

    return sig;
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    
    id target = nil;
    
    pthread_rwlock_rdlock(&_targetRWLock);
    NSArray* objs = [_targetDict allValues];
    for(id obj in objs){
        
        if(nil != [obj methodSignatureForSelector:[invocation selector]]){
            target = obj;
            break;
        }
    }
    pthread_rwlock_unlock(&_targetRWLock);
    
    if(nil != target)
        [invocation invokeWithTarget:target];
}



- (BOOL)respondsToSelector:(SEL)aSelector {
    
    BOOL isResponds = NO;
    
    pthread_rwlock_rdlock(&_targetRWLock);
    NSArray* objs = [_targetDict allValues];
    for(id obj in objs){
        if([obj respondsToSelector:aSelector]){
            isResponds = YES;
            break;
        }
    }
    pthread_rwlock_unlock(&_targetRWLock);
    
    return isResponds;
}




@end
