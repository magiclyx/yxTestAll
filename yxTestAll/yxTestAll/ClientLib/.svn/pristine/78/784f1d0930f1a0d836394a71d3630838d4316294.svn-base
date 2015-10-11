//
//  NSObject+remoteObj.h
//  testClass
//
//  Created by Yuxi Liu on 12/10/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "remoteObj.h"
#import "RMObject.h"

@interface NSObject (remoteObj)<remoteObj>
-(NSObject*)toRemoteObj;
-(id)initWithRemoteObj:(id)obj;
@end


@interface NSArray (remoteObj)<remoteObj>
-(NSObject*)toRemoteObj;
-(id)initWithRemoteObj:(id)obj;
@end

//assert!!!  All user-defined variables must inherit from RMObject
@interface NSDictionary (remoteObj)<remoteObj>
-(NSObject*)toRemoteObj;
-(id)initWithRemoteObj:(id)obj;
@end



@interface RMObject (rmoteObj)<remoteObj>
-(NSObject*)toRemoteObj;
-(id)initWithRemoteObj:(id)obj;
@end


