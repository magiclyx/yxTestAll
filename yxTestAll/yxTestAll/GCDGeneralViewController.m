//
//  GCDGeneralViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 7/24/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "GCDGeneralViewController.h"

@interface GCDGeneralViewController (){
    
}

/*queue about*/
- (void) _serialDiapatchQueue; //串行队列
- (void) _concurrentDiapatchQueue; //并行队列

/*sync about*/
- (void) _testBasicSync; //同步
- (void) _testBasicAsync; //异步
- (void) _testDispatchUsingFunction; //_f类的测试

@end

@implementation GCDGeneralViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setShouldIntervalInDifferentTask:YES];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    [self startWithName:@"测试GCD" andWorkingBlock:^{
        
        
        /*queue*/
        [self groupWithName:@"queue" andGroupblock:^{
            
            [self runTask:@"串行queue" withSelector:@selector(_serialDiapatchQueue) withObject:nil];
            
            [self runTask:@"并行queue" withSelector:@selector(_concurrentDiapatchQueue) withObject:nil];
        }];
        
        
        
        /*sync/async*/
        [self groupWithName:@"sync/async" andGroupblock:^{
            [self runTask:@"各种sync" withSelector:@selector(_testBasicSync) withObject:nil];

        }];
        
        
        
        
    }];
    
    
}

#pragma mark queue
- (void) _serialDiapatchQueue{ //串行队列
    
    //创建串行队列
    dispatch_queue_t serialDiapatchQueue=dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_SERIAL);
    
    //使用队列
    dispatch_async(serialDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"1"];
    });
    dispatch_async(serialDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"2"];
    });
    dispatch_async(serialDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"3"];
    });
    
    dispatch_barrier_sync(serialDiapatchQueue, ^{});
    
    
    dispatch_release(serialDiapatchQueue);
    
}
- (void) _concurrentDiapatchQueue{ //并行队列
    
    
    //创建串行队列
    dispatch_queue_t concurrentDiapatchQueue=dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_CONCURRENT);
    
    //使用队列
    dispatch_async(concurrentDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"1"];
    });
    dispatch_async(concurrentDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"2"];
    });
    dispatch_async(concurrentDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"3"];
    });
    
    
    dispatch_barrier_sync(concurrentDiapatchQueue, ^{});
    
    // ios 6 之后 ARC自动管理 dispatch_release(serialDiapatchQueue);
    dispatch_release(concurrentDiapatchQueue);
    
}

#pragma mark sync/async

- (void) _testBasicSync{ //同步
    //切记，千万别在执行Dispatch Sync方法的队列中调用自身队列，否则，死锁。
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        sleep(1.0f);
        [self log:@"1"];
    });
    dispatch_sync(queue, ^{
        sleep(1.0f);
        [self log:@"2"];
    });
    dispatch_sync(queue, ^{
        sleep(1.0f);
        [self log:@"3"];
    });
    
    dispatch_release(queue);
}

- (void) _testBasicAsync{ //异步
}

- (void) _testDispatchUsingFunction{ //_f类的测试
}

@end
