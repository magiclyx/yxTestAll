//
//  GCDGeneralViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 7/24/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "GCDGeneralViewController.h"

extern void _testCFunction(void *val); //用于_syncUsingFunction 测试

@interface GCDGeneralViewController (){
    
}

/*queue about*/
- (void) _serialDiapatchQueue:(logViewTaskContext*)context; //串行队列
- (void) _concurrentDiapatchQueue:(logViewTaskContext*)context; //并行队列
-(void) _globalQueueAndMainQueue:(logViewTaskContext*)context; //全局队列测试
-(void)_dispatchSetTargetQueue:(logViewTaskContext*)context; //设置目标队列

/*sync about*/
- (void) _basicSync:(logViewTaskContext*)context; //同步
- (void) _basicAsync:(logViewTaskContext*)context; //异步
- (void) _syncUsingFunction:(logViewTaskContext*)context; //_f类的测试
- (void) _dispatchAfter:(logViewTaskContext*)context; //延迟一段时间，插入队列
-(void) _doDispatchApply:(logViewTaskContext*)context; //apply, 执行一个block n 次

/*同步相关*/
- (void) _dispatchBarrierAsync:(logViewTaskContext*)context; //barrier
- (void) _suspendResunme:(logViewTaskContext*)context;
- (void) _semaphore:(logViewTaskContext*)context;
- (void) _dispatchOnce:(logViewTaskContext*)context;

/*dispatch group*/
- (void) _groupWait:(logViewTaskContext*)context;
- (void) _groupNotify:(logViewTaskContext*)context;

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
            
            [self runTask:@"串行queue" withSelector:@selector(_serialDiapatchQueue:) withObject:nil];
            
            [self runTask:@"并行queue" withSelector:@selector(_concurrentDiapatchQueue:) withObject:nil];
            
            [self runTask:@"全局队列和main队列" withSelector:@selector(_globalQueueAndMainQueue:) withObject:nil];
            
            [self runTask:@"测试目标队列" withSelector:@selector(_dispatchSetTargetQueue:) withObject:nil];
        }];
        
        
        
//        /*sync/async*/
        [self groupWithName:@"一些基本sync/async" andGroupblock:^{
            [self runTask:@"sync" withSelector:@selector(_basicSync:) withObject:nil];
            [self runTask:@"async" withSelector:@selector(_basicAsync:) withObject:nil];
            [self runTask:@"使用C函数" withSelector:@selector(_syncUsingFunction:) withObject:nil];
            [self runTask:@"延迟插入队列" withSelector:@selector(_dispatchAfter:) withObject:nil];
            [self runTask:@"apply" withSelector:@selector(_doDispatchApply:) withObject:nil];
        }];
        
        
        /*group*/
        [self groupWithName:@"dispatchGroup" andGroupblock:^{
            [self runTask:@"dispatch_group_notify (异步，完成后调用)" withSelector:@selector(_groupNotify:) withObject:nil];
            [self runTask:@"dispatch_group_wait (挂起，直到完成)" withSelector:@selector(_groupWait:) withObject:nil];

        }];
        
        
        [self groupWithName:@"同步相关" andGroupblock:^{
            [self runTask:@"barrier" withSelector:@selector(_dispatchBarrierAsync:) withObject:nil];
            [self runTask:@"挂起，恢复" withSelector:@selector(_suspendResunme:) withObject:nil];
            [self runTask:@"信标" withSelector:@selector(_semaphore:) withObject:nil];
            [self runTask:@"dispatchOnce" withSelector:@selector(_dispatchOnce:) withObject:nil];
        }];
        
    }];
    
    
}

