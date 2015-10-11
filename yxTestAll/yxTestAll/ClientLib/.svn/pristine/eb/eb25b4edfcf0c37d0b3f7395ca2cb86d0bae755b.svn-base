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


static luaEngine_oc* g_luaEngineBridge_oc_instance = nil;



int luaEngine_distributeFun(lua_State* L);
static const NSString* distributeFunRgistName = @"callOCFunbyName"; //this name is used for lua script




@interface luaEngine_oc()//{
//@private
//    lua_State* _luaRTContext;
//    //NSMutableDictionary* _objDict;
//    targetProxy* _target;
//}

- (luaEngineError) _luaError2EngineError:(int)luaErr;
- (luaEngineError) _callLuaFunction:(NSString*)funName :(NSMutableArray*)rtVal :(NSMutableArray*)params;

@property(readonly, assign) targetProxy* target;

@end



@implementation luaEngine_oc



-(void)RegistObject:(NSObject*)obj{
    [_target registerTarget:obj];
}


-(void)UnRegistObject:(NSObject*)obj{
    [_target removeTarget:obj];
}




@synthesize target = _target;



-(id)init{
    
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

    }
    
    return self;
}

-(void)dealloc{
    
    lua_close(_luaRTContext);
        
    
    [_target release];
    _target = nil;
    
    [super dealloc];
}



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

-(luaEngineError) callLuaFunction:(NSString*)scriptPath :(NSString*)funName :(NSMutableArray*)rtVal :(NSMutableArray*)params{
    
    luaEngineError error = luaEngine_error_success;
    
    if(nil != scriptPath)
    {
        error = [self runChunkByPath:scriptPath];
        if(error != luaEngine_error_success)
            return error;
    }
    
    
    return [self _callLuaFunction:funName :rtVal :params];
    
}

-(luaEngineError) callLuaFunctionEx:(NSString*)scriptPath :(NSString*)funName :(NSMutableArray*)rtVal :(int)paramNum,...{
    
    NSMutableArray* paramArr = [[NSMutableArray alloc] initWithCapacity:paramNum];
    
    va_list params;
    va_start(params, paramNum);
    for(int i=0; i<paramNum; i++){
        id param = va_arg(params, id);
        [paramArr addObject:param];
    }
    
    
    luaEngineError err = [self callLuaFunction:scriptPath :funName :rtVal :paramArr];
    
    
    [paramArr removeAllObjects];
    [paramArr release];
    paramArr = nil;
    
    return err;
}

-(luaEngineError) callLuaFunctionWithBunchBuff:(NSData*)data :(NSString*)bundleName :(NSString*)funName :(NSMutableArray*)rtVal :(NSMutableArray*)params{
    
    luaEngineError error = luaEngine_error_success;
    
    if(nil != data  &&  nil != bundleName)
    {
        error = [self runChunkByBuff:data withName:bundleName];
        if(error != luaEngine_error_success)
            return error;
    }
    
    
    return [self _callLuaFunction:funName :rtVal :params];
    
}

-(luaEngineError) callLuaFunctionWithBunchBuffEx:(NSData*)data :(NSString*)bundleName :(NSString*)funName :(NSMutableArray*)rtVal :(int)paramNum,...{
    NSMutableArray* paramArr = [[NSMutableArray alloc] initWithCapacity:paramNum];
    
    va_list params;
    va_start(params, paramNum);
    for(int i=0; i<paramNum; i++){
        id param = va_arg(params, id);
        [paramArr addObject:param];
    }
    
    
    luaEngineError err = [self callLuaFunctionWithBunchBuff:data :bundleName :funName :rtVal : paramArr];
    
    
    [paramArr removeAllObjects];
    [paramArr release];
    paramArr = nil;
    
    return err;
}




/////////////////////////////////////////////////////////////////////////////////////////
/*single operation*/
/////////////////////////////////////////////////////////////////////////////////////////

+(luaEngine_oc*) sharedManager{
    @synchronized(self){
        if(nil == g_luaEngineBridge_oc_instance){
            [[self alloc] init]; //assigment not done here
        }
    }
    
    
    return g_luaEngineBridge_oc_instance;
}

+(BOOL)sharedInstanceExists{
    return (g_luaEngineBridge_oc_instance != nil ? YES : NO);
}

+(void)releaseManager{
    @synchronized(self){
        if(nil != g_luaEngineBridge_oc_instance){
            luaEngine_oc* tmpInstance = g_luaEngineBridge_oc_instance;
            g_luaEngineBridge_oc_instance = nil;  //Just when g_luaEngineBridge_oc_instance is equal to nil, the release operation will do the free work.
            [tmpInstance release];
        }
    }
}






