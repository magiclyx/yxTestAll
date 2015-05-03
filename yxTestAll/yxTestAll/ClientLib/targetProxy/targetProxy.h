///
//  targetProxy.h
//  remoteCall_server
//
//  Created by Yuxi Liu on 10/28/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface targetProxy : NSProxy{
    
    @private
    NSMutableDictionary* _targetDict;
    pthread_rwlock_t _targetRWLock;
}

-(id)init;
-(void)registerTarget:(id)newTarget;
-(void)removeTarget:(id)target;

@end
