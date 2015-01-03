//
//  crashManager.m
//  yxTestAll
//
//  Created by Yuxi Liu on 12/18/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "crashManager.h"
#import "runtime.h"


@interface crashLog()
+ (instancetype)logWithDictionary:(NSDictionary*)dict;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* const KCrashManager_info = @"crashInfo";

static NSString* const KCrashManager_lastCrashInfo = @"lastCrash";
static NSString* const KCrashManager_lastCrashInfo_date = @"date";
static NSString* const KCrashManager_lastCrashInfo_isContinuous = @"isContinous";



static NSString* const KCrashManager_crashlogInfo = @"crashLog";
static NSString* const KCrashManager_crashlog_date = @"date";
static NSString* const KCrashManager_crashlog_uuid = @"uuid";
static NSString* const KCrashManager_crashlog_isJailBreakFlag = @"isJailBreak";
static NSString* const KCrashManager_crashlog_appVersion = @"appVersion";
static NSString* const KCrashManager_crashlog_type = @"type";
static NSString* const KCrashManager_crashlog_subtype = @"subtype";
static NSString* const KCrashManager_crashlog_description = @"descripton";
static NSString* const KCrashManager_crashlog_threadId = @"threadId";
static NSString* const KCrashManager_crashlog_callstack = @"callstack";


#define CRASHMANAGER_MAX_LOG_NUM 10

#define CRASHMANAGERTYPENAME_EXCEPTION @"exception"
#define CRASHMANAGERTYPENAME_SIGN @"sign"

#define CRASHMANAGER_CRASH_SUBTYPE_NAME(a,b)    case a: b = [NSString stringWithUTF8String:#a];break;





static void _signalHandler(int signalcode);
static void _uncaughtExceptionHandler(NSException *exception);



@interface crashManager()

- (void) _loadCrashInfo;

- (void) _registSignHandle;
- (void) _registExceptionHandle;

- (void) _unregistSignHandle;
- (void) _unregistExceptionHandle;

- (NSDictionary*) _lastCrashInfoByTimeStamp:(NSDate*)timeStamp;

- (NSDictionary*) _crashLogBySignal:(int)signal andTimeStamp:(NSDate*)timeStamp;
- (NSDictionary*) _crashLogByException:(NSException*)exception andTimeStamp:(NSDate*)timeStamp;

- (void) _handleCrashByCrashLog:(NSDictionary*)crashLog andTimeStamp:(NSDate*)timeStamp;

@end


@implementation crashManager

#pragma public

- (void)registCrashMonitor
{
    [self _registSignHandle];
    [self _registExceptionHandle];
}

- (void)unregistCrashMonitor
{
    [self _unregistExceptionHandle];
    [self _unregistSignHandle];
}

- (NSArray*)crashLog
{
    NSMutableArray* crashLogArray = nil;
    
    do{
        NSDictionary* crashInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KCrashManager_info];
        if (nil == crashInfo  ||  NO == [crashInfo isKindOfClass:[NSDictionary class]])
            break;
        
        NSArray* crashLogDictArray = [crashInfo objectForKey:KCrashManager_crashlogInfo];
        if (nil == crashLogDictArray  ||  NO == [crashLogDictArray isKindOfClass:[NSArray class]])
            break;
        
        
        crashLogArray = [NSMutableArray arrayWithCapacity:[crashLogDictArray count]];
        for (NSDictionary* crashLogdict in crashLogDictArray) {
            
            if (NO == [crashLogdict isKindOfClass:[NSDictionary class]])
                continue;
            
            crashLog* log = [crashLog logWithDictionary:crashLogdict];
            if (nil != log) {
                [crashLogArray addObject:log];
            }
        }
        
    }while (0);
    
    
    return crashLogArray;
}

