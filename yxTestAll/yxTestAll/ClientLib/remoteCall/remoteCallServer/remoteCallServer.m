//
//  remoteCallServer.m
//  remoteCall_server
//
//  Created by Yuxi Liu on 10/25/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//


#import <pthread.h>

#import "../../cm/cmMem.h"

#import "remoteCallServer.h"
#import "../../err/errInfo.h"


#import "../common_remoteCall.h"



static const NSInteger hasNotReturn = 0;
static const NSInteger returned = 1;

static const int max_function_waiting_for_return = 50;

//:~ TODO Split the packet
//:~ TODO using yx_pool here, for a elastic memory
static const int max_len_buff_size = 1024*90;
//

static remoteCallServer* g_remoteCallServerInstance = nil;



///////////////////////////////////////////////////////////////////////////////////////////
//int remoteCall_err_success = 0; //must be zero
//int remoteCall_err_unknown = 1;
//int remoteCall_err_timeout = 2;
//int remoteCall_err_param = 3;



//
///////////////////////////////////////////////////////////////////////////////////////////


typedef struct __remote_func{
    NSConditionLock* condition;   //Using for the func return
    //:~ TODO add some special return value. void, nil, err, closed~~~
    id rtValue;      // the return value 
    int errNum;      //the err num;
}_remote_func, *_remote_func_ref;




typedef struct __remote_notification{
    NSString* cliName;
    id<clientEventNotification> observer;
}_remote_notification, *_remote_notification_ref;




/////////////////////////////////////////////////////////////////////////////////////////

@interface remoteCallServer()


-(int)sendDictionary:(int)connectionID :(NSDictionary*)dict;
-(NSDictionary*) getDictByBuf:(const void*)buf :(int)size; //mark! should release the dictionary by user

-(void)notifyClientConnect:(NSString*)cliName :(remoteProxy*)clientProxy;
//-(void)notifyClientClosed:(NSString *)cliName;
-(void)notifyClientClosed:(remoteProxy*)proxy;

- (void)_log:(NSString*)log withLevel:(int)level;

@property(readwrite, atomic, assign) HSLSelectServer server;
@property(readwrite, assign) HTSH_Tble funWaitTable;
@property(readonly, assign) targetProxy* target; //be carefully, I use assign not retain !!!
@property(readonly, assign) NSMutableDictionary* remoteProxyDict;

@end

/////////////////////////////////////////////////////////////////////////////////////////

@interface remoteProxy()
//    int _clientID;
//    HTSH_Tble _funTable;
//}

-(void)makeAllFunReturn;

@property(readwrite, assign) int clientID;
@property(readwrite, retain) NSString* clientName;
@property(readwrite, assign) pid_t pid;
@property(readwrite, assign) BOOL isValidate;

@end

/////////////////////////////////////////////////////////////////////////////////////////


@implementation remoteCallServer



void _handle_new_connection(int connectionID, const char* ipAddress, int port);
void _handle_msg(int connectionID, const void* buf, int size);
void _handle_connectin_closed(int connectionID, const char* ipAddress, int port);


-(NSString*)test:(NSNumber*)num : (NSString*) str{
    NSLog(@"func call:%@, %@", num, str);
    
    return @"rtVal";
}

-(BOOL)setupServer:(int) port{
    @synchronized(_server){
        [self setServer:setupServer(port, _handle_msg, _handle_new_connection, _handle_connectin_closed)];
    }
    
return (_server!=nil? YES : NO);


}
-(void)shutdownServer:(BOOL)tryToWait{
    @synchronized(_server){
        shutdownServer(&_server, YES == tryToWait? CM_TRUE : CM_FALSE); //after this operation, the _client is already NULL.
        [self setServer:NULL];  //this is just to call the offerial function and tell the variable has changed.
    }
}


-(void)registerTarget:(id)newTarget{
    [_target registerTarget:newTarget];
}

-(void)removeTarget:(id)target{
    [_target removeTarget:target];
}

