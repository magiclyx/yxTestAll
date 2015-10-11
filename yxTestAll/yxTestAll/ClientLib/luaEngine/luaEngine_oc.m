//
//  luaEngine_oc.m
//  luaEngine
//
//  Created by Yuxi Liu on 9/24/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import "luaEngine_oc.h"
#import "basictype_luaEngine.h"


/*  A debug tool */
//I've tried to use the lua_typename. but it can not work correctly. why?

int luaEngine_distributeFun(lua_State* L);
static const NSString* distributeFunRgistName = @"callOCFunbyName"; //this name is used for lua script



@interface luaEngine_oc(){
    lua_State* _luaRTContext;
    targetProxy* _target;
}

- (NSString*) _findStdLibPackage:(NSString*)packageName withPath:(NSString*)path;
- (BOOL) _loadStdlib:(NSString*)path;
- (luaEngineError) _luaError2EngineError:(int)luaErr;


- (luaEngineError) _callLuaFunction:(NSString*)funName :(NSMutableArray*)rtVal :(NSMutableArray*)params;

@property(readonly, assign) targetProxy* target;

@end



@implementation luaEngine_oc



@synthesize target = _target;



-(void)RegistObject:(NSObject*)obj{
    [_target registerTarget:obj];
}


-(void)UnRegistObject:(NSObject*)obj{
    [_target removeTarget:obj];
}







#pragma mark lifecrycle
-(instancetype)initWithStdLibPath:(NSString*)path;
{
    
    if(self = [super init])
    {
        if(NULL == (_luaRTContext = luaL_newstate()))
        {
            NSLog(@"failed to create lua context");
            return nil;
        }
        
        
        luaL_openlibs(_luaRTContext);
        
        lua_register(_luaRTContext, [distributeFunRgistName UTF8String], luaEngine_distributeFun);
        
        
        _target = [[targetProxy alloc] init];
        
        
        if( NO == [self _loadStdlib:path] )
        {
            NSLog(@"failed to load lua stdlib");
            return nil;
        }
        
        
        luaEngineError err = [self callFunction:@"setInstance" withReturnValues:nil andParamsNum:1, [NSNumber numberWithUnsignedLong:(unsigned long)(void*)self]];
        if (luaEngine_error_success != err)
        {
            NSLog(@"failed to set instance");
            return nil;
        }
    }
    
    return self;
}

-(void)dealloc{
    
    lua_close(_luaRTContext);
        
    
    [_target release];
    _target = nil;
    
    
    [super dealloc];
}


#pragma mark public

-(luaEngineError) runChunkByPath:(NSString*)path{
    
    /**********luaL_dofile**********/
    int error = 0;
    if(0 != (error = luaL_loadfile(_luaRTContext, [path UTF8String])))
        return [self _luaError2EngineError:error];
    
    if(0 != (error = lua_pcall(_luaRTContext, 0, LUA_MULTRET, 0)))
        return [self _luaError2EngineError:error];
    
    return luaEngine_error_success;
}


-(luaEngineError) runChunkByBuff:(NSData*)data withName:(NSString*)name{
    
    /**********luaL_buff**********/
    int error = 0;
    
    
    if(0 != (error = luaL_loadbuffer(_luaRTContext, (const char*)[data bytes], [data length], [name UTF8String])))
        return [self _luaError2EngineError:error];
    
    if(0 != (error = lua_pcall(_luaRTContext, 0, LUA_MULTRET, 0)))
        return [self _luaError2EngineError:error];
    
    return luaEngine_error_success;
    
}