#pragma mark queue
- (void) _serialDiapatchQueue:(logViewTaskContext*)context{ //串行队列
    
    //创建串行队列
    dispatch_queue_t serialDiapatchQueue=dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_SERIAL);
    
    //使用队列
    dispatch_async(serialDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"1 - async - sleep(1)"];
    });
    dispatch_async(serialDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"2 - async - sleep(1)"];
    });
    dispatch_async(serialDiapatchQueue, ^{
        sleep(1.0f);
        [self log:@"3 - async - sleep(1)"];
    });
    
    
    [context barrierFinishOnQueue:serialDiapatchQueue];
    
    dispatch_release(serialDiapatchQueue);
    
}
- (void) _concurrentDiapatchQueue:(logViewTaskContext*)context{ //并行队列
    
    
    //创建串行队列
    dispatch_queue_t concurrentDiapatchQueue=dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_CONCURRENT);
    
    //使用队列
    dispatch_async(concurrentDiapatchQueue, ^{
        sleep(1);
        [self log:@"1 - async - sleep(1)"];
    });
    dispatch_async(concurrentDiapatchQueue, ^{
        sleep(1);
        [self log:@"2 - async - sleep(1)"];
    });
    dispatch_async(concurrentDiapatchQueue, ^{
        sleep(1);
        [self log:@"3 - async - sleep(1)"];
    });
    
    
    [context barrierFinishOnQueue:concurrentDiapatchQueue];
    
    // ios 6 之后 ARC自动管理 dispatch_release(serialDiapatchQueue);
    dispatch_release(concurrentDiapatchQueue);
    
}

-(void)_globalQueueAndMainQueue:(logViewTaskContext*)context
{
    [context setOperationSemahoreNum:7];
    
    [self log:@"全局队列"];
    //GlobalQueue其实就是系统创建的ConcurrentDiapatchQueue
    //MainQueue其实就是系统创建的位于主线程的SerialDiapatchQueue
    //MainQueue队列中插入会放在本次Runloop的最后
    dispatch_async(dispatch_get_main_queue(), ^{
        [self log:@"5 - main queue" onOperation:context];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self log:@"4 - global - background" onOperation:context];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self log:@"3 - global - low" onOperation:context];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"2 - global - default" onOperation:context];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self log:@"1 - global - hight" onOperation:context];
    });
   
    [self log:@"常用方式"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self log:@"6 - global - hight" onOperation:context];
        dispatch_async(dispatch_get_main_queue(), ^{
        [self log:@"7 - global - main" onOperation:context];
        });
    });
}

-(void)_dispatchSetTargetQueue:(logViewTaskContext*)context
{
    
    /*******************************************************************************************
    Dispatch Queue目标指定
    
    所有的用户队列都有一个目标队列概念。从本质上讲，一个用户队列实际上是不执行任何任务的，但是它会将任务传递给它的目标队列来执行。通常，目标队列是默认优先级的全局队列。
    
    用户队列的目标队列可以用函数 dispatch_set_target_queue来修改。我们可以将任意dispatch queue传递给这个函数，甚至可以是另一个用户队列，只要别构成循环就行。这个函数可以用来设定用户队列的优先级。比如我们可以将用户队列的目标队列设定为低优先级的全局队列，那么我们的用户队列中的任务都会以低优先级执行。高优先级也是一样道理。
    
    有一个用途，是将用户队列的目标定为main queue。这会导致所有提交到该用户队列的block在主线程中执行。这样做来替代直接在主线程中执行代码的好处在于，我们的用户队列可以单独地被挂起和恢复，还可以被重定目标至一个全局队列，然后所有的block会变成在全局队列上执行（只要你确保你的代码离开主线程不会有问题）。
    
    还有一个用途，是将一个用户队列的目标队列指定为另一个用户队列。这样做可以强制多个队列相互协调地串行执行，这样足以构建一组队列，通过挂起和暂停那个目标队列，我们可以挂起和暂停整个组。想象这样一个程序：它扫描一组目录并且加载目录中的内容。为了避免磁盘竞争，我们要确定在同一个物理磁盘上同时只有一个文件加载任务在执行。而希望可以同时从不同的物理磁盘上读取多个文件。要实现这个，我们要做的就是创建一个dispatch queue结构，该结构为磁盘结构的镜像。
    
    首先，我们会扫描系统并找到各个磁盘，为每个磁盘创建一个用户队列。然后扫描文件系统，并为每个文件系统创建一个用户队列，将这些用户队列的目标队列指向合适的磁盘用户队列。最后，每个目录扫描器有自己的队列，其目标队列指向目录所在的文件系统的队列。目录扫描器枚举自己的目录并为每个文件向自己的队列提交一个block。由于整个系统的建立方式，就使得每个物理磁盘被串行访问，而多个物理磁盘被并行访问。除了队列初始化过程，我们根本不需要手动干预什么东西。
    *******************************************************************************************/
    
    
    [self log:@"更改目标队列，改变队列优先级"];
    [self log:@""];
    
    dispatch_queue_t serialDiapatchQueue=dispatch_queue_create("com.test.queue", NULL);
    dispatch_queue_t dispatchgetglobalqueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    dispatch_set_target_queue(serialDiapatchQueue, dispatchgetglobalqueue);
    
    dispatch_async(serialDiapatchQueue, ^{
        [self log:@"优先级被更改为low, 的测试队列"];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self log:@"默认队列"];
    });
    //简单的理解为我们自己创建的queue其实是位于global_queue中执行,所以改变global_queue的优先级，也就改变了我们自己所创建的queue的优先级。
    //同时，我们用这个方法可以做到用队列管理子队列
    
    [context barrierFinishOnQueue:serialDiapatchQueue];
    
    dispatch_release(serialDiapatchQueue);
}

