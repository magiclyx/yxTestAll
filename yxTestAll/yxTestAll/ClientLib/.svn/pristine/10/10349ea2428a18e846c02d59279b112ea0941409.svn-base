//
//  clientEventNotification.h
//  remoteCall_server
//
//  Created by Yuxi Liu on 10/29/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//


//use this protocal can give me more control on a client

#import <Foundation/Foundation.h>

@class remoteProxy;
@protocol clientEventNotification <NSObject>

@required
/*
Note!!!!!
//Do not remote or add client Observer in notification function. it will cause the thread deadlock!!
Note!!!!!
*/
-(void)clientConnected:(NSString*)cliName :(remoteProxy*)proxy;
-(void)clientClosed:(remoteProxy*)proxy;

//this useful??
//-(void)clientWillCallFunction:(SEL)aSelector;
//-(void)clientDidCallFunction:(SEL)aSelector;

@end