- (luaEngineError) callFunction:(NSString*)funName withReturnValues:(NSArray**)rtVal andParams:(NSArray*)params
{
    /*init the error*/
    luaEngineError error = luaEngine_error_success;
    
    
    /*mark the current stack*/
    int nTopFlag_BeforeCalling = lua_gettop(_luaRTContext);
    
    
    /*push the function name*/
    lua_getglobal(_luaRTContext, [funName UTF8String]);
    
    
    
    /*push the parameters*/
    if (nil != params)
    {
        for(NSObject<luaBinding>* obj in params)
        {
            [obj pushValue:_luaRTContext];
        }
    }
    
    
    
    
    /*call the function*/
    int rt;
    if(0 != (rt = lua_pcall(_luaRTContext, (int)[params count], LUA_MULTRET, 0)))
        return [self _luaError2EngineError:rt];
    
    
    
    /*fetch the return value*/
    int nTopFlag_AfterCalling = lua_gettop(_luaRTContext);
    
    if (NULL != rtVal)
    {
        NSMutableArray* return_list = [NSMutableArray arrayWithCapacity:nTopFlag_AfterCalling - nTopFlag_BeforeCalling];
        
        int index = nTopFlag_BeforeCalling;
        for(; index<nTopFlag_AfterCalling; index++)
        {
            switch (lua_type(_luaRTContext, index+1)) {
                case LUA_TNUMBER:
                case LUA_TBOOLEAN:
                    [return_list addObject:[NSNumber valueWithLuaState:_luaRTContext :index+1]];
                    break;
                case LUA_TSTRING:
                    [return_list addObject:[NSString valueWithLuaState:_luaRTContext :index+1]];
                    break;
                case LUA_TTABLE:
                    /*number or array*/
                    [return_list addObject:[NSMutableDictionary valueWithLuaState:_luaRTContext :index+1]];
                    break;
                default:
                    NSLog(@"unknow datatype");
            }
        }
        
        *rtVal = return_list;
    }
    
    
    /*reset the calling stack*/
    lua_pop(_luaRTContext, nTopFlag_AfterCalling - nTopFlag_BeforeCalling);
    
    
    return error;
}


- (luaEngineError) callFunction:(NSString*)funName withReturnValues:(NSArray**)rtVal andParamsNum:(int)paramNum, ...
{
    NSMutableArray* paramArr = [[NSMutableArray alloc] initWithCapacity:paramNum];
    
    va_list params;
    va_start(params, paramNum);
    for(int i=0; i<paramNum; i++){
        id param = va_arg(params, id);
        
        assert(YES == [param isKindOfClass:[NSObject class]]);
        
        [paramArr addObject:param];
    }
    
    luaEngineError err = [self callFunction:funName withReturnValues:rtVal andParams:paramArr];
    
    [paramArr release];
    
    return err;

}













- (NSObject<luaBinding>*) autoGet:(lua_State*)luaRTContext :(int)idx
{
    switch (lua_type(luaRTContext, idx)){
        case LUA_TBOOLEAN:
        case LUA_TNUMBER:
            return [NSNumber valueWithLuaState:luaRTContext :idx];
        case LUA_TSTRING:
            return [NSString valueWithLuaState:luaRTContext :idx];
            break;
        case LUA_TTABLE:
            break;
    };
    
    return nil;
}











///////////////////////////////////////////////////////////////////////
//private functions

- (BOOL) _loadStdlib:(NSString*)path
{
    BOOL isSuccess = NO;
    
    do{
        
        if (nil == path)
            break;
        
        NSString* runtimePackagePath = [self _findStdLibPackage:@"luaEngine_runtime" withPath:path];
        if (nil == runtimePackagePath)
            break;
        
        NSString* arrayPackagePath = [self _findStdLibPackage:@"luaEngine_MutableArray" withPath:path];
        if (nil == arrayPackagePath)
            break;
        
        
        if (luaEngine_error_success != [self runChunkByPath:runtimePackagePath])
            break;
        
        if (luaEngine_error_success != [self runChunkByPath:arrayPackagePath])
            break;
        
        isSuccess = YES;
        
        
    }while(0);
    
    
    return isSuccess;
}

- (NSString*) _findStdLibPackage:(NSString*)packageName withPath:(NSString*)path
{
    NSString* resultPath = nil;
    
    if (nil == packageName)
        return nil;
    
    NSString* packagePath = [path stringByAppendingPathComponent:@"luaEngine_runtime"];
    if(YES == [[NSFileManager defaultManager] fileExistsAtPath:packagePath])
        resultPath = packagePath;
    
    
#ifdef DEBUG
    if (nil == resultPath)
    {
        packagePath = [packagePath stringByAppendingPathExtension:@"lua"];
        if(YES == [[NSFileManager defaultManager] fileExistsAtPath:packagePath])
            resultPath = packagePath;
    }
#endif
    
    
//    if (nil != packagePath)
//    {
//        BOOL isValid = [self _fileSignVerify:packagePath];
//        if (NO == isValid)
//        {
//            packagePath = nil;
//        }
//    }
//    
    
    return resultPath;
}