-(targetProxy*)target{
    return _target;
}




-(void)addNewClientObserver:(NSString*)cliName :(id<clientEventNotification>)obs{
    
    NSMutableArray* observerArray;
    
    pthread_rwlock_wrlock(&_obsRWLock);
    
    if(nil == (observerArray = [_obsDict objectForKey:cliName])){
        observerArray = [[[NSMutableArray alloc] init] autorelease];
        [_obsDict setObject:observerArray forKey:cliName];
    }
    [observerArray addObject:obs];
    
    pthread_rwlock_unlock(&_obsRWLock);
}



-(void)removeClientObserver:(NSString*)cliName :(id<clientEventNotification>)obs{
    
    NSMutableArray* observerArray;
    pthread_rwlock_wrlock(&_obsRWLock);
    
    if(nil != (observerArray = [_obsDict objectForKey:cliName])){
        
        if(nil == obs)
            [observerArray removeAllObjects];
        else
            [observerArray removeObject:obs];
        
        if([observerArray count] == 0)
            [_obsDict removeObjectForKey:cliName];
    }
    
    pthread_rwlock_unlock(&_obsRWLock);
}

- (void)_log:(NSString*)log withLevel:(int)level{
    //-(void)remoteLog:(NSString*)log withLevel:(int)level;

#if DEBUG
    
    //:~ debug
    [log writeToFile:[NSString stringWithFormat:@"/Library/Logs/360Server_%@", [NSDate date]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if(YES == [self respondsToSelector:@selector(remoteLog:withLevel:)]){
        //:~ TODO
//        [self remoteLog:log withLevel:level];
    }
    else{
        NSLog(@"[remoteCallServer(%d)]:%@", level, log);
    }
#endif
}



@synthesize server = _server;
@synthesize target = _target;
@synthesize remoteProxyDict = _remoteProxyDict;
@synthesize funWaitTable = _funWaitTable;


/*private functions*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

-(int)sendDictionary:(int)connectionID :(NSDictionary*)dict{
    
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
        if(NULL == (dictData =  CFPropertyListCreateXMLData(NULL, (CFDictionaryRef)dict))){
            
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
        
        if(0 != (err = sendMsg(_server, connectionID, (void*)dictBuff, dictSize, NULL))){
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
    CFPropertyListRef dict = NULL;
    
    do {
        
        assert(NULL != buf);
        assert(size >= 0);
        
        //veriry the buff
//        if([self isBinaryPropertyListData:buf :size] == NO){
//            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
//            break;
//        }
        
        
        if(NULL == (dictData = CFDataCreateWithBytesNoCopy(NULL, (const UInt8*)buf, size, kCFAllocatorNull))){
            err = OSStatusToErrno(0/*coreFoundationUnknownErr*/);
            break;
        }
        
        
        if(NULL == (dict = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, dictData, kCFPropertyListImmutable, NULL))){
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
    
    
    return [(NSDictionary*)(CFDictionaryRef)(dict) autorelease];
}


//-(Boolean) isBinaryPropertyListData :(const void *)plistBuffer :(size_t)plistSize
//// Make sure that whatever is passed into the buffer that will
//// eventually become a plist (and then sequentially a dictionary)
//// is NOT in binary format.
//{
//    static const char kBASBinaryPlistWatermark[6] = "bplist";
//    
//    assert(plistBuffer != NULL);
//	
//	return (plistSize >= sizeof(kBASBinaryPlistWatermark))
//    && (memcmp(plistBuffer, kBASBinaryPlistWatermark, sizeof(kBASBinaryPlistWatermark)) == 0);
//}






-(void)notifyClientConnect:(NSString*)cliName :(remoteProxy*)clientProxy{
    
    NSMutableArray* observerArray = nil;
    pthread_rwlock_rdlock(&_obsRWLock);
    if(nil != (observerArray = [_obsDict objectForKey:cliName])){
        for(id<clientEventNotification> observer in observerArray){
            [observer clientConnected:cliName :clientProxy];
        }
    }
    pthread_rwlock_unlock(&_obsRWLock);
    
}


