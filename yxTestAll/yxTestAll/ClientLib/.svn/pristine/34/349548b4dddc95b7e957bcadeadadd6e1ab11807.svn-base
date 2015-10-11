//
//  Loger.m
//  360ClientUI
//
//  Created by Yuxi Liu on 11/5/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import "Loger.h"




const NSString* LOG_LEVEL_EMERG = @"LOG_LEVEL_EMERG";
const NSString* LOG_LEVEL_ALERT = @"LOG_LEVEL_ALERT";
const NSString* LOG_LEVEL_CRIT = @"LOG_LEVEL_CRIT";
const NSString* LOG_LEVEL_ERR = @"LOG_LEVEL_ERR";
const NSString* LOG_LEVEL_WARNING = @"LOG_LEVEL_WARNING";
const NSString* LOG_LEVEL_NOTICE = @"LOG_LEVEL_NOTICE";
const NSString* LOG_LEVEL_INFO = @"LOG_LEVEL_INFO";
const NSString* LOG_LEVEL_DEBUG = @"LOG_LEVEL_DEBUG";









static Loger* g_logerInstance = nil;


@interface Loger()

@property(readwrite, assign) HSL_Handle logerHandle;

-(int)getLevelNum:(const NSString*)level;

-(Loger*)initUsrLogWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName;
-(Loger*)initSysLogWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName;

@end


@implementation Loger



-(NSString*)logIdentifier{
    return [NSString stringWithUTF8String:SL_Identifier(_logerHandle)];
}

-(NSString*)facilityIdentifier{
    return [NSString stringWithUTF8String:SL_Facility(_logerHandle)];
}


-(int)changeDirName:(NSString*)dirName fileName:(NSString*)fileName{
    return SL_bindLogFile(_logerHandle, [dirName UTF8String], [fileName UTF8String]);
}



-(void)setLogIdentifier:(NSString *)theLogIdentifier{
    SL_setIdent(_logerHandle, [theLogIdentifier UTF8String]);
}

-(void)setFacilityIdentifier:(NSString *)theFacilityIdentifier{
    SL_setFacility(_logerHandle, [theFacilityIdentifier UTF8String]);
}




-(int)getLevelNum:(const NSString*)level{
    
    int numLevel = -1;
    
    if(level == LOG_LEVEL_EMERG || YES == [level isEqualToString:(NSString*)LOG_LEVEL_EMERG]){
        numLevel = 0;
    }
    else if(level == LOG_LEVEL_ALERT || YES == [level isEqualToString:(NSString*)LOG_LEVEL_ALERT]){
        numLevel = 1;
    }else if(level == LOG_LEVEL_CRIT || YES == [level isEqualToString:(NSString*)LOG_LEVEL_CRIT]){
        numLevel = 2;
    }else if(level == LOG_LEVEL_ERR || YES == [level isEqualToString:(NSString*)LOG_LEVEL_ERR]){
        numLevel = 3;
    }else if(level == LOG_LEVEL_WARNING || YES == [level isEqualToString:(NSString*)LOG_LEVEL_WARNING]){
        numLevel = 4;
    }else if(level == LOG_LEVEL_NOTICE || YES == [level isEqualToString:(NSString*)LOG_LEVEL_NOTICE]){
        numLevel = 5;
    }else if(level == LOG_LEVEL_INFO || YES == [level isEqualToString:(NSString*)LOG_LEVEL_INFO]){
        numLevel = 6;
    }else if(level == LOG_LEVEL_DEBUG || YES == [level isEqualToString:(NSString*)LOG_LEVEL_DEBUG]){
        numLevel = 7;
    }
    
    
    return numLevel;
}


-(void) logerMsg:(NSString*)msg as:(const NSString*)level{
    Loger* loger = [Loger sharedManager];
    SL_Log([loger logerHandle], [self getLevelNum:level], [msg UTF8String]);
}



-(void)setLevel:(const NSString*)level{
    Loger* loger = [Loger sharedManager];
    SL_SetLevel([loger logerHandle], [self getLevelNum:level]);
}


-(void) debug:(const NSString *)info{
    Loger* loger = [Loger sharedManager];
    SL_Log([loger logerHandle], [self getLevelNum:LOG_LEVEL_DEBUG], [info UTF8String]);
}