- (luaEngineError) _luaError2EngineError:(int)luaErr{
    luaEngineError rtVal;
    switch(luaErr)
    {
        case 0:
            rtVal = luaEngine_error_success;
            break;
        case LUA_ERRFILE:
            rtVal = luaEngine_error_file;
            break;
        case LUA_ERRMEM:
            rtVal = luaEngine_error_mem;
            break;
        case LUA_ERRSYNTAX:
            rtVal = luaEngine_error_syntax;
            break;
        case LUA_ERRRUN:
            rtVal = luaEngine_error_runtime;
            break;
        case LUA_ERRERR:
            rtVal = luaEngine_error_errfun;
            break;
        default:
            rtVal = luaEngine_error_unknow;
            break;
    }
    
    return rtVal;

}



- (luaEngineError) _callLuaFunction:(NSString*)funName :(NSMutableArray*)rtVal :(NSMutableArray*)params{
    
    
    luaEngineError error = luaEngine_error_success;
    
    int nTopFlag_BeforeCalling = lua_gettop(_luaRTContext);
    
    lua_getglobal(_luaRTContext, [funName UTF8String]);
    
    
    for(NSObject<luaBinding>* obj in params)
    {
        [obj pushValue:_luaRTContext];
    }
    
    int rt;
    if(0 != (rt = lua_pcall(_luaRTContext, (int)[params count], LUA_MULTRET, 0)))
        return [self _luaError2EngineError:rt];
    
    int nTopFlag_AfterCalling = lua_gettop(_luaRTContext);
    int index = nTopFlag_BeforeCalling;
    for(; index<nTopFlag_AfterCalling; index++)
    {
        switch (lua_type(_luaRTContext, index+1)) {
            case LUA_TNUMBER:
            case LUA_TBOOLEAN:
                [rtVal addObject:[NSNumber valueWithLuaState:_luaRTContext :index+1]];
                break;
            case LUA_TSTRING:
                [rtVal addObject:[NSString valueWithLuaState:_luaRTContext :index+1]];
                break;
            case LUA_TTABLE:
                /*number or array*/
                [rtVal addObject:[NSMutableDictionary valueWithLuaState:_luaRTContext :index+1]];
                break;
            default:
                NSLog(@"unknow datatype");
        }
    }
    
    lua_pop(_luaRTContext, nTopFlag_AfterCalling - nTopFlag_BeforeCalling);
    
    
    return error;
}



-(void)debug_stack{
    luadebug_stack(_luaRTContext);
}

-(NSString*)debug_stackInfo{
    return luadebug_stackInfo(_luaRTContext);
}




@end




