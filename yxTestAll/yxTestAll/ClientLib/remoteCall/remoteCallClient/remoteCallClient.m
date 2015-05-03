//
//  remoteCallClient.m
//  remoteCall_client
//
//  Created by Yuxi Liu on 10/25/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//


#include <semaphore.h>

#import "../../err/errInfo.h"

#import "../../hash/hashOnThread.h"

#import "../../cm/cmMem.h"

#import "../common_remoteCall.h"


#import "remoteCallClient.h"

static const NSInteger hasNotReturn = 0;
static const NSInteger returned = 1;


static const int max_function_waiting_for_return = 50;


typedef struct __remote_func{
    NSConditionLock* condition;   //Using for the func return
    id rtValue;      // the return value
    int errNum;      //the err num;
}_remote_func, *_remote_func_ref;



static remoteCallClient* g_remoteCallClientInstance = nil;



//:~ TODO Split the packet
//:~ TODO using yx_pool here, for a elastic memory
static const int max_len_buff_size = 1024*90;
//

@interface remoteCallClient()


-(int)sendDictionary:(NSDictionary*)dict;
-(NSDictionary*) getDictByBuf:(const void*)buf :(int)size;
-(void)makeAllFunReturn;

- (void)_log:(NSString*)log withLevel:(int)level;

@property (readwrite, atomic, assign) HSLSelectClient client;
@property (readwrite, assign) HTSH_Tble funWaitTable;
@property (readonly, assign) targetProxy* target;

@end




@implementation remoteCallClient


static void _handle_msg(const void* buf, int size);
static void _handle_closed();

