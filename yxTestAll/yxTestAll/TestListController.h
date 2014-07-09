//
//  TestListController.h
//  testNavigation
//
//  Created by Yuxi Liu on 6/20/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  测试结果
 */
@interface TestResult : NSObject

@property(readwrite, assign) BOOL isSuccess;
@property(readwrite, nonatomic, retain) NSString *resultInfo;

+ (id)state:(BOOL)isSuccss;
+ (id)info:(NSString *)info;
+ (id)state:(BOOL)isSuccss andInfo:(NSString *)info;

@end



/**
 *  测试上下文
 */
@interface TestContext : NSObject

@property(readwrite, assign) id target;
@property(readwrite, assign) SEL selector;
@property(readwrite, retain, nonatomic) id userData;
@property(readwrite, retain, nonatomic) NSString *title;
@property(readwrite, retain, nonatomic) TestResult *result; //在测试之前，这一项是nil
@property(readonly, assign) NSTimeInterval timeInterval; //测试前是-1


@end




/**
 *  测试列表代理
 */
@class TestListController;
@protocol TestListControllerDelegate <NSObject>


/*
 测试开始/结束
 */
- (void) willStartTestOperation:(TestListController *)testController;
- (void) didFinishThestOperation:(TestListController *)testController;


/*
 test one by one
 */
- (BOOL) canRunTest:(TestContext *)context;
- (void) willRunTest:(TestContext *)context;
- (void) didRunTest:(TestContext *)context;

/*
 无法正常运行测试模块
 返回值是要在list中显示的状态
 */
- (TestResult *) errorOnTest:(TestContext *)context withError:(NSError *)err;

@end



/**
 *  测试列表
 */
@interface TestListController : UIViewController
@property (readwrite, assign) BOOL showRedGreenStyle;
@property (readwrite, assign) BOOL showProgressLight;
@property (readwrite, assign) BOOL showTime;
@property (readwrite, assign) BOOL autoRun;
@property (readwrite, assign) id<TestListControllerDelegate> delegate;




/*背景色*/
@property(readwrite, retain, nonatomic) UIColor *bg_normalColor;

/*showProgressLight == YES 时有效*/
@property(readwrite, retain, nonatomic) UIColor *bg_testingColor;
@property(readwrite, retain, nonatomic) UIColor *bg_finishColor;

/*showRedGreenStyle == YES 时有效*/
@property(readwrite, retain, nonatomic) UIColor *successColor;
@property(readwrite, retain, nonatomic) UIColor *failureColor;



- (void)addTestWithTitle:(NSString *)title Target:(id)target selector:(SEL)selector andUserInfo:(id)data;
- (NSArray*)allTestContext;
- (NSUInteger)testCount;

@end


































