//
//  Loger.h
//  360ClientUI
//
//  Created by Yuxi Liu on 11/5/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Log.h"

//several level
extern const NSString* LOG_LEVEL_EMERG;
extern const NSString* LOG_LEVEL_ALERT;
extern const NSString* LOG_LEVEL_CRIT;
extern const NSString* LOG_LEVEL_ERR;
extern const NSString* LOG_LEVEL_WARNING;
extern const NSString* LOG_LEVEL_NOTICE;
extern const NSString* LOG_LEVEL_INFO;
extern const NSString* LOG_LEVEL_DEBUG;



@interface Loger : NSObject{
    
    @private
    HSL_Handle _logerHandle;
}


+(Loger*)initUsrLogManagerWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName;
+(Loger*)initSysLogManagerWithIdentifier:(NSString*)identifier facility:(NSString*)facility dirName:(NSString*)dirName fileName:(NSString*)fileName;
+(Loger*)sharedManager;
+(BOOL)sharedInstanceExists;
+(void)releaseManager;



-(void)setLevel:(const NSString*)level;


-(void) logerMsg:(NSString*)msg as:(const NSString*)level;

-(void) debug:(const NSString *)info;
-(void) info:(const NSString*)info;
-(void) notice:(const NSString *)info;
-(void) warning:(const NSString*)info;
-(void) err:(const NSString*)info;
-(void) fatal:(const NSString*)info; //The fatal is "LOG_LEVEL_CRIT"


-(int)changeDirName:(NSString*)dirName fileName:(NSString*)fileName;
@property(readwrite, retain) NSString* logIdentifier;
@property(readwrite, retain) NSString* facilityIdentifier;



@end