int luaEngine_distributeFun(lua_State* L){
    
    
    int nParamNum = lua_gettop(L);
    if(nParamNum < 1)
        return (int)luaEngine_error_param;
    
    
    if(!lua_istable(L, 1))
        return (int)luaEngine_error_param;
    
    
    NSDictionary* callingDict = [NSDictionary valueWithLuaState:L :1];
    if(nil == callingDict)
        return (int)luaEngine_error_param;
    
    NSNumber* engineAddress = [callingDict objectForKey:@"engine_address"];
    if (nil == engineAddress  ||  NO == [engineAddress isKindOfClass:[NSNumber class]])
        return (int)luaEngine_error_param;
    
    unsigned long engineAddressValue = [engineAddress unsignedLongValue];
//    if (yx_false == isPtr((void*)engineAddressValue))
//        return (int)luaEngine_error_param;
    
    
    
    luaEngine_oc* engine = (luaEngine_oc*)(unsigned long)engineAddressValue;
    if (NO == [engine isKindOfClass:[luaEngine_oc class]])
        return (int)luaEngine_error_param;
    
    
    NSString* funName = [callingDict objectForKey:@"function_name"];
    if(nil == funName  ||  NO == [funName isKindOfClass:[NSString class]])
        return (int)luaEngine_error_param;
    
    
    NSDictionary* paramDict = [callingDict objectForKey:@"param_list"];
    if(nil == paramDict  ||  NO == [paramDict isKindOfClass:[NSDictionary class]])
        return (int)luaEngine_error_param;
    
    
    targetProxy* target = [engine target];
    if (nil == target)
        return (int)luaEngine_error_param;
    
    
    NSMethodSignature* sig = [target methodSignatureForSelector:NSSelectorFromString(funName)];
    
#ifdef DEBUG
    if(nil == sig){
        NSLog(@"luaEngine");
        NSLog(@"lua->C  can not found a function:%@", funName);
        assert(0);
    }
#endif
    
    int rtVal = 0;
    if(nil != sig)
    {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:target];
        [invocation setSelector:NSSelectorFromString(funName)];
        
        
        int ndictCount = (int)[paramDict count];
        for(int index=0; index<ndictCount; index++){
            NSString* key = [NSString stringWithFormat:@"_param_%d", index+1];
            id param = [paramDict objectForKey:key];
            assert(nil != param);
            [invocation setArgument:&param atIndex:index+2];
        }
        
        
        
        
        
        @try {
            [invocation invoke];
        }
        @catch (NSException *exception) {
            NSArray *arr = [exception callStackSymbols];
            NSString *reason = [exception reason];
            NSString *name = [exception name];
            
            NSLog(@"an exception on remote call");
            NSString* log = [NSString stringWithFormat:@"%@\n%@\n%@\n", name, reason, arr];
            NSLog(@"%@", log);
            assert(0);
        }
        
        
        
        rtVal = 0;
        const char* returnType = sig.methodReturnType;
        const char cursor = *returnType;
        
        switch (cursor)
        {
            case '^':
            {
                void* returnValue = NULL;
                [invocation getReturnValue:&returnValue];
                
                lua_pushlightuserdata(L, returnValue);
                
                rtVal = 1;
            }
            break;
                
            case '@':
            {
                id returnValue = nil;
                [invocation getReturnValue:&returnValue];
                
                
                if (nil == returnValue)
                {
                    returnValue = [NSNull null];
                }
                
                
                [returnValue pushValue:L];
                
                rtVal = 1;

            }
                
            break;
                
            case 'V':
                rtVal = 0;
                break;
            case 'B':
            {
                BOOL returnValue;
                [invocation getReturnValue:&returnValue];
                
                lua_pushboolean(L, (int)returnValue);
                
                rtVal = 1;
            }
                break;
            case 'i':
            {
                int returnValue;
                [invocation getReturnValue:&returnValue];
                
                lua_pushinteger(L, returnValue);
                
                rtVal = 1;
            }
                break;
            case 'I':
            {
                unsigned int returnValue;
                [invocation getReturnValue:&returnValue];
                
                lua_pushunsigned(L, returnValue);
                
                rtVal = 1;
            }
                break;
            case 'q':
            {
                long returnValue;
                [invocation getReturnValue:&returnValue];

                lua_pushinteger(L, returnValue);
                
                rtVal = 1;
            }
                break;
            case 'Q':
            {
                unsigned long returnValue;
                [invocation getReturnValue:&returnValue];

                lua_pushnumber(L, (double)returnValue);
                
                rtVal = 1;
            }
                break;
            case 's':
            {
                short returnValue;
                [invocation getReturnValue:&returnValue];

                lua_pushinteger(L, returnValue);
                
                rtVal = 1;
            }
                break;
            case 'S':
            {
                unsigned short returnValue;
                [invocation getReturnValue:&returnValue];

                lua_pushunsigned(L, returnValue);
                
                rtVal = 1;
            }
                break;
            case 'c':
            case 'C':
            {
                char returnValue;
                [invocation getReturnValue:&returnValue];
                
                
                [[NSString stringWithFormat:@"%c", (char)returnValue] pushValue:L];
                
                
                rtVal = 1;
            }
                break;
            case ':':
            {
                SEL returnValue;
                [invocation getReturnValue:&returnValue];
                
                NSString* funName = NSStringFromSelector(returnValue);
                if (nil != funName)
                {
                    [funName pushValue:L];
                }

                rtVal = 1;
            }
                break;
                
            default:
                rtVal = 0;
                break;
        }
        
        
    }
    return rtVal;
}