- (void)cleanLog
{
    NSArray* crashLogArray = nil;
    
    do{
        NSDictionary* crashInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KCrashManager_info];
        if (nil == nil   ||  NO == [crashInfo isKindOfClass:[NSDictionary class]])
            break;
        
        NSArray* crashLogArray_tmp = [crashInfo objectForKey:KCrashManager_crashlogInfo];
        if (nil == crashLogArray_tmp  ||  NO == [crashLogArray_tmp isKindOfClass:[NSArray class]])
            break;
        
        if ([crashLogArray count] > 1)
        {
            NSMutableDictionary* newCrashInfo = [NSMutableDictionary dictionaryWithDictionary:crashInfo];
            [newCrashInfo setObject:[NSArray arrayWithObject:[crashLogArray firstObject]] forKey:KCrashManager_crashlogInfo];
            
            [[NSUserDefaults standardUserDefaults] setObject:newCrashInfo forKey:KCrashManager_info];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }while (0);

}





#pragma lifecycle

+ (instancetype)sharedManager
{
    static dispatch_once_t  onceToken;
    static crashManager* sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastCrashDate = nil;
        _continuousCrashCounter = 0;
        
        _recoreCrashLog = YES;
        
        
        [self _loadCrashInfo];
    }
    return self;
}



#pragma private

- (void) _registSignHandle
{
    signal(SIGABRT, _signalHandler);
    signal(SIGBUS, _signalHandler);
    signal(SIGFPE, _signalHandler);
    signal(SIGILL, _signalHandler);
    signal(SIGPIPE, _signalHandler);
    signal(SIGSEGV, _signalHandler);
}

- (void) _registExceptionHandle
{
    NSSetUncaughtExceptionHandler(&_uncaughtExceptionHandler);
}