-(void)notifyClientClosed:(remoteProxy*)proxy{
    
    NSMutableArray* observerArray = nil;
    pthread_rwlock_rdlock(&_obsRWLock);
    if(nil != (observerArray = [_obsDict objectForKey:[proxy clientName]])){
        for(id<clientEventNotification> observer in observerArray){
            [observer clientClosed:proxy];
        }
    }
    pthread_rwlock_unlock(&_obsRWLock);
    
}







/////////////////////////////////////////////////////////////////////////////////////////
/*release*/
/////////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc{
    if(nil != _server){
        [self shutdownServer:YES];
        HTSH_FreeTable(&_funWaitTable);
    }
    
    
    if(nil != _obsDict){
        pthread_rwlock_wrlock(&_obsRWLock);
        NSArray* observerArrayArr = [_obsDict allValues];
        for(NSMutableArray* observerArray in observerArrayArr){
            [observerArray release];
        }
        pthread_rwlock_unlock(&_obsRWLock);
        pthread_rwlock_destroy(&_obsRWLock);
    }
    
    if(nil != _remoteProxyDict){
        pthread_rwlock_wrlock(&_rmoteProxyRWLock);
        NSArray* remoteProxyArray = [_remoteProxyDict allValues];
        for(remoteProxy* proxy in remoteProxyArray)
            [proxy release];
        pthread_rwlock_unlock(&_rmoteProxyRWLock);
        pthread_rwlock_destroy(&_rmoteProxyRWLock);
    }
    
    
    
    [super dealloc];
}


- (id)init{
    if(nil != (self = [super init])){
        
#ifdef DEBUG
        _funWaitTable = HTSH_InitTable(max_function_waiting_for_return, CM_FALSE, NULL);
#else
        _funWaitTable =  HTSH_InitTable(max_function_waiting_for_return);
#endif //DEBUG
        
        
        //target
        _target = [[targetProxy alloc] init];
        
        
        //observer
        _obsDict = [[NSMutableDictionary alloc] init];
        pthread_rwlock_init(&_obsRWLock, NULL);
        
        
        //remote proxy
        _remoteProxyDict = [[NSMutableDictionary alloc] init];
        pthread_rwlock_init(&_rmoteProxyRWLock, NULL);
        
    }
    
    
    return self;
}