+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (g_luaEngineBridge_oc_instance == nil) {
            g_luaEngineBridge_oc_instance = [super allocWithZone:zone];
            return g_luaEngineBridge_oc_instance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release
{
    if(nil == g_luaEngineBridge_oc_instance)
        [self dealloc];
    
    //do nothing
}

- (id)autorelease
{
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////










///////////////////////////////////////////////////////////////////////
//private functions

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















//int luaEngine_distributeFun(lua_State* L){
//    
//    
//    int nParamNum = lua_gettop(L);
//    if(nParamNum < 1)
//        return (int)luaEngine_error_param;
//    
//    
//    if(!lua_isstring(L, 1))
//        return (int)luaEngine_error_param;
//    
//    NSString* funName = [NSString valueWithLuaState:L :1];
//    
//    NSMutableArray* params = [NSMutableArray arrayWithCapacity:nParamNum-1];
//    for(int i=1; i<nParamNum; i++)
//    {
//        switch (lua_type(L, i+1)) {
//            case LUA_TNUMBER:
//            case LUA_TBOOLEAN:
//                [params addObject:[NSNumber valueWithLuaState:L :i+1]];
//                break;
//            case LUA_TSTRING:
//                [params addObject:[NSString valueWithLuaState:L :i+1]];
//                break;
//            case LUA_TTABLE:
//                /*dictioanry or array*/
//                [params addObject:[NSMutableDictionary valueWithLuaState:L :i+1]];
//                break;
//            default:
//                NSLog(@"unknow datatype");
//        }
//    }
//    
//    
//    
//    
//    NSMethodSignature* sig = [[[luaEngine_oc sharedManager] target] methodSignatureForSelector:NSSelectorFromString(funName)];
//    
//#ifdef DEBUG
//    if(nil == sig){
//        NSLog(@"luaEngine");
//        NSLog(@"lua->C  can not found a function:%@", funName);
//        assert(0);
//    }
//#endif
//    
//    if(nil != sig){
//        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
//        [invocation setTarget:[[luaEngine_oc sharedManager] target]];
//        [invocation setSelector:NSSelectorFromString(funName)];
//        
//        
//        //set param
//        int index = 0;
//        for(id param in params){
//            [invocation setArgument:&param atIndex:index+2];
//            index++;
//        }
//        
//        
//        
//        
//        @try {
//            [invocation invoke];
//        }
//        @catch (NSException *exception) {
//            NSArray *arr = [exception callStackSymbols];
//            NSString *reason = [exception reason];
//            NSString *name = [exception name];
//            
//            NSLog(@"an exception on remote call");
//            NSString* log = [NSString stringWithFormat:@"%@\n%@\n%@\n", name, reason, arr];
//            NSLog(@"%@", log);
//            assert(0);
//        }
//        
//        
//        int rtVal = 0;
//        id returnValue = nil;
//        const char* returnType = sig.methodReturnType;
//        if(0 == strcmp(returnType, @encode(void))){
//            rtVal = 0;
//        }
//        else if(0 == strcmp(returnType, @encode(id))){
//            
//            [invocation getReturnValue:&returnValue];
//            
//            //invalidate return type!!!!!!
//            assert(YES == [returnValue respondsToSelector:@selector(pushValue:)]);
//            
//            [returnValue pushValue:L]; //returnValue also supported the NSNull object
//            
//            rtVal = 1;
//        }
//        else{
//            //:~ TODO
//            //we just support the object-c data type and nil.
//            //can do it later!!!
//            rtVal = 0;
//        }
//        
//    }
//    
//    
//
//    
//    return -1;
//}




int luaEngine_distributeFun(lua_State* L){
    
    
    int nParamNum = lua_gettop(L);
    if(nParamNum < 1)
        return (int)luaEngine_error_param;
    
    
    if(!lua_istable(L, 1))
        return (int)luaEngine_error_param;
    
    
    NSDictionary* callingDict = [NSDictionary valueWithLuaState:L :1];
    if(nil == callingDict)
        return (int)luaEngine_error_param;
    
    NSString* funName = [callingDict objectForKey:@"function_name"];
    if(nil == funName  ||  NO == [funName isKindOfClass:[NSString class]])
        return (int)luaEngine_error_param;
    
//    NSNumber* paramNum = [callingDict objectForKey:@"param_num"];
//    if(nil == paramNum  ||  NO == [paramNum isKindOfClass:[NSNumber class]])
//        return (int)luaEngine_error_param;
    
    NSDictionary* paramDict = [callingDict objectForKey:@"param_list"];
    if(nil == paramDict  ||  NO == [paramDict isKindOfClass:[NSDictionary class]])
        return (int)luaEngine_error_param;
    
//    int ndictCount = (int)[paramDict count];
//    NSMutableArray* params = [[NSMutableArray alloc] initWithCapacity:ndictCount];
//    for(int i=0; i<ndictCount; i++){
//        NSString* key = [NSString stringWithFormat:@"_param_%d", i+1];
//        id param = [paramDict objectForKey:key];
//        assert(nil != param);
//        [params addObject:param];
//    }
    
    
    NSMethodSignature* sig = [[[luaEngine_oc sharedManager] target] methodSignatureForSelector:NSSelectorFromString(funName)];
    
#ifdef DEBUG
    if(nil == sig){
        NSLog(@"luaEngine");
        NSLog(@"lua->C  can not found a function:%@", funName);
        assert(0);
    }
#endif
    
    int rtVal = 0;
    if(nil != sig){
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:[[luaEngine_oc sharedManager] target]];
        [invocation setSelector:NSSelectorFromString(funName)];
        
        
        //set param
//        int index = 0;
//        for(id param in params){
//            [invocation setArgument:&param atIndex:index+2];
//            index++;
//        }
//              
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
        id returnValue = nil;
        const char* returnType = sig.methodReturnType;
        if(0 == strcmp(returnType, @encode(void))){
            rtVal = 0;
        }
        else if(0 == strcmp(returnType, @encode(id))){
            
            [invocation getReturnValue:&returnValue];
            
            //invalidate return type!!!!!!
            assert(YES == [returnValue respondsToSelector:@selector(pushValue:)]);
            
            [returnValue pushValue:L]; //returnValue also supported the NSNull object
            
            rtVal = 1;
        }
        else{
            //:~ TODO
            //we just support the object-c data type and nil.
            //can do it later!!!
            rtVal = 0;
        }
        
    }
    
    
    
    
    return rtVal;
}