#pragma mark sync/async

- (void) _basicSync:(logViewTaskContext*)context{ //同步
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

- (void) _basicAsync:(logViewTaskContext*)context{ //异步
    
    dispatch_queue_t queue = dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        sleep(1);
        [self log:@"1"];
    });
    dispatch_async(queue, ^{
        sleep(1);
        [self log:@"2"];
    });
    dispatch_async(queue, ^{
        sleep(1);
        [self log:@"3"];
    });
    
    [context barrierFinishOnQueue:queue];
    
    dispatch_release(queue);
}

void _testCFunction(void *val)
{
    GCDGeneralViewController* obj = (GCDGeneralViewController *)val;
    assert(nil != obj);
    assert(NO != [obj isKindOfClass:[GCDGeneralViewController class]]);
    
    [obj log:@"in CFunction"];
}

- (void) _syncUsingFunction:(logViewTaskContext*)context{ //_f类的测试
    // dispatch_async_f(queue, void *context, dispatch_function_t work)
    // queue：指定执行该work的队列,这个和用block一样
    // void *context：所使用的 application-defined（应用程序范围内有效的，也就是全局的）级别的参数。这是个C语法，void * 是一个无类型指针。也就是说，用它可以指向任何内存数据。
    // work：在指定队列（queue 参数）中要执行的方法。在该方法中，第一个参数所指代的数据，也就是dispatch_async_f方法所使用的第二个参数（void *context）所指带的数据。
    
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync_f(queue, (void*)self, _testCFunction);
    
    dispatch_release(queue);
}


-(void)_dispatchAfter:(logViewTaskContext*)context
{
    [context setOperationSemahoreNum:1];
    
    [self log:@"延迟2秒执行"];
    double delayInSeconds = 2.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self log:@"执行!!" onOperation:context];
    });
    //在不挂起线程和不sleep的情况下，在2秒后插入到主线程的RunLoop中，但是之前说了dispatch_get_main_queue是插入到本次RunLoop的最后，所以真正执行会大于2秒。
}

-(void) _doDispatchApply:(logViewTaskContext*)context{ //apply, 执行一个block n 次
    
    [context setOperationSemahoreNum:7];
    
    //此方法可用于异步遍历，提高遍历的效率。
    NSArray *array=[[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6", nil];
    
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        dispatch_apply([array count], queue, ^(size_t index) {
            [self log:[NSString stringWithFormat:@"%zu=%@", index, [array objectAtIndex:index]] onOperation:context];
        });
    });
    
    
}



#pragma mark 同步相关

-(void)_dispatchBarrierAsync:(logViewTaskContext*)context
{
    //创建并发队列
    dispatch_queue_t concurrentDiapatchQueue=dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_CONCURRENT);
    //此方法用于并发队列时打断其他线程，只执行队列中一个任务。
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"1"];});
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"2"];});
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"3"];});
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"4"];});
    dispatch_barrier_async(concurrentDiapatchQueue, ^{sleep(1); [self log:@"5"];});
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"6"];});
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"7"];});
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"8"];});
    dispatch_async(concurrentDiapatchQueue, ^{[self log:@"9"];});
    
    //看打印结果，我们发现，在执行dispatch_barrier_async的时候5、6、7、8也没有并发执行，而是等4执行结束之后，才继续并发执行。
    //我们可以设想一个使用场景，对一个数组删除和读取的时候，如果正在读得瞬间删除了一条数据，导致下标改变，那就有可能出问题，甚至crash，这时候这个操作就能避免此类问题出现。
    
    
    [context barrierFinishOnQueue:concurrentDiapatchQueue];
    
    // ios 6 之后 ARC自动管理 dispatch_release(concurrentDiapatchQueue);
    dispatch_release(concurrentDiapatchQueue);
}

