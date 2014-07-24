//
//  logViewController.h
//  yxTestAll
//
//  Created by Yuxi Liu on 7/24/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^logWorkingBlock)(void);
typedef void (^logGroupBlock)(void);
typedef void (^logTaskBlock)(void);

@interface logViewController : UIViewController

@property(readwrite, assign) BOOL shouldIntervalInDifferentTask;
@property(readwrite, assign) CGFloat intervalPerTask;

- (void)startWithName:(NSString *)name andWorkingBlock:(logWorkingBlock)block;
- (void)rest;

- (void)groupWithName:(NSString *)name andGroupblock:(logGroupBlock)block;

- (void)runTask:(NSString *)taskName withSelector:(SEL)selector withObject:(id)object;
- (void)runTask:(NSString *)taskName withTaskBlock:(logTaskBlock)block;

- (void)log:(NSString *)msg;

@end
