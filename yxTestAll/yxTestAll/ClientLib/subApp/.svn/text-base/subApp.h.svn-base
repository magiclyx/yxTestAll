//
//  subApp.h
//  systemRubbishCleaner
//
//  Created by Yuxi Liu on 11/6/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//



//the sub app is just like a light NSApplication interface.
//it help to  more flexible control codes

//:~ TODO bugs~

/*
 add the memory pool in the heartbeat timer
 */

#import <Foundation/Foundation.h>

#import "subAppDelegate.h"



@interface subApp : NSObject{
@private
    BOOL _isRunning;
    IBOutlet id < subAppDelegate > _delegate;
}


@property(readonly, assign, atomic) BOOL isRunning;


//instance manager
+(id) sharedManager;
+(BOOL)sharedInstanceExists;
+(void)releaseManager;


- (void)setDelegate:(id < subAppDelegate >)anObject;
- (id < subAppDelegate >)delegate;


-(void)run;
-(void)terminate;



//:~ TODO
//-(void)addTimer;
//-(void)addEvent;
//-(void)addObserver;

@end
