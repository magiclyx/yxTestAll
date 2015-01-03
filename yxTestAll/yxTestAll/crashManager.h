//
//  crashManager.h
//  yxTestAll
//
//  Created by Yuxi Liu on 12/18/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface crashManager : NSObject

@property(readwrite, retain, nonatomic) NSDate* lastCrashDate;
@property(readwrite, assign, nonatomic) NSUInteger continuousCrashCounter;

@property(readwrite, assign, nonatomic) BOOL recoreCrashLog;
@property(readonly, retain, nonatomic) NSArray* crashLog;


+ (instancetype)sharedManager;

- (void)registCrashMonitor;
- (void)unregistCrashMonitor;

- (void)cleanLog; //This operation will keep the last log

@end



@interface crashLog : NSObject

@property(readwrite, retain, nonatomic) NSDate* date;
@property(readwrite, retain, nonatomic) NSString* type;
@property(readwrite, retain, nonatomic) NSString* subType;
@property(readwrite, retain, nonatomic) NSString* crashInfo;
@property(readwrite, assign, nonatomic) int threadId;
@property(readwrite, retain, nonatomic) NSArray* callstack;
@property(readwrite, assign, nonatomic) BOOL isJailBreak;
@property(readwrite, retain, nonatomic) NSString* uuid;
@property(readwrite, retain, nonatomic) NSString* appVersion;

@end


