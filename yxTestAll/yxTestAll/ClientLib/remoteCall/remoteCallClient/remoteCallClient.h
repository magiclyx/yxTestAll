//
//  remoteCallClient.h
//  remoteCall_client
//
//  Created by Yuxi Liu on 10/25/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "serverEventNotification.h"
#import "client_engine.h"
#import "../../targetProxy/targetProxy.h"
#import "../../hash/hashOnThread.h"

//extern int remoteCall_err_success;
//extern int remoteCall_err_unknown;
//extern int remoteCall_err_timeout;
//extern int remoteCall_err_param;


//some serious bug occurred.(e.g.  send data error.error = 22, Invalid argument)
//should merge some new future in remoteCall-module from yxLib.


//:~ TODO merge compress and poolManager features from remoteCall-module. (for error 22)
//:~ TODO merge elastic thread pool feature form remoteCall-module.



//:~ TODO merge sub Work Controller future from remoteCall-module.
/*the current struction can not distribute the msg to subProcess*/
/*With the increase of fetures in 360Safe, there will be more and more the child process is started. This is not what I want*/



/**/
//:~ TODO merge the following new feature form remoteCall-module in yxLib

/****************************************************************************************************/
/****************************************************************************************************/

//:~ TODO client should return all the calling when it prepare to shutdown.
//Now, when a client want to shutdown. The calling process, from the server, can just wait until timeout.
//tell the clientTool to scan the file

//not implemented -- by yuxi
//should add log reporter
//should deal with the err state

//see all the todo comment in implemention file(remoteCallClient.m)
/**/
/****************************************************************************************************/
/****************************************************************************************************/


/*
 remove all repetitive comment in the implemention file.
 
 Because I want to refactoring this module in future.
 */

#import "../remotePortInterface.h"

@interface remoteCallClient : NSObject<remotePortInterface>{
    @private
    HSLSelectClient _client;
    HTSH_Tble _funWaitTable;
    HTSH_Tble _funTable;
    
    //target
    targetProxy* _target;
    
    //delegate
    id<serverEventNotification> _delegate;
}

+(remoteCallClient*) sharedManager;
+(BOOL)sharedInstanceExists;
+(void)releaseManager;
-(id<serverEventNotification>)delegate;
-(void)setDelegate:(id<serverEventNotification>)Obj;


-(BOOL)connectToServer:(NSString*)clientName :(NSString*) address :(int) port;
-(void)closeConnection:(BOOL)tryToWait;


//add target
-(void)registerTarget:(id)newTarget;
-(void)removeTarget:(id)target;


- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond :(int*)err, ... ;
- (int)performRemoteSelectorNoWait:(SEL)aSelector :(int*)err, ...;
- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond  :(int*)err withPramArr:(NSArray*)params;


-(void)remoteLog:(NSString*)log withLevel:(int)level;

@end
