//
//  logViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 7/24/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "logViewController.h"
#import "logView.h"


@interface logViewTaskContext(){
    dispatch_semaphore_t _semaphore;
    dispatch_queue_t _threadSafeQueue;
    
    NSUInteger _operationNum;
    
}
+ (id)context;
- (void) reduceSemahore;
- (void) waitSemahoreIfNeed;
@end




@interface logViewController (){
    NSString* _workQueueLabe;
    dispatch_queue_t _workingQueue;
    dispatch_queue_t _logQueue;
    dispatch_queue_t _semphoreQueue;
    //outputView* _output;
    logView* _output;
    
    
    BOOL _firstSection; //第一个显示的内容，不需要时间间隔
}

@property(readwrite, assign, getter = isFirstSection) BOOL firstSection;

@end

@implementation logViewController

@synthesize shouldIntervalInDifferentTask;
@synthesize intervalPerTask;

@synthesize firstSection = _firstSection;


- (void)startWithName:(NSString *)name andWorkingBlock:(void (^)(void))block{
    
    assert(nil != block);
    
    dispatch_async(_workingQueue, ^{
        
        if (nil != name) {
            assert(YES == [name isKindOfClass:[NSString class]]);
            
            [self log:name];
            [self log:@""];
            
            [NSThread sleepForTimeInterval:[self intervalPerTask]];
            [self setFirstSection:NO];
        }
        
        block();
    });
}

- (void)reset{
    [self setShouldIntervalInDifferentTask:NO];
    [self setFirstSection:YES];
}

- (void)groupWithName:(NSString *)name andGroupblock:(void (^)(void))block{
    if (nil != name) {
        assert(YES == [name isKindOfClass:[NSString class]]);
        
            [self log:name];
            [self log:@""];
            [NSThread sleepForTimeInterval:[self intervalPerTask]];
            [self setFirstSection:NO];
    }
    
    block();
}

- (void)runTask:(NSString *)taskName withSelector:(SEL)selector withObject:(id)object{
    
    assert(YES == [self respondsToSelector:selector]);
    
    [self runTask:taskName withTaskBlock:^(logViewTaskContext* context){
        
        if (nil != object) {
            [context setUserInfo:object];
        }
        
        [self performSelector:selector withObject:context];
    }];
    
}

- (void)runTask:(NSString *)taskName withTaskBlock:(logTaskBlock)block{
    
    assert(nil != taskName);
    assert(YES == [taskName isKindOfClass:[NSString class]]);
    assert(nil != block);
    
    if (NO == [self isFirstSection]) {
        if (YES == [self shouldIntervalInDifferentTask]) {
            [NSThread sleepForTimeInterval:[self intervalPerTask]];
        }
    }
    else{
        [self setFirstSection:NO];
    }
    
    logViewTaskContext* context = [[logViewTaskContext alloc] init];
    
    
    [self log:taskName];
    [self log:@"-----------------------"];
    
    @try {
        block(context);
        [context waitSemahoreIfNeed];
    }
    @catch (NSException *exception) {
        [self log:[NSString stringWithFormat:@"%@", exception]];
    }
    
    [self log:@"done"];
    [self log:@"-----------------------"];
    [self separateBar];
    
    [context release];
}


- (void)log:(NSString *)msg{
   dispatch_async(_logQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_output log:msg];
        });
   });
    
}

- (void)log:(NSString *)msg onOperation:(logViewTaskContext *)context{
    
    [self log:msg];
    
    if (nil != context) {
        [context reduceSemahore];
    }
}

- (void)separateBar{
   dispatch_async(_logQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_output separateBar];
        });
   });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark lifecrycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_output setFrame:self.view.bounds];
    [self.view addSubview:_output];
    [self.view setAutoresizesSubviews:YES];
    [_output setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self setShouldIntervalInDifferentTask:NO];
        [self setIntervalPerTask:1.0f];
        [self setFirstSection:YES];
        
        /*初始化 working queue*/
        _workQueueLabe = [[NSString stringWithFormat:@"com.yxTestAll.workingQueue.%lu", (unsigned long)(void*)self] retain];
        _workingQueue = dispatch_queue_create([_workQueueLabe UTF8String], DISPATCH_QUEUE_CONCURRENT);
        
        _logQueue = dispatch_queue_create("com.yxTestAll.logQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_logQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        
        _semphoreQueue = dispatch_queue_create("com.yxTestAll.semphoreQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_semphoreQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        
        /*初始化 outputView*/
        _output = [[logView alloc] initWithFrame:CGRectZero];
        //_output = [[outputView alloc] initWithFrame:CGRectZero];
    }
    return self;
    
}

-(void)dealloc{
    
    [_output release], _output = nil;
    
    dispatch_release(_workingQueue);
    [_workQueueLabe release], _workQueueLabe = nil;
    
    dispatch_release(_logQueue);
    
    dispatch_release(_semphoreQueue);
    
    [super dealloc];
}


@end



@implementation logViewTaskContext

@synthesize userInfo;


- (id) init{
    self = [super init];
    if (self) {
        [self setUserInfo:nil];
        _semaphore = nil;
        
        _threadSafeQueue = dispatch_queue_create("com.yxTestAll.logViewContextThreadSafeQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_threadSafeQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    }
    
    return self;
}

-(void)dealloc{
    
    dispatch_release(_threadSafeQueue);
    if (NULL != _semaphore) {
        dispatch_release(_semaphore);
    }
    
    [super dealloc];
}

+ (id)context{
    return [[[[self class] alloc] init] autorelease];
}


- (void) setOperationSemahoreNum:(int)num{
    
    dispatch_sync(_threadSafeQueue, ^{
        if (NULL == _semaphore) {
            _operationNum = num;
            _semaphore = dispatch_semaphore_create(0);
        }
    });
}

- (void) reduceSemahore{
    
    dispatch_sync(_threadSafeQueue, ^{
        _operationNum --;
        
        if (0 == _operationNum) {
            dispatch_semaphore_signal(_semaphore);
        }
    });
}

- (void) waitSemahoreIfNeed{
    if (NULL != _semaphore) {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    }
}

- (void) barrierFinishOnQueue:(dispatch_queue_t)queue{ //just working on async and custom queue
    
    /*
     这个函数只能用于自己的队列，而且是DISPATCH_QUEUE_CONCURRENT队列。
     否则
     它的行为等同于dispatch_sync函数
     */
    dispatch_barrier_sync(queue, ^{});
}


@end