- (void) _suspendResunme:(logViewTaskContext*)context{
    dispatch_queue_t concurrentDiapatchQueue=dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentDiapatchQueue, ^{
        for (int i=0; i<6; i++)
        {
            [self log:[NSString stringWithFormat:@"%d", i]];
            if (i==2)
            {
                dispatch_suspend(concurrentDiapatchQueue);
                sleep(3);
                dispatch_resume(concurrentDiapatchQueue);
            }
        }
    });
    //此demo模拟当遇到符合某个特定值的时候挂起线程，然后等处理完之后恢复线程。
    
    [context barrierFinishOnQueue:concurrentDiapatchQueue];
    
    dispatch_release(concurrentDiapatchQueue);
}

-(void)_semaphore:(logViewTaskContext*)context;
{
    //dispatch_semaphore_signal 信号量+1;
    //dispatch_semaphore_wait 信号量-1, 当变为0后如果是DISPATCH_TIME_FOREVER，则永远等待;
    
    [context setOperationSemahoreNum:5];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);//为了让一次输出2个，初始信号量为2；
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 5; i++)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//每进来1次，信号量-1;进来2次后就一直hold住，直到信号量大于0；
        dispatch_async(queue, ^{
            sleep(2);
            [self log:[NSString stringWithFormat:@"%d", i] onOperation:context];
            dispatch_semaphore_signal(semaphore);//由于这里只是log,所以处理速度非常快，我就模拟2秒后信号量+1;
        });
    }
    
    dispatch_release(queue);
    dispatch_release(semaphore);
    
    //这个demo的使用场景是为了防止并发数过多导致系统资源吃紧。
    //在这里不得不提到并发的真实工作原理，以单核CPU做并发为例，一个CPU永远只能干一件事情，那如何同时处理多个事件呢，聪明的内核工程师让CPU干第一件事情，一定时间后停下来，存取进度，干第二件事情以此类推，所以如果开启非常多的线程，单核CPU会变得非常吃力，即使多核CPU，核心数也是有限的，所以合理分配线程，变得至关重要。
    //讲到这也不得不提如何高效的发挥多核CPU的性能，如果让一个核心模拟传很多线程，经常干一半放下干另一件事情，那效率也会变低，所以我们要合理安排，将单一任务或者一组相关任务并发至全局队列中运算或者将多个不相关的任务或者关联不紧密的任务并发至用户队列中运算。
}

- (void) _dispatchOnce:(logViewTaskContext*)context{
    //此方法都用于单例。
    static dispatch_once_t once;
    dispatch_once(&once,^{
        [self log:@"只执行1次"];
    });
}


#pragma mark dispatch_group

/*dispatch group*/
- (void) _groupWait:(logViewTaskContext*)context{
    
    [context setOperationSemahoreNum:1];
    
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group=dispatch_group_create();
    dispatch_group_async(group, queue, ^{[self log:@"1"];});
    dispatch_group_async(group, queue, ^{[self log:@"2"];});
    dispatch_group_async(group, queue, ^{[self log:@"3"];});
    
    //dispatch_group_wait(group, DISPATCH_TIME_NOW) 这个方法在每个RunLoop的周期中都会返回值，用来检查是否执行完成。
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    [self log:@"finished" onOperation:context];
    
    
    dispatch_release(queue);
    dispatch_release(group);
}
- (void) _groupNotify:(logViewTaskContext*)context{
    
    [context setOperationSemahoreNum:1];
    
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group=dispatch_group_create();
    dispatch_group_async(group, queue, ^{[self log:@"1"];});
    dispatch_group_async(group, queue, ^{[self log:@"2"];});
    dispatch_group_async(group, queue, ^{[self log:@"3"];});
    
     //之前说了用dispatch_set_target_queue把子队列放到一个串行队列中，如果子队列是串行队列也可以达到一样的效果，但是并发队列的管理就变得复杂了，故引入Group的方法。
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{[self log:@"finished" onOperation:context];});
    
    
    dispatch_release(queue);
    dispatch_release(group);
}


@end
