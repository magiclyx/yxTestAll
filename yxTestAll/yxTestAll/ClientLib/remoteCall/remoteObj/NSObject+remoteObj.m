//
//  NSObject+remoteObj.m
//  testClass
//
//  Created by Yuxi Liu on 12/10/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import "NSObject+remoteObj.h"

@implementation NSObject (remoteObj)
-(NSObject*)toRemoteObj{
    return self;
}

-(id)initWithRemoteObj:(id)obj{
    
    self = [self init];
    
    id old = self;
    self = [obj retain];
    [old release];
    old = nil;
    
    
    return self;
}

@end

@implementation RMObject (remoteObj)

-(NSObject*)toRemoteObj{
    return [self toDictionary];
}

-(id)initWithRemoteObj:(id)obj{
    return [self initWithDictionary:obj];
}

@end


@implementation NSArray (remoteObj)

-(NSObject*)toRemoteObj{
    NSMutableArray* array = [NSMutableArray array];
    for(id<remoteObj> obj in self)
        [array addObject:[obj toRemoteObj]];
    
    return array;
}


-(id)initWithRemoteObj:(id)obj{
    NSArray* objArray = (NSArray*)obj;
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:[objArray count]];
    for(id<remoteObj> subObj in objArray){
        [array addObject:[[[subObj class] alloc] initWithRemoteObj:subObj]];
    }
    
    [self initWithArray:array];
    [array release];
    array = nil;
    
    return self;
}


@end

@implementation NSDictionary (remoteObj)

-(id)initWithRemoteObj:(id)obj{
    NSDictionary* objDict = (NSDictionary*)obj;
        
    NSArray* keys = [[NSArray alloc] initWithRemoteObj:[objDict allKeys]];
    NSArray* values = [[NSArray alloc] initWithRemoteObj:[objDict allValues]];
        
    [self initWithObjects:values forKeys:keys];
        
    [keys release];
    keys = nil;
        
    [values release];
    values = nil;
    
    return self;
}



-(NSObject*)toRemoteObj{
    NSArray* keys = (NSArray*)[[self allKeys] toRemoteObj];
    NSArray* values = (NSArray*)[[self allValues] toRemoteObj];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    
    return dict;
}

@end