-(BOOL)connectToServer:(NSString*)clientName :(NSString*) address :(int) port{
    
    /*@synchronized(_client)*/{
        
        _client = nil;
        
        if(nil == _client){
            HSLSelectClient cli = SLFSetupClient([address UTF8String], port, _handle_msg, _handle_closed);
            if(cli != nil){
                _client = cli;
                NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
                [paramDict setObject:remoteMsgRegister forKey:remoteKeyType];
                [paramDict setObject:clientName forKey:remoteKeyClientName];
                assert(sizeof(getpid()) == sizeof(int)); //I use int datatype to store the pid_t datatype
                [paramDict setObject:[NSNumber numberWithInt:getpid()] forKey:remoteKeyClientProcessID];
                

                int key = (unsigned long)[NSThread currentThread] % INT32_MAX;
                
                [paramDict setObject:[NSNumber numberWithInt: key]  forKey:remoteKeyIndex];
                
                
                //:~ TODO 
                _remote_func_ref fun = (_remote_func_ref)MALLOC(sizeof(_remote_func));
                fun->errNum = 0;
                fun->rtValue = nil;
                fun->condition = [[NSConditionLock alloc] initWithCondition:hasNotReturn];
                HTSH_Insert(_funWaitTable, key, (unsigned long)fun);
                int errCodes = 0;
                if(0 != (errCodes = [self sendDictionary:paramDict])){
                    [self _log:[NSString stringWithFormat:@"error on send data when connect to server. err = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err];
                }
                NSNumber* rtVal = nil;
                
                if(YES == [fun->condition lockWhenCondition:returned beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]){
                    rtVal = fun->rtValue;
                    [fun->condition unlock];
                }
                else{
                    //timeout
                    printf("time out\n");
                }
                
                [fun->condition release];
                HTSH_Remove(_funWaitTable, key);
                FREE(fun);
                
                
                if(YES == [rtVal boolValue]){
                    [self setClient:cli];
                    if(nil != _delegate && [_delegate respondsToSelector:@selector(serverConnected)])
                        [_delegate serverConnected];
                }
                else{
                    //register failed.
                    SLFShutDownClient(&cli, CM_TRUE);
                }
                
                
            }
        }
    }
    
    return (_client!=nil? YES : NO);
}

- (void)_log:(NSString*)log withLevel:(int)level{
    //-(void)remoteLog:(NSString*)log withLevel:(int)level;
    //:~ TODO debug
#if DEBUG
    [log writeToFile:[NSString stringWithFormat:@"/Library/Logs/360Client_%@", [NSDate date]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if(YES == [self respondsToSelector:@selector(remoteLog:withLevel:)]){
        //:~ TODO
//        [self remoteLog:log withLevel:level];
    }
    else{
        NSLog(@"[remoteCallClient(%d)]:%@", level, log);
    }
#endif
}

-(void)closeConnection:(BOOL)tryToWait{
    @synchronized(_client){
        SLFShutDownClient(&_client, tryToWait==YES? CM_TRUE : CM_FALSE);//after this operation, the _client is already NULL.
        [self setClient:NULL]; //this is just to call the offerial function and tell the varibale has changed
    }
}

- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond  :(int*)err withPramArr:(NSArray*)params{
    
    int localErr = remoteCall_err_success;
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [paramDict setObject:remoteMsgFunCall forKey:remoteKeyType];
    [paramDict setObject:NSStringFromSelector(aSelector) forKey:remoteKeyFunName];
    [paramDict setObject:[NSNumber numberWithBool:YES] forKey:remoteKeyWait];
    
    //TODO:~ modified the hash table, and use unsigned long as its key
    //use the current thread pointer as it's key.
    //dangerours!!! Pointer truncation. use a int datatype to store a pointer
    //I think it's ok. the low address in an address is always differents.
    //But, I'm not very sure
    int key = (unsigned long)[NSThread currentThread] % INT32_MAX;
    
    [paramDict setObject:[NSNumber numberWithInt: key]  forKey:remoteKeyIndex];
    
    
    _remote_func_ref fun = (_remote_func_ref)MALLOC(sizeof(_remote_func));
    fun->errNum = 0;
    fun->rtValue = nil;
    fun->condition = [[NSConditionLock alloc] initWithCondition:hasNotReturn];
    assert(nil != fun->condition);
    assert(nil != fun);
    
    
    
    int index = 0;
    for(id obj in params){
        NSString* key = [NSString stringWithFormat:(NSString*)remoteKeyParamFormat, index];
        [paramDict setObject:obj forKey:key];
        
        index++;
    }
    
    
    
    CM_BOOL rt = HTSH_Insert(_funWaitTable, key, (unsigned long)fun);
    assert(CM_FALSE != rt);
    
    id rtVal = nil;
    int errCodes = 0;
    if(0 != (errCodes = [self sendDictionary:paramDict])){
        [self _log:[NSString stringWithFormat:@"send data error.error = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err]; //you may passed an invalidate datatype as param
        localErr = remoteCall_err_unknown; //:~ TODO modify the sendDictionary function. then we can know the err reason.
    }
    else{
        
        if(YES == [fun->condition lockWhenCondition:returned beforeDate:[NSDate dateWithTimeIntervalSinceNow:maxWaitSecond]]){
            rtVal = fun->rtValue;
            [rtVal autorelease];
            [fun->condition unlock];
        }
        else{
            //timeout
            localErr = remoteCall_err_timeout;
        }
        
    }
    
    [fun->condition release];
    HTSH_Remove(_funWaitTable, key);
    FREE(fun);
    
    if(NULL != err)
        *err = localErr;
    
    return rtVal;
}


- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond :(int*)err, ... {
    
    int localErr = remoteCall_err_success;
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [paramDict setObject:remoteMsgFunCall forKey:remoteKeyType];
    [paramDict setObject:NSStringFromSelector(aSelector) forKey:remoteKeyFunName];
    [paramDict setObject:[NSNumber numberWithBool:YES] forKey:remoteKeyWait];
    
    //TODO modified the hash table, and use unsigned long as its key
    //use the current thread pointer as it's key.
    //dangerours!!! Pointer truncation. use a int datatype to store a pointer
    //I think it's ok. the low address in an address is always differents.
    //But, I'm not very shure
    int key = (unsigned long)[NSThread currentThread] % INT32_MAX;
    
    [paramDict setObject:[NSNumber numberWithInt: key]  forKey:remoteKeyIndex];

    
    _remote_func_ref fun = (_remote_func_ref)MALLOC(sizeof(_remote_func));
    fun->errNum = 0;
    fun->rtValue = nil;
    fun->condition = [[NSConditionLock alloc] initWithCondition:hasNotReturn];
    assert(nil != fun->condition);
    assert(nil != fun);
    
    id p;
    va_list params;
    va_start(params, err);
    
    for(int i=0; ;i++){
        p = va_arg(params, id);
        if(p == nil)
            break;
        
        NSString* key = [NSString stringWithFormat:(NSString*)remoteKeyParamFormat, i];
        [paramDict setObject:p forKey:key];
    }
    
    va_end(params);
    

    
    CM_BOOL rt = HTSH_Insert(_funWaitTable, key, (unsigned long)fun);
    assert(CM_FALSE != rt);
    
    id rtVal = nil;
    int errCodes = 0;
    if(0 != (errCodes = [self sendDictionary:paramDict])){
        [self _log:[NSString stringWithFormat:@"send data error.error = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err]; //you may passed an invalidate datatype as param
        localErr = remoteCall_err_unknown; //:~ TODO modify the sendDictionary function. then we can know the err reason.
    }
    else{
     
        if(YES == [fun->condition lockWhenCondition:returned beforeDate:[NSDate dateWithTimeIntervalSinceNow:maxWaitSecond]]){
            rtVal = fun->rtValue;
            [rtVal autorelease];
            [fun->condition unlock];
        }
        else{
            //timeout
            localErr = remoteCall_err_timeout;
        }
        
    }
    
    [fun->condition release];
    HTSH_Remove(_funWaitTable, key);
    FREE(fun);
    
    if(NULL != err)
        *err = localErr;
    
    return rtVal;
}

- (int)performRemoteSelectorNoWait:(SEL)aSelector :(int*)err, ...{
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [paramDict setObject:remoteMsgFunCall forKey:remoteKeyType];
    [paramDict setObject:NSStringFromSelector(aSelector) forKey:remoteKeyFunName];
    
    id p;
    va_list params;
    va_start(params, err);
    
    for(int i=0; ;i++){
        p = va_arg(params, id);
        if(p == nil)
            break;
        
        NSString* param_key = [NSString stringWithFormat:(NSString*)remoteKeyParamFormat, i];
        [paramDict setObject:p forKey:param_key];
    }
    
    va_end(params);
    
    
    int errCodes = 0;
    if(0 != (errCodes = [self sendDictionary:paramDict])){
        [self _log:[NSString stringWithFormat:@"error on send data. error = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err];
    }
    
    return 0;
}



-(void)registerTarget:(id)newTarget{
    [_target registerTarget:newTarget];
}

-(void)removeTarget:(id)target{
    [_target removeTarget:target];
}


@synthesize client = _client;
@synthesize funWaitTable = _funWaitTable;
@synthesize target = _target;

/*private functions*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////


-(int)sendDictionary:(NSDictionary*)dict{
    
    int err = 0;
    CFDataRef dictData = NULL;
    CFIndex dictSize = -1;
    const UInt8 * dictBuff;

    do {
        assert(NULL != dict);
        
        //:~ TODO using CFErrorCopyDescription function to replace CFPropertyListCreateXMLData
        //1. the CFPropertyListCreateXMLData will be deprecated soon.
        //2. we can pass binary data in ship version. it's may smaller and safer
        //3. we can know the reason when it fail.
        if(NULL == (dictData = CFPropertyListCreateXMLData(NULL, (CFDictionaryRef)dict))){
            
            [self _log:[NSString stringWithFormat:@"failed on convert dict to xml:%@", dict] withLevel:remoteCall_logLevel_debug];
            
            
            NSArray* arr = [dict allValues];
            int index = 0;
            for(id obj in arr){
                [self _log:[NSString stringWithFormat:@"dictValueType[%d] = %@", index, [obj class]] withLevel:remoteCall_logLevel_debug];
                index ++;
            }
            
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
            break;
        }
        
        if((dictSize = CFDataGetLength(dictData)) > max_len_buff_size){
            [self _log:@"data is too long to send to the server" withLevel:remoteCall_logLevel_debug];
            err = EINVAL;
            break;
        }
        
        dictBuff = CFDataGetBytePtr(dictData);
        
        if(0 != (err = SLFSendData(_client, (void*)dictBuff, dictSize))){
            [self _log:[NSString stringWithFormat:@"failed to send data:%@", dict] withLevel:remoteCall_logLevel_debug];
            break;
        }

    } while (0);
    
    
    if(NULL != dictData)
        CFRelease(dictData);
    
    
    return err;
    
}


-(NSDictionary*) getDictByBuf:(const void*)buf :(int)size{
    
    int err = 0;
    CFDataRef dictData;
    CFPropertyListRef 	dict = NULL;
    
    do {
        
        assert(NULL != buf);
        assert(size >= 0);
        
        
        //:~ TODO
//        //veriry the buff
        
        
        if(NULL == (dictData = CFDataCreateWithBytesNoCopy(NULL, (const UInt8*)buf, size, kCFAllocatorNull))){
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
            break;
        }
    

        if(NULL == (dict = CFPropertyListCreateFromXMLData(NULL, dictData, kCFPropertyListImmutable, NULL))){
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
        }
        
        
    } while (0);


    if(0 != err)
    {
        if(NULL != dict){
            CFRelease(dict);
            dict = NULL;
        }
    }

    if(NULL != dictData)
        CFRelease(dictData);
    
    
    return (NSDictionary*)(CFDictionaryRef)(dict);
}

-(void)makeAllFunReturn{
    
    HTSH_BeginIteratorForWrite(_funTable);
    
    HTSH_TbleIter it = NULL;
    do {
        Hsh_Pair pair = {-1, (unsigned long)-1};
        it = HTSH_Iterator(_funTable, it, &pair);
        if(-1!=pair.key && -1!=pair.data){
            
            _remote_func_ref fun = (_remote_func_ref)(pair.data);
            assert(NULL != fun);
            
            [fun->condition lock];
            fun->rtValue = nil;
            [fun->condition unlockWithCondition:returned];
        }
        
    } while (NULL != it);
    
    
    HTSH_EndIterator(_funTable);
}



/////////////////////////////////////////////////////////////////////////////////////////
/*other navigate function*/
/////////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc{
    if(nil != _client){
        [self closeConnection:YES];
    }
    
    HTSH_FreeTable(&_funWaitTable);
    _funWaitTable = NULL;
    
    HTSH_FreeTable(&_funTable);
    _funTable = NULL;
    
    [_target release];
    _target = nil;
    
    
    [super dealloc];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"forward Invocation");
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return YES;
}

- (id)init{
    if(nil != (self = [super init])){
        
#ifdef DEBUG
        _funWaitTable = HTSH_InitTable(max_function_waiting_for_return, CM_FALSE, NULL);
        _funTable = HTSH_InitTable(max_function_waiting_for_return, CM_FALSE, NULL);
#else
        _funWaitTable =  HTSH_InitTable(max_function_waiting_for_return);
        _funTable =  HTSH_InitTable(max_function_waiting_for_return);
#endif //DEBUG
        
        if(_funWaitTable == NULL){
            [self release];
            return nil;
        }
        
        _target = [[targetProxy alloc] init];
        
    }
    
    
    return self;
}



/////////////////////////////////////////////////////////////////////////////////////////
/*single operation*/
/////////////////////////////////////////////////////////////////////////////////////////
+ (remoteCallClient*)sharedManager
{
    @synchronized(self) {
        if (g_remoteCallClientInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return g_remoteCallClientInstance;
}


+(BOOL)sharedInstanceExists{
    return (g_remoteCallClientInstance != nil ? YES : NO);
}


+(void)releaseManager{
    
    @synchronized(self){
        if(g_remoteCallClientInstance != nil){
            remoteCallClient* tmpInstance = g_remoteCallClientInstance;
            g_remoteCallClientInstance = nil;
            [tmpInstance release];
        }
        
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (g_remoteCallClientInstance == nil) {
            g_remoteCallClientInstance = [super allocWithZone:zone];
            return g_remoteCallClientInstance;  // assignment and return on first allocation
        }
    }
    return nil; 
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
    if(nil == g_remoteCallClientInstance)
        [self dealloc];
    
    //do nothing
}

- (id)autorelease
{
    return self;
}

-(id<serverEventNotification>)delegate{
    return _delegate;
}

-(void)setDelegate:(id<serverEventNotification>)Obj{
    _delegate = Obj;
}



static void _handle_msg(const void* buf, int size){
    
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSDictionary* dict = nil;
    
    do {
        //:~ TODO. should malloc a mutableDictionary outside the getDictByBuf function and pass it to it as param
        dict = [[remoteCallClient sharedManager] getDictByBuf:buf :size];
        if(nil == dict)
            break;
        
        NSString* opertionType = [dict objectForKey:remoteKeyType];
        if(nil == opertionType)
            break;
        
        if([opertionType isEqualToString:(NSString*)remoteMsgFunReturn]){
            NSNumber* index = [dict objectForKey:remoteKeyIndex];
            if(nil == index)
                break;
            
            int key = [index intValue];
            id rtVal = [dict objectForKey:remoteKeyReturnVal];
            
            _remote_func_ref fun = NULL;
            HTSH_Find([[remoteCallClient sharedManager] funWaitTable] , key, (unsigned long*)(&fun));
            if(NULL == fun){/*time out. the calling info has already been deleted.*/
                [[remoteCallClient sharedManager] _log:@"an out of data fun returned" withLevel:remoteCall_logLevel_err];
#ifdef DEBUG
                printf("null\n");
                printf("key=%d", key);
                HTSH_Walk([[remoteCallClient sharedManager] funWaitTable]);
                printf("current table size = %ld\n", HTSH_Size([[remoteCallClient sharedManager] funWaitTable]));
#endif
                break;
            }
            
            //printf("<-%ld\n\n\n", (unsigned long)fun);
            [fun->condition lock];
            fun->rtValue = [rtVal retain];
            [fun->condition unlockWithCondition:returned];
        }
        else if([opertionType isEqualToString:(NSString*)remoteMsgFunCall]){
            NSString* funName = [dict objectForKey:remoteKeyFunName];
            
            //NSMethodSignature* sig = [remoteCallClient instanceMethodSignatureForSelector:NSSelectorFromString(funName)];
            NSMethodSignature* sig = [[[remoteCallClient sharedManager] target] methodSignatureForSelector:NSSelectorFromString(funName)];
            
            //:~TODO return an error info when can not find the specific fun
            //the remoteCall can not find the function. it do nothing. however, the caller is still waiting for the return value.
            
            if(nil == sig){
                [[remoteCallClient sharedManager] _log:[NSString stringWithFormat:@"can not found the function :%@", funName] withLevel:remoteCall_logLevel_err];
            }
            
            if(nil != sig){
                
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
                [invocation setTarget:[[remoteCallClient sharedManager] target]];
                [invocation setSelector:NSSelectorFromString(funName)];
                
                //set param
                for(int i=0; ;i++){
                    id param = [dict objectForKey:[NSString stringWithFormat:(NSString*)remoteKeyParamFormat, i]];
                    if(nil == param)
                        break;
                    
                    [invocation setArgument:&param atIndex:i+2];
                }
                
                //call the function
                @try {
                    [invocation invoke];
                }
                @catch (NSException *exception) {
                    NSArray *arr = [exception callStackSymbols];
                    NSString *reason = [exception reason];
                    NSString *name = [exception name];
                    
                    NSString* log = [NSString stringWithFormat:@"%@\n%@\n%@\n", name, reason, arr];
                    
                    [[remoteCallClient sharedManager] _log:[NSString stringWithFormat:@"an exception on remote call\n%@", log] withLevel:remoteCall_logLevel_err];
                    
                    assert(0);
                }
                
                
                NSNumber* isWait = [dict objectForKey:remoteKeyWait];
                if(nil != isWait && YES == [isWait boolValue]){
                    
                    NSNumber* index = [dict objectForKey:remoteKeyIndex];
                    assert(0 != index);
                    
                    //return value
                    id returnValue = @"function not found";
                    const char* returnType = @encode(id);
                    if(nil != sig){
                        returnType = sig.methodReturnType;
                        returnValue = nil;
                    }
                    
                    
                    if(strcmp(returnType, @encode(void)) == 0){
                        //returnValue = [[[NSNull alloc] init] autorelease]; //for void
                        //:~ TODO need a void return value;
                        returnValue = @"a void value.";
                        //NSLog(@"how dare you return a void datatype here!!");
                        //assert(0);
                    }
                    else if(strcmp(returnType, @encode(id)) == 0){
                        [invocation getReturnValue:&returnValue];
                        if(nil == returnValue){
                            returnValue = @"a null value";
                            //:~ TODO need a nil  return value;
                            //NSLog(@"how dare you return a nil datatype here!!");
                            //assert(0);
                        }
                        else{
                            //a normal return value or function not found
                        }
                    }
                    else{
                        //we just support the object-c data type.
                        //:~ TODO handle the non-object return value;
                        returnValue = @"a basic C datatype";
                        returnType = @encode(id);
                        [[remoteCallClient sharedManager] _log:@"invalidate return type" withLevel:remoteCall_logLevel_err];
                        assert(0);
                        return;
                    }
                    
                    NSMutableDictionary* rtDict = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
                    [rtDict setObject:remoteMsgFunReturn forKey:remoteKeyType];
                    [rtDict setObject:returnValue forKey:remoteKeyReturnVal];
                    [rtDict setObject:index forKey:remoteKeyIndex];
                    
                    int tmprt = [[remoteCallClient sharedManager] sendDictionary:rtDict];
                    if(0!=tmprt){
                        [[remoteCallClient sharedManager] _log:[NSString stringWithFormat:@"failed on send data. error=%d, %s", tmprt, strerror(tmprt)] withLevel:remoteCall_logLevel_err];
                    }
                    
                } //if(nil != isWait && YES == [isWait boolValue]){
                
            }
            
        }
        else if([opertionType isEqualToString:(NSString*)rmoteMsgRegisterResponds]){
            //const NSString* rmoteMsgRegisterResponds = @"_rmRegister_respoinds";
            
            
            NSNumber* index = [dict objectForKey:remoteKeyIndex];
            if(nil == index)
                break;
            
            int key = [index intValue];
            id rtVal = [dict objectForKey:remoteKeyRegisterResult];
            
            _remote_func_ref fun = NULL;
            HTSH_Find([[remoteCallClient sharedManager] funWaitTable] , key, (unsigned long*)(&fun));
            if(NULL == fun)
                break;

            [fun->condition lock];
            fun->rtValue = [rtVal retain];
            [fun->condition unlockWithCondition:returned];
            
            
        } //if([opertionType isEqualToString:(NSString*)remoteMsgFunReturn]){
        
    } while (0);

    if(nil != dict)
        [dict release];
    
    
    [pool drain];
}


static void _handle_closed(){
    id<serverEventNotification> delegate = [[remoteCallClient sharedManager] delegate];
    if(nil != delegate && [delegate respondsToSelector:@selector(serverClosed)])
        [delegate serverClosed];
    
    //force all function return. the server end will not have the return value
    [[remoteCallClient sharedManager] makeAllFunReturn];
}



@end
