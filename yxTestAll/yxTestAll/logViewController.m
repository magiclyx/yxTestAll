//
//  logViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 7/24/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "logViewController.h"
#import "outputView.h"

@interface logViewController (){
    NSString* _workQueueLabe;
    dispatch_queue_t _workingQueue;
    outputView* _output;
    
    
    BOOL _firstSection; //第一个显示的内容，不需要时间间隔
}

@property(readwrite, assign, getter = isFirstSection) BOOL firstSection;

@end

@implementation logViewController

@synthesize shouldIntervalInDifferentTask;
@synthesize intervalPerTask;

@synthesize firstSection = _firstSection;


- (void)startWithName:(NSString *)name andWorkingBlock:(logWorkingBlock)block{
    
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

- (void)rest{
    [self setShouldIntervalInDifferentTask:NO];
    [self setFirstSection:YES];
}

- (void)groupWithName:(NSString *)name andGroupblock:(logGroupBlock)block{
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
    
    [self runTask:taskName withTaskBlock:^{
        [self performSelector:selector withObject:object];
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
    
    [self log:taskName];
    [self log:@"-----------------------"];
    
    block();
    
    
    [self log:@"done"];
    [self log:@"-----------------------"];
    [self log:@""];
}

- (void)log:(NSString *)msg{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_output log:msg];
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
        _workQueueLabe = [[NSString stringWithFormat:@"com.yuTestAll.workingQueue.%lu", (unsigned long)(void*)self] retain];
        _workingQueue = dispatch_queue_create([_workQueueLabe UTF8String], DISPATCH_QUEUE_CONCURRENT);
        
        /*初始化 outputView*/
        _output = [[outputView alloc] initWithFrame:CGRectZero];
    }
    return self;
    
}

-(void)dealloc{
    
    [_output release], _output = nil;
    
    dispatch_release(_workingQueue);
    [_workQueueLabe release], _workQueueLabe = nil;
    
    [super dealloc];
}


@end