- (void) _unregistSignHandle
{
    signal(SIGABRT, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
}

- (void) _unregistExceptionHandle
{
    NSSetUncaughtExceptionHandler(nil);
}

- (void) _loadCrashInfo
{
    
    NSDictionary* crashInfo = nil;
    NSDictionary* lastCrashInfo = nil;
    
    do
    {
        /*get crash info dict*/
        crashInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KCrashManager_info];
        if (nil == crashInfo  ||  NO == [crashInfo isKindOfClass:[NSDictionary class]]){
            crashInfo = nil;
            break;
        }
        
        
        /*get last crash info*/
        lastCrashInfo = [crashInfo objectForKey:KCrashManager_lastCrashInfo];
        if (nil == lastCrashInfo  ||  NO == [lastCrashInfo isKindOfClass:[NSDictionary class]]){
            lastCrashInfo = nil;
            break;
        }
        

        /*last crash date*/
        NSDate* lastCrashDate = [lastCrashInfo objectForKey:KCrashManager_lastCrashInfo_date];
        if (nil != lastCrashDate  &&  YES == [lastCrashDate isKindOfClass:[NSDate class]]) {
            [self setLastCrashDate:lastCrashDate];
        }
        
        
        /*is continue crash*/
        NSNumber* setContinuousCrashNumber = [lastCrashInfo objectForKey:KCrashManager_lastCrashInfo_isContinuous];
        if (nil != setContinuousCrashNumber  &&  YES == [setContinuousCrashNumber isKindOfClass:[NSNumber class]]) {
            [self setContinuousCrashCounter:[setContinuousCrashNumber unsignedIntegerValue]];
        }
        

        
    }while (0);
    
    
    
    
    
    
    /**
     *  write back the continuous Crash info
     */
    if (nil != crashInfo  &&  nil != lastCrashInfo) {
        
        //for invalidate data
        if (NO == [crashInfo isKindOfClass:[NSDictionary class]]) {
            crashInfo = [NSDictionary dictionary];
        }
        
        if (NO == [lastCrashInfo isKindOfClass:[NSDictionary class]]) {
            lastCrashInfo = [NSDictionary dictionary];
        }
        
        
        NSMutableDictionary* new_crashInfo = [NSMutableDictionary dictionaryWithDictionary:crashInfo];
        
        
        /*clear the empty value*/
        NSMutableDictionary* new_lastCrashInfo = [NSMutableDictionary dictionaryWithDictionary:lastCrashInfo];
        [new_lastCrashInfo setObject:[NSNumber numberWithUnsignedInteger:0] forKey:KCrashManager_lastCrashInfo_isContinuous];
        
        
        [new_crashInfo setObject:new_lastCrashInfo forKey:KCrashManager_lastCrashInfo];
        
        
        
        /*clear the log if it's num more than 10*/
        NSArray* crashLogArray = [crashInfo objectForKey:KCrashManager_crashlogInfo];
        if (nil != crashLogArray) {
            if (YES == [crashLogArray isKindOfClass:[NSArray class]])
            {
                if ([crashLogArray count] > CRASHMANAGER_MAX_LOG_NUM) {
                    
                    [new_crashInfo setObject:[NSArray arrayWithObject:[crashLogArray firstObject]] forKey:KCrashManager_crashlogInfo];
                }
            }
            else
            {
                [new_crashInfo setObject:[NSDictionary dictionary] forKey:KCrashManager_crashlogInfo];
            }
        }
        
        
        
        [[NSUserDefaults standardUserDefaults] setObject:new_crashInfo forKey:KCrashManager_info];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
}

- (NSDictionary*) _lastCrashInfoByTimeStamp:(NSDate*)timeStamp;
{
//    NSMutableDictionary* crashInfo = [NSMutableDictionary dictionary];
    
    /*
     last crash info
     */
    NSMutableDictionary* lastCrashInfo = [NSMutableDictionary dictionary];
    
    //last crash date
    [lastCrashInfo setObject:timeStamp forKey:KCrashManager_lastCrashInfo_date];
    
    
    //continuous crash counter
    NSUInteger crashCounter = self.continuousCrashCounter;
    if (nil != self.lastCrashDate) {
        
        if ([timeStamp timeIntervalSince1970] - [self.lastCrashDate timeIntervalSince1970] <= 5.0f * 60.0f)
        {
            crashCounter ++;
        }
        else
        {
            crashCounter = 1; //not a continue crash
        }
    }
    else
    {
        crashCounter = 1; //first crash
    }
    
    [lastCrashInfo setObject:[NSNumber numberWithUnsignedInteger:crashCounter] forKey:KCrashManager_lastCrashInfo_isContinuous];
    
    
    

    return lastCrashInfo;
//    
//    [crashInfo setObject:lastCrashInfo forKey:KCrashManager_lastCrashInfo];
//    [[NSUserDefaults standardUserDefaults] setObject:crashInfo forKey:KCrashManager_info];
}



- (NSDictionary*) _crashLogBySignal:(int)signal andTimeStamp:(NSDate*)timeStamp;
{
    NSMutableDictionary* logDict = [NSMutableDictionary dictionary];
    
    /*date*/
    [logDict setObject:timeStamp forKey:KCrashManager_crashlog_date];
    
    /*type*/
    [logDict setObject:CRASHMANAGERTYPENAME_SIGN forKey:KCrashManager_crashlog_type];
    
    /*sub type*/
    NSString* subtype;
    switch (signal)
    {
            CRASHMANAGER_CRASH_SUBTYPE_NAME(SIGABRT, subtype);
            CRASHMANAGER_CRASH_SUBTYPE_NAME(SIGBUS, subtype);
            CRASHMANAGER_CRASH_SUBTYPE_NAME(SIGFPE, subtype);
            CRASHMANAGER_CRASH_SUBTYPE_NAME(SIGILL, subtype);
            CRASHMANAGER_CRASH_SUBTYPE_NAME(SIGPIPE, subtype);
            CRASHMANAGER_CRASH_SUBTYPE_NAME(SIGSEGV, subtype);
        default:
            subtype = @"unknown";
    }
    
    [logDict setObject:subtype forKey:KCrashManager_crashlog_subtype];
    
    
    /*thread id*/
    int threadId = [[runtime sharedManager] threadIndex];
    if (threadId > 0) {
        [logDict setObject:[NSNumber numberWithInt:threadId] forKey:KCrashManager_crashlog_threadId];
    }
    
    
    
    /*call stack*/
    NSArray* callStacks = [[runtime sharedManager] callStacks];
    if (nil != callStacks  &&  0 != callStacks.count) {
        [logDict setObject:callStacks forKey:KCrashManager_crashlog_callstack];
    }
    
    
    /*is jail break*/
    [logDict setObject:[NSNumber numberWithBool:[[runtime sharedManager] isJailBroken]] forKey:KCrashManager_crashlog_isJailBreakFlag];
    
    
    /*uuid*/
    NSString* uuid = [[runtime sharedManager] uuid];
    if (nil != uuid &&  0 != uuid.length) {
        [logDict setObject:uuid forKey:KCrashManager_crashlog_uuid];
    }
    
    /*app Version*/
    NSString* appVersion = [[runtime sharedManager] appVersion];
    if (nil != appVersion  &&  0 != appVersion.length) {
        [logDict setObject:appVersion forKey:KCrashManager_crashlog_appVersion];
    }
    
    
    return logDict;
}

- (NSDictionary*) _crashLogByException:(NSException*)exception andTimeStamp:(NSDate*)timeStamp;
{
    NSMutableDictionary* logDict = [NSMutableDictionary dictionary];
    
    /*date*/
    [logDict setObject:timeStamp forKey:KCrashManager_crashlog_date];
    
    /*type*/
    [logDict setObject:CRASHMANAGERTYPENAME_EXCEPTION forKey:KCrashManager_crashlog_type];
    
    /*subtype*/
    if (nil != [exception name]) {
        [logDict setObject:[exception name] forKey:KCrashManager_crashlog_subtype];
    }
    
    /*description*/
    if (nil != [exception reason]) {
        [logDict setObject:[exception reason] forKey:KCrashManager_crashlog_description];
    }
    
    
    /*thread id*/
    int threadId = [[runtime sharedManager] threadIndex];
    if (threadId > 0) {
        [logDict setObject:[NSNumber numberWithInt:threadId] forKey:KCrashManager_crashlog_threadId];
    }
    
    
    /*call stack*/
    NSArray* callStacks = [[runtime sharedManager] callStacks];
    if (nil != callStacks  &&  0 != callStacks.count) {
        [logDict setObject:callStacks forKey:KCrashManager_crashlog_callstack];
    }
    
    
    /*is jail break*/
    [logDict setObject:[NSNumber numberWithBool:[[runtime sharedManager] isJailBroken]] forKey:KCrashManager_crashlog_isJailBreakFlag];
    
    
    /*uuid*/
    NSString* uuid = [[runtime sharedManager] uuid];
    if (nil != uuid &&  0 != uuid.length) {
        [logDict setObject:uuid forKey:KCrashManager_crashlog_uuid];
    }
    
    /*app Version*/
    NSString* appVersion = [[runtime sharedManager] appVersion];
    if (nil != appVersion  &&  0 != appVersion.length) {
        [logDict setObject:appVersion forKey:KCrashManager_crashlog_appVersion];
    }
    
    
    return logDict;
}

- (void) _handleCrashByCrashLog:(NSDictionary*)crashLog andTimeStamp:(NSDate*)timeStamp
{
    
    /*get storage crashInfo*/
    NSMutableDictionary* crashInfo = nil;
    NSDictionary* crashInfo_tmp = [[NSUserDefaults standardUserDefaults] objectForKey:KCrashManager_info];
    if (nil != crashInfo_tmp) {
        crashInfo = [NSMutableDictionary dictionaryWithDictionary:crashInfo_tmp];
    }
    else {
        crashInfo = [NSMutableDictionary dictionary];
    }
    
    
    
    /*set last crash info*/
    NSDictionary* lastCrashInfo = [self _lastCrashInfoByTimeStamp:timeStamp];
    if (nil != lastCrashInfo) {
        [crashInfo setObject:lastCrashInfo forKey:KCrashManager_lastCrashInfo];
    }
    
    
    /*set crash log*/
    if (nil != crashLog  &&  YES == [self recoreCrashLog]) {
        
        NSArray* crashLogArray_tmp = [crashInfo objectForKey:KCrashManager_crashlogInfo];
        NSMutableArray* crashLogArray = nil;
        if (nil != crashLogArray_tmp)
        {
            crashLogArray = [NSMutableArray arrayWithArray:crashLogArray_tmp];
        }
        else
        {
            crashLogArray = [NSMutableArray arrayWithCapacity:1];
        }
        
        [crashLogArray insertObject:crashLog atIndex:0];
        [crashInfo setObject:crashLogArray forKey:KCrashManager_crashlogInfo];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:crashInfo forKey:KCrashManager_info];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


static void _signalHandler(int signalcode)
{
    
    /*unregist crash monitor*/
    [[crashManager sharedManager] unregistCrashMonitor];
    
    /*crash time*/
    NSDate* crashTimeStamp = [NSDate date];
    
    
    /*set crash log*/
    NSDictionary* crashLog = nil;
    if (YES == [[crashManager sharedManager] recoreCrashLog]) {
        crashLog = [[crashManager sharedManager] _crashLogBySignal:signalcode andTimeStamp:crashTimeStamp];
    }
    
    [[crashManager sharedManager] _handleCrashByCrashLog:crashLog andTimeStamp:crashTimeStamp];
    
}


static void _uncaughtExceptionHandler(NSException *exception)
{
    
    /*unregist crash monitor*/
    [[crashManager sharedManager] unregistCrashMonitor];
    
    /*crash time*/
    NSDate* crashTimeStamp = [NSDate date];
    
    NSDictionary* crashLog = nil;
    if (YES == [[crashManager sharedManager] recoreCrashLog]) {
        crashLog = [[crashManager sharedManager] _crashLogByException:exception andTimeStamp:crashTimeStamp];
    }
    
    [[crashManager sharedManager] _handleCrashByCrashLog:crashLog andTimeStamp:crashTimeStamp];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation crashLog

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.date = [dict objectForKey:KCrashManager_crashlog_date];
        
        self.type = [dict objectForKey:KCrashManager_crashlog_type];
        
        self.subType = [dict objectForKey:KCrashManager_crashlog_subtype];
        
        self.crashInfo = [dict objectForKey:KCrashManager_crashlog_description];
        
        NSNumber* threadId_oc = [dict objectForKey:KCrashManager_crashlog_threadId];
        if (nil != threadId_oc  &&  YES == [threadId_oc isKindOfClass:[NSNumber class]]) {
            self.threadId = [threadId_oc intValue];
        }
        
        self.callstack = [dict objectForKey:KCrashManager_crashlog_callstack];
        NSNumber* jailBreak_oc = [dict objectForKey:KCrashManager_crashlog_isJailBreakFlag];
        if (nil != jailBreak_oc  &&  YES == [jailBreak_oc isKindOfClass:[NSNumber class]]) {
            self.isJailBreak = [threadId_oc boolValue];
        }
        
        self.uuid = [dict objectForKey:KCrashManager_crashlog_uuid];
        
        self.appVersion = [dict objectForKey:KCrashManager_crashlog_appVersion];
    }
    
    return self;
}

+ (instancetype)logWithDictionary:(NSDictionary*)dict
{
    return [[[[self class] alloc] initWithDictionary:dict] autorelease];
}

-(NSString *)description
{
    
    NSString* description = [NSString stringWithFormat:
     @"date=%@\r"
     @"type=%@\r"
     @"subType=%@\r"
     @"info=%@\r"
     @"threadId=%d\r"
     @"callstack=\r%@\r"
     @"isJailBreak=%@\r"
     @"uuid=%@\r"
     @"appVersion=%@\r",
     self.date, self.type, self.subType, self.crashInfo, self.threadId, self.callstack, ((YES == self.isJailBreak)? @"YES" : @"NO"), self.uuid, self.appVersion];
    
    return description;
}


- (void)dealloc
{
    
    [_date release], _date = nil;
    [_type release], _type = nil;
    [_subType release], _subType = nil;
    [_crashInfo release], _crashInfo = nil;
    [_callstack release], _callstack = nil;
    [_uuid release], _uuid = nil;
    [_appVersion release], _appVersion = nil;
    
    
    [super dealloc];
}

@end