/////////////////////////////////////////////////////////////////////////////////////////
/*single operation*/
/////////////////////////////////////////////////////////////////////////////////////////
+ (remoteCallServer*)sharedManager
{
    @synchronized(self) {
        if (g_remoteCallServerInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return g_remoteCallServerInstance;
}


+(BOOL)sharedInstanceExists{
    return (g_remoteCallServerInstance != nil ? YES : NO);
}


+(void)releaseManager{
    
    @synchronized(self){
        if(g_remoteCallServerInstance != nil){
            remoteCallServer* tmpInstance = g_remoteCallServerInstance;
            g_remoteCallServerInstance = nil; //Just when g_remoteCallServerInstance is equal to nil, the releaase operation will do the free work
            [tmpInstance release];
        }
        
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (g_remoteCallServerInstance == nil) {
            g_remoteCallServerInstance = [super allocWithZone:zone];
            return g_remoteCallServerInstance;  // assignment and return on first allocation
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
    if(nil == g_remoteCallServerInstance)
        [self dealloc];

    //do nothing
}

- (id)autorelease
{
    return self;
}





void _handle_new_connection(int connectionID, const char* ipAddress, int port){
    
    @autoreleasepool {
        [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"new connection(%d)\n", connectionID] withLevel:remoteCall_logLevel_debug];
    }
    
    //printf("new connection(%d)\n", connectionID);
}
void _handle_msg(int connectionID, const void* buf, int size){

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSDictionary* dict = nil;
    
    
    do {
        dict = [[remoteCallServer sharedManager] getDictByBuf:buf :size];
        
        
        if(nil == dict)
            break;

        
        NSString* opertionType = [dict objectForKey:remoteKeyType];
        if(nil == opertionType)
            break;
        
        
        if([opertionType isEqualToString:(NSString*)remoteMsgFunReturn]){
            //NSLog(@"in remoteMsgFunReturn");
            NSNumber* index = [dict objectForKey:remoteKeyIndex];
            if(nil == index)
                break;
            
            int key = [index intValue];
            id rtVal = [dict objectForKey:remoteKeyReturnVal];
            
            _remote_func_ref fun;
            HTSH_Find([[remoteCallServer sharedManager] funWaitTable] , key, (unsigned long*)(&fun));
            if(NULL == fun){
                [[remoteCallServer sharedManager] _log:@"an out of data fun returned" withLevel:remoteCall_logLevel_err];
#ifdef DEBUG
                printf("null\n");
                printf("key=%d", key);
                HTSH_Walk([[remoteCallServer sharedManager] funWaitTable]);
                printf("current table size = %ld\n", HTSH_Size([[remoteCallServer sharedManager] funWaitTable]));
#endif
                break;
            }
            
            [fun->condition lock];
            fun->rtValue = [rtVal retain];
            [fun->condition unlockWithCondition:returned];
        }
        else if([opertionType isEqualToString:(NSString*)remoteMsgFunCall]){
//            NSLog(@"in remoteMsgFunCall");
            NSString* funName = [dict objectForKey:remoteKeyFunName];
            
            
//            NSMethodSignature* sig = [remoteCallServer instanceMethodSignatureForSelector:NSSelectorFromString(funName)];
            
             NSMethodSignature* sig = [[[remoteCallServer sharedManager] target] methodSignatureForSelector:NSSelectorFromString(funName)];
            if(nil == sig){
                [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"can not found the function :%@", funName] withLevel:remoteCall_logLevel_err];
            }
            
            if(nil != sig){
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
                [invocation setTarget:[[remoteCallServer sharedManager] target]];
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
                    [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"an exception on remote call\n%@", log] withLevel:remoteCall_logLevel_err];
                    
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
                        //returnValue = [[[NSNull alloc] init] autorelease];
                        //TODO can not support void datat type
                        returnValue = @"return an void";
                        //NSLog(@"how dare you return a void datatype here!!");
//                        assert(0);
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
                        returnValue = @"a basic C datatype";
                        returnType = @encode(id);
                        [[remoteCallServer sharedManager] _log:@"invalidate return type" withLevel:remoteCall_logLevel_err];
                        assert(0);
                        return;
                    }
                    
                    NSMutableDictionary* rtDict = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
                    [rtDict setObject:remoteMsgFunReturn forKey:remoteKeyType];
                    [rtDict setObject:returnValue forKey:remoteKeyReturnVal];
                    [rtDict setObject:index forKey:remoteKeyIndex];
                    
                    int errCodes = 0;
                    if(0 != (errCodes = [[remoteCallServer sharedManager] sendDictionary:connectionID :rtDict])){
                        [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"error on send data. err = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err];
                    }
                }

            } //if(nil != sig){

        } //if([opertionType isEqualToString:(NSString*)remoteMsgFunReturn]){
        else if([opertionType isEqualToString:(NSString*)remoteMsgRegister]){
            NSNumber* index = [dict objectForKey:remoteKeyIndex];
            NSString* clientName = [dict objectForKey:remoteKeyClientName];
            NSNumber* pid = [dict objectForKey:remoteKeyClientProcessID];
//            NSLog(@"a client named %@ linked", clientName);
//            NSLog(@"pid = %d", [pid intValue]);
            
            remoteProxy* proxy = [[[remoteProxy alloc] init] autorelease];
            [proxy setClientID:connectionID];
            [proxy setClientName:clientName];
            [proxy setPid:(pid_t)[pid intValue]];
            [proxy setIsValidate:YES];

            
            pthread_rwlock_wrlock(&([remoteCallServer sharedManager]->_rmoteProxyRWLock));
            [[[remoteCallServer sharedManager] remoteProxyDict] setObject:proxy forKey: [NSNumber numberWithInt:connectionID]];
            pthread_rwlock_unlock(&([remoteCallServer sharedManager]->_rmoteProxyRWLock));
            
                
            NSMutableDictionary* rtDict = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
            [rtDict setObject:rmoteMsgRegisterResponds forKey:remoteKeyType];
            [rtDict setObject:[NSNumber numberWithBool:YES] forKey:remoteKeyRegisterResult];
            [rtDict setObject:index forKey:remoteKeyIndex];
            
            int errCodes = 0;
            if(0 != (errCodes = [[remoteCallServer sharedManager] sendDictionary:connectionID :rtDict])){
                 [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"error on send data when a remote client regist. err = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err];
            }
            
            [[remoteCallServer sharedManager] notifyClientConnect:clientName :proxy];
        }
        
    } while (0);
    
    
    
    [pool drain];
    
}



void _handle_connectin_closed(int connectionID, const char* ipAddress, int port){
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    printf("connection closed(%d)\n", connectionID);
    
    remoteProxy* proxy = nil;
    pthread_rwlock_wrlock(&([remoteCallServer sharedManager]->_rmoteProxyRWLock));
    proxy = [[[[remoteCallServer sharedManager] remoteProxyDict] objectForKey:[NSNumber numberWithInt:connectionID]] retain];
    [[[remoteCallServer sharedManager] remoteProxyDict] removeObjectForKey:[NSNumber numberWithInt:connectionID]];
    pthread_rwlock_unlock(&([remoteCallServer sharedManager]->_rmoteProxyRWLock));
    
    [proxy setIsValidate:NO];
    [[remoteCallServer sharedManager] notifyClientClosed:proxy];
    
    //force all function return. the client end will not have the return value
    [proxy makeAllFunReturn];
    [proxy release];
    
    
    [pool drain];
}



@end



/*NSRemoteProxy*/
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////



@implementation remoteProxy


@synthesize clientName;
@synthesize pid;
@synthesize clientID = _clientID;
@synthesize isValidate;

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

- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond  :(int*)err withPramArr:(NSArray*)params{

    
    if (NO == [self isValidate])
        return nil;
    
    int localErr = remoteCall_err_success;
    
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [paramDict setObject:remoteMsgFunCall forKey:remoteKeyType];
    [paramDict setObject:NSStringFromSelector(aSelector) forKey:remoteKeyFunName];
    [paramDict setObject:[NSNumber numberWithBool:YES] forKey:remoteKeyWait];
    
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
    
    
    int index = 0;
    for(id obj in params){
        NSString* key = [NSString stringWithFormat:(NSString*)remoteKeyParamFormat, index];
        [paramDict setObject:obj forKey:key];
        index++;
    }
    
    assert([self isValidate] == YES);
    
    CM_BOOL tt;
    tt = HTSH_Insert(_funTable, key, (unsigned long)fun);
    assert([self isValidate] == YES);
    assert(CM_FALSE != tt);
    tt = HTSH_Insert([[remoteCallServer sharedManager] funWaitTable], key, (unsigned long)fun);
    assert(CM_FALSE != tt);
    
    
    id rtVal = nil;
    int errCodes = 0;
    if(0 != (errCodes = [[remoteCallServer sharedManager] sendDictionary:_clientID :paramDict])){
        [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"failed on send data. err = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err];
        localErr = remoteCall_err_unknown; //:~ TODO modify the sendDictionary function. then we can know the err reason.
    }
    else{
        //id rtVal = nil; //[[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
        if(YES == [fun->condition lockWhenCondition:returned beforeDate:[NSDate dateWithTimeIntervalSinceNow:maxWaitSecond]]){
            rtVal = fun->rtValue;
            [fun->condition unlock];
            [rtVal autorelease];
        }
        else{
            //timeout
            localErr = remoteCall_err_timeout;
        }
        
    }
    
    [fun->condition release];
    fun->condition = nil;
    HTSH_Remove([[remoteCallServer sharedManager] funWaitTable], key);
    HTSH_Remove(_funTable, key);
    FREE(fun);
    
    if(NULL != err)
        *err = localErr;
    
    return rtVal;
}



- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond :(int*)err, ... {
    
    if (NO == [self isValidate])
        return nil;
    
    int localErr = remoteCall_err_success;
    
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [paramDict setObject:remoteMsgFunCall forKey:remoteKeyType];
    [paramDict setObject:NSStringFromSelector(aSelector) forKey:remoteKeyFunName];
    [paramDict setObject:[NSNumber numberWithBool:YES] forKey:remoteKeyWait];
    
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
    
    assert([self isValidate] == YES);
    
    CM_BOOL tt;
    tt = HTSH_Insert(_funTable, key, (unsigned long)fun);
    assert([self isValidate] == YES);
    assert(CM_FALSE != tt);
    tt = HTSH_Insert([[remoteCallServer sharedManager] funWaitTable], key, (unsigned long)fun);
    assert(CM_FALSE != tt);

    
    id rtVal = nil;
    int errCodes = 0;
    if(0 != (errCodes = [[remoteCallServer sharedManager] sendDictionary:_clientID :paramDict])){
        [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"failed on send data. err = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err];
        localErr = remoteCall_err_unknown; //:~ TODO modify the sendDictionary function. then we can know the err reason.
    }
    else{     
        //id rtVal = nil; //[[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
        if(YES == [fun->condition lockWhenCondition:returned beforeDate:[NSDate dateWithTimeIntervalSinceNow:maxWaitSecond]]){
            rtVal = fun->rtValue;
            [fun->condition unlock];
            [rtVal autorelease];
        }
        else{
            //timeout
            localErr = remoteCall_err_timeout;
        }
        
    }
    
    [fun->condition release];
    fun->condition = nil;
    HTSH_Remove([[remoteCallServer sharedManager] funWaitTable], key);
    HTSH_Remove(_funTable, key);
    FREE(fun);
    
    if(NULL != err)
        *err = localErr;
    
    return rtVal;
}




- (int)performRemoteSelectorNoWait:(SEL)aSelector :(int*)err, ...{
    
    if (NO == [self isValidate])
        return -1;
    
    int localErr = remoteCall_err_success;
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [paramDict setObject:remoteMsgFunCall forKey:remoteKeyType];
    [paramDict setObject:NSStringFromSelector(aSelector) forKey:remoteKeyFunName];
    //    [paramDict setObject:[NSNumber numberWithBool:NO] forKey:remoteKeyWait]; //we don't need to set this value in nowait node.
    
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
    if(0 != (errCodes = [[remoteCallServer sharedManager] sendDictionary:_clientID :paramDict])){
        [[remoteCallServer sharedManager] _log:[NSString stringWithFormat:@"error on send data. err = %d, %s", errCodes, strerror(errCodes)] withLevel:remoteCall_logLevel_err];
        localErr = remoteCall_err_unknown; //:~ TODO modify the sendDictionary function. then we can know the err reason.
    }
    
    if(NULL != err)
        *err = localErr;
    
    return 0;
}

-(id)init{
    if(nil != (self = [super init])){
#ifdef DEBUG
        _funTable = HTSH_InitTable(max_function_waiting_for_return, CM_FALSE, NULL);
#else
        _funTable =  HTSH_InitTable(max_function_waiting_for_return);
#endif //DEBUG
        
    }
    
    return self;
}

-(void)close{
    close(_clientID);
}

- (BOOL)isEqualToProxy:(remoteProxy*)aProxy{
    
    return ([self pid] == [aProxy pid])? YES :NO;
}


-(void)dealloc{
    [clientName release];
    clientName = nil;
    
    
    HTSH_FreeTable(&_funTable);
    _funTable = NULL;
    
    [super dealloc];
}


@end