-(void) info:(NSString*)info{
    Loger* loger = [Loger sharedManager];
    SL_Log([loger logerHandle], [self getLevelNum:LOG_LEVEL_INFO], [info UTF8String]);
}


-(void) notice:(const NSString *)info{
    Loger* loger = [Loger sharedManager];
    SL_Log([loger logerHandle], [self getLevelNum:LOG_LEVEL_NOTICE], [info UTF8String]);
}


-(void) warning:(NSString*)info{
    Loger* loger = [Loger sharedManager];
    SL_Log([loger logerHandle], [self getLevelNum:LOG_LEVEL_WARNING], [info UTF8String]);
}


-(void) err:(NSString*)info{
    Loger* loger = [Loger sharedManager];
    SL_Log([loger logerHandle], [self getLevelNum:LOG_LEVEL_ERR], [info UTF8String]);
}

-(void) fatal:(NSString*)info{
    Loger* loger = [Loger sharedManager];
    SL_Log([loger logerHandle], [self getLevelNum:LOG_LEVEL_CRIT], [info UTF8String]);
}


@synthesize logerHandle = _logerHandle;


-(Loger*)initUsrLogWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName{
    if(nil != (self = [super init])){
        
        
        _logerHandle = SL_InitUserLog(
                                      [identifier UTF8String],
                                      [facility UTF8String],
                                      [dirName UTF8String],
                                      [fileName UTF8String]);
        
        
        //if fail to initialize
        if(NULL == _logerHandle){
            [self release];
            self = nil;
        }
    }
    
    
    return self;
}
-(Loger*)initSysLogWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName{
    if(nil != (self = [super init])){
        
        
        _logerHandle = SL_InitSyeLog(
                                      [identifier UTF8String],
                                      [facility UTF8String],
                                      [dirName UTF8String],
                                      [fileName UTF8String]);
        
        
        //if fail to initialize
        if(NULL == _logerHandle){
            [self release];
            self = nil;
        }
    }
    
    
    return self;
}





/////////////////////////////////////////////////////////////////////////////////////////
/*single operation*/
/////////////////////////////////////////////////////////////////////////////////////////



+(Loger*)initUsrLogManagerWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName{
    @synchronized(self) {
        if (g_logerInstance == nil) {
            
            Loger* loger = [[self alloc] initUsrLogWithIdentifier:identifier facility:facility dirName:dirName fileName:fileName]; // assignment not done here
            g_logerInstance = loger;
        }
    }
    return g_logerInstance;
}
+(Loger*)initSysLogManagerWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName{
    @synchronized(self) {
        if (g_logerInstance == nil) {
            
            Loger* loger = [[self alloc] initSysLogWithIdentifier:identifier facility:facility dirName:dirName fileName:fileName]; // assignment not done here
            g_logerInstance = loger;
        }
    }
    return g_logerInstance;
}


+ (Loger*)sharedManager
{
    @synchronized(self) {
        if (g_logerInstance == nil) {
            
            Loger* loger = [[self alloc] initUsrLogWithIdentifier:@"[loger]identifier" facility:@"[loger]facilityIdentifier" dirName:[NSString stringWithFormat:@"[loger]%@", NSUserName()] fileName:[NSString stringWithFormat:@"[loger]%@", NSUserName()]]; // assignment not done here
            g_logerInstance = loger;
        }
    }
    return g_logerInstance;
}





+(BOOL)sharedInstanceExists{
    return (g_logerInstance != nil ? YES : NO);
}





+(void)releaseManager{
    
    @synchronized(self){
        if(g_logerInstance != nil){
            Loger* tmpInstance = g_logerInstance;
            g_logerInstance = nil; //Just when g_remoteCallServerInstance is equal to nil, the releaase operation will do the free work
            [tmpInstance release];
        }
        
    }
}





+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (g_logerInstance == nil) {
            g_logerInstance = [super allocWithZone:zone];
            return g_logerInstance;  // assignment and return on first allocation
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
    if(nil == g_logerInstance){
        
        if(NULL != _logerHandle)
            SL_ReleaseUserLog(&_logerHandle);
        
        [self dealloc];
    }
    
    //do nothing
}

- (id)autorelease
{
    return self;
}







@end






