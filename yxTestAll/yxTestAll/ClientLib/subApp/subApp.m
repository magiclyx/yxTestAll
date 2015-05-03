//
//  subApp.m
//  systemRubbishCleaner
//
//  Created by Yuxi Liu on 11/6/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import "subApp.h"
//#include <Cocoa/Cocoa.h>


static subApp* g_subAppInstance = nil;




//add setTimer function to subApp module
static void _timer(CFRunLoopTimerRef timer __unused, void *info)
{
    
//    static int a = 0;
//    a++;
//    
//    if(a == 10){
//        CFRunLoopRef mainLoop = CFRunLoopGetMain();
//        CFRunLoopStop(mainLoop);
//    }
////    CFRunLoopSourceSignal(info);
//    NSLog(@"in _timer");
    
    //Do something here!!
    
    //NSLog(@"try");
    
    
    if( YES == [((id)info) respondsToSelector:@selector(Heartbeat)] )
        [((id)info) Heartbeat];
    
    if(NO == [g_subAppInstance isRunning])
        CFRunLoopStop(CFRunLoopGetCurrent());
}



//this is not valid in 32bit
@interface subApp()
//write property just validate in privacy.
//Because the isRunning must multithreading safety, must use [self setIsRunning:xx].
@property(readwrite, assign, atomic) BOOL isRunning;
@end


@implementation subApp




-(void)run{
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [self setIsRunning:YES];
    
    if([_delegate respondsToSelector:@selector(applicationWillFinishLaunching)])
        [_delegate applicationWillFinishLaunching];
    
    //add initialize work here
    
    if([_delegate respondsToSelector:@selector(applicationDidFinishLaunching)])
        [_delegate applicationDidFinishLaunching];
    
    
    
    //CFRunLoopRef mainLoop = CFRunLoopGetMain();
    CFRunLoopRef _runLoop = CFRunLoopGetCurrent();
    
    CFRunLoopTimerContext timerContext;
    bzero(&timerContext, sizeof(timerContext));
    timerContext.info = (void*)_delegate;
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent(), 0.5, 0, 0, _timer, &timerContext);
    CFRunLoopAddTimer(_runLoop, timer, kCFRunLoopDefaultMode);
    
    CFRunLoopRun();
    
    CFRelease(timer);
    
    
    if([_delegate respondsToSelector:@selector(applicationWillTerminate)])
        [_delegate applicationWillTerminate];
    
    //add release work here
    
    if([_delegate respondsToSelector:@selector(applicationDidTerminate)])
        [_delegate applicationDidTerminate];
    
    
    
    [pool drain];
    
}


-(void)terminate{
    [self setIsRunning:NO];
}


//retain or assign is a question!!
- (void)setDelegate:(id < subAppDelegate >)anObject{
    _delegate = anObject;
}
- (id < subAppDelegate >)delegate{
    return _delegate;
}



@synthesize isRunning = _isRunning;


/////////////////////////////////////////////////////////////////////////////////////////
-(id)init{
    if(nil != (self = [super init])){
        _delegate = nil;
        [self setIsRunning:NO];
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////////////////////////////
/*single operation*/
/////////////////////////////////////////////////////////////////////////////////////////
+ (id)sharedManager
{
    @synchronized(self) {
        if (g_subAppInstance == nil) {
            
            /*this is because init function may failed and return a nil*/
            subApp* app = [[self alloc] init]; // assignment not done here
            g_subAppInstance = app;
        }
    }
    return g_subAppInstance;
}


+(BOOL)sharedInstanceExists{
    return (g_subAppInstance != nil ? YES : NO);
}


+(void)releaseManager{
    
    @synchronized(self){
        if(g_subAppInstance != nil){
            subApp* tmpInstance = g_subAppInstance;
            g_subAppInstance = nil; //Just when g_remoteCallServerInstance is equal to nil, the releaase operation will do the free work
            [tmpInstance release];
        }
        
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (g_subAppInstance == nil) {
            g_subAppInstance = [super allocWithZone:zone];
            return g_subAppInstance;  // assignment and return on first allocation
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
    if(nil == g_subAppInstance)
        [self dealloc];
    
    //do nothing
}

- (id)autorelease
{
    return self;
}



@end
