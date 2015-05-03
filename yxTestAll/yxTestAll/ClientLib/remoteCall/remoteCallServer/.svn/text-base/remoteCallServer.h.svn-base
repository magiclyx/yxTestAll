//
//  remoteCallServer.h
//  remoteCall_server
//
//  Created by Yuxi Liu on 10/25/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "clientEventNotification.h"
#import "../../hash/hashOnThread.h"
#import "../../targetProxy/targetProxy.h"
#import "server_engine.h"

#import "../remotePortInterface.h"

//extern int remoteCall_err_success;
//extern int remoteCall_err_unknown;
//extern int remoteCall_err_timeout;
//extern int remoteCall_err_param;

/*
 remove all repetitive comment in the implemention file.
 
 Because I want to refactoring this module in future.
 */


@interface remoteProxy : NSObject<remotePortInterface>{//use nsproxy in future.
    NSString* clientName;
    pid_t pid;
    BOOL isValidate;
    
    @private
    int _clientID;
    HTSH_Tble _funTable;
}

- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond :(int*)err, ... ;
- (int)performRemoteSelectorNoWait:(SEL)aSelector :(int*)err, ...;
- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond  :(int*)err withPramArr:(NSArray*)params;

- (void)close;
- (BOOL)isEqualToProxy:(remoteProxy*)aProxy;

@property(readonly, retain) NSString* clientName;
@property(readonly, assign) BOOL isValidate;
@property(readonly, assign) pid_t pid;

@end;



//some serious bug occurred.(e.g.  send data error.error = 22, Invalid argument)
//should merge some new future from in remoteCall-module.

//:~ TODO merge compress and poolManager features from remoteCall-module.
//:~ TODO merge elastic thread pool feature form remoteCall-module.



//:~ TODO merge sub Work Controller future from remoteCall-module in yxLib.
/*the current struction can not distribute the msg to subProcess*/
/*With the increase of fetures in 360Safe, there will be more and more the child process is started. This is not what I want*/



/**/
//:~ TODO merge the following new feature form remoteCall-module in yxLib

/****************************************************************************************************/
/****************************************************************************************************/

//:~ TODO the server should has the ability to close a connection
//:~ TODO turn off the long time no respond linkd.
//:~ TODO if a connection send wrong data format, close it or ignore it.


//:~ TODO see all the todo comment in the implemention file.(remoteCallServer.m)

/****************************************************************************************************/
/****************************************************************************************************/

@interface remoteCallServer : NSObject{
    
    @private
    HSLSelectServer _server;
    HTSH_Tble _funWaitTable;
    
    //target
    targetProxy* _target;
    
    //remote observer
    NSMutableDictionary* _obsDict;
    pthread_rwlock_t _obsRWLock;
    
    
    //remote proxy
    NSMutableDictionary* _remoteProxyDict;
    pthread_rwlock_t _rmoteProxyRWLock;
}

-(NSString*)test:(NSNumber*)num : (NSString*) str;

-(BOOL)setupServer:(int) port;
-(void)shutdownServer:(BOOL)tryToWait;


//instance manager
+(remoteCallServer*) sharedManager;
+(BOOL)sharedInstanceExists;
+(void)releaseManager;


//add target
-(void)registerTarget:(id)newTarget;
-(void)removeTarget:(id)target;

-(targetProxy*)target;


//add an client observer
-(void)addNewClientObserver:(NSString*)cliName :(id<clientEventNotification>)obs;
-(void)removeClientObserver:(NSString*)cliName :(id<clientEventNotification>)obs;


-(void)remoteLog:(NSString*)log withLevel:(int)level;


@end





