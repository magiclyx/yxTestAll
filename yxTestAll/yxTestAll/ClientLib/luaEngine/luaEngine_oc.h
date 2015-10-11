//
//  luaEngine_oc.h
//  luaEngine
//
//  Created by Yuxi Liu on 9/24/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>


#include "./lua/lua.h"
#include "./lua/lualib.h"
#include "./lua/lauxlib.h"


#import "../targetProxy/targetProxy.h"

/************************/
//:~ 3 bugs here
/************************/

typedef enum {
    luaEngine_error_success = 0, //success
    luaEngine_error_param, //wrong parameters
    luaEngine_error_retValLess, //the length of your array is not enough to accept all the return values
    luaEngine_error_retValBeyond, //the length of yor array is too much.
    
    luaEngine_error_file, //can not open or read the file
    luaEngine_error_mem, //memory allocation error
    luaEngine_error_syntax, //syntax error during pre-compilation
    luaEngine_error_runtime, //script run time error
    luaEngine_error_errfun, //error while running the error handler function
    
    luaEngine_error_unknow  //unknown error
}luaEngineError;



@interface luaEngine_oc : NSObject

-(instancetype)initWithStdLibPath:(NSString*)path;

-(void)RegistObject:(NSObject*)obj;
-(void)UnRegistObject:(NSObject*)obj;

-(luaEngineError) runChunkByPath:(NSString*)path;
-(luaEngineError) runChunkByBuff:(NSData*)data withName:(NSString*)name;


- (luaEngineError) callFunction:(NSString*)funName withReturnValues:(NSArray**)rtVal andParams:(NSArray*)params;
- (luaEngineError) callFunction:(NSString*)funName withReturnValues:(NSArray**)rtVal andParamsNum:(int)paramNum, ...;



-(void)debug_stack;
-(NSString*)debug_stackInfo;

@end














