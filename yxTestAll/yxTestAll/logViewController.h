//
//  logViewController.h
//  yxTestAll
//
//  Created by Yuxi Liu on 7/24/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "logView.h"

@class logViewTaskContext;


typedef void (^logTaskBlock)(logViewTaskContext*);
typedef void* logViewSemaphoreHandle;



@interface logViewTaskContext: NSObject
- (void) setOperationSemahoreNum:(int)num;
- (void) barrierFinishOnQueue:(dispatch_queue_t)queue; //just working on async and custom queue

@property(readwrite, retain, nonatomic) id userInfo;

@end






@interface logViewController : UIViewController

@property(readwrite, assign) BOOL shouldIntervalInDifferentTask;
@property(readwrite, assign) CGFloat intervalPerTask;


- (logView*)logView;

- (void)startWithName:(NSString *)name andWorkingBlock:(void (^)(void))block;
- (void)reset;

- (void)groupWithName:(NSString *)name andGroupblock:(void (^)(void))block;

- (void)runTask:(NSString *)taskName withSelector:(SEL)selector withObject:(id)object;
- (void)runTask:(NSString *)taskName withTaskBlock:(logTaskBlock)block;

- (void)log:(NSString *)msg;
- (void)log:(NSString *)msg onOperation:(logViewTaskContext *)context;
- (void)separateBar;


@end









