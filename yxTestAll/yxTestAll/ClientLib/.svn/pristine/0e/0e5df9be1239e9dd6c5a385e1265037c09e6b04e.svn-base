//
//  queue.m
//  ClientLib
//
//  Created by Yuxi Liu on 7/4/13.
//
//

#import "queue.h"
#import "linkedListOnThread.h"

static const NSUInteger _no_data_ = 0;
static const NSUInteger _has_data_ = 1;
static const NSUInteger _unlock_all_ = INT32_MAX - 1;
static const NSUInteger _none_ = INT32_MAX;



@interface queue()
//-(void)waitForTerminate;
@end

@implementation queue

@synthesize count = _count;

-(id)init{
    return [self initWithNumOfPriorityLevel:1];
}
-(id)initWithNumOfPriorityLevel:(int)num{
    
    assert(0 != num);
    
    self = [super init];
    if(self){
        
        NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:num];
        for(int i=0; i<num; i++){
            linkedListOnThread* list = [[linkedListOnThread alloc] init];
            [arr addObject:list];
            [list release];
        }
        
        _queueList = [[NSArray alloc] initWithArray:arr];
        [arr release];
        arr = nil;
        
        
       _condionLock = [[NSConditionLock alloc] initWithCondition:_no_data_];
        _isStop = NO;
        _count = 0;
    }
    
    return self;
}

-(void)dealloc{
    
    [self terminate:NO];
    
    [_queueList release];
    _queueList = nil;
    
    [_condionLock release];
    _condionLock = nil;
    
    
    [super dealloc];
}

-(NSString *)description{
    return [_queueList description];
}


-(void)pushObjectAtFront:(id)obj{
    
    linkedListOnThread* lowestList = [_queueList lastObject];
    [lowestList addObjectAtFront:obj];
    
    [_condionLock lock];
    _count = _count + 1;
    [_condionLock unlockWithCondition:(0==_count)? _no_data_ : _has_data_];
}
-(void)pushObjectAtEnd:(id)obj{
    linkedListOnThread* lowestList = [_queueList lastObject];
    [lowestList addObjectAtEnd:obj];
    
    [_condionLock lock];
    _count = _count + 1;
    [_condionLock unlockWithCondition:(0==_count)? _no_data_ : _has_data_];
}

-(void)pushObjectAtFront:(id)obj withPriority:(int)priority{
    
    assert(priority < [_queueList count]);//out of range
    
    linkedListOnThread* lowestList = [_queueList objectAtIndex:priority];
    [lowestList addObjectAtFront:obj];
    
    [_condionLock lock];
    _count = _count + 1;
    [_condionLock unlockWithCondition:(0==_count)? _no_data_ : _has_data_];
}
-(void)pushObjectAtEnd:(id)obj withPriority:(int)priority{
    linkedListOnThread* lowestList = [_queueList objectAtIndex:priority];
    [lowestList addObjectAtEnd:obj];
    
    [_condionLock lock];
    _count = _count + 1;
    [_condionLock unlockWithCondition:(0==_count)? _no_data_ : _has_data_];
}

-(void)moveObjectAtFront:(id)obj withPriority:(int)priority{
    
    if(YES == [_condionLock lockWhenCondition:_has_data_ beforeDate:[NSDate dateWithTimeIntervalSinceNow:0]]){
        for(linkedListOnThread* list in _queueList){
            int rmNum = [list removeObject:obj];
            _count -= rmNum;
        }
    }
    assert(_count >= 0);
    [_condionLock unlockWithCondition:(YES == _isStop ||  0 != _count)? _has_data_ : _no_data_ ];
    
    
    [self pushObjectAtFront:obj withPriority:priority];
    
}
-(void)moveObjectAtEnd:(id)obj withPriority:(int)priority{
    
    if(YES == [_condionLock lockWhenCondition:_has_data_ beforeDate:[NSDate dateWithTimeIntervalSinceNow:0]]){
        for(linkedListOnThread* list in _queueList){
            int rmNum = [list removeObject:obj];
            _count -= rmNum;
        }
    }
    assert(_count >= 0);
    [_condionLock unlockWithCondition:(YES == _isStop ||  0 != _count)? _has_data_ : _no_data_ ];
    
    
    [self pushObjectAtEnd:obj withPriority:priority];
}


-(void)clearWithPriority:(int)priority{
    
    assert(priority < [_queueList count]);//out of range
    [[_queueList objectAtIndex:priority] removeAllObjects];
    
    
    //some thread may push new objects after we clear the list.
    //so, I should re-calculate the num of object in list
    [_condionLock lock];
    
    int _currCount = 0;
    for(linkedListOnThread* list in _queueList){
        _currCount += [list count];
    }
    
    [_condionLock unlockWithCondition:(0==_count)? _no_data_ : _has_data_];
}
-(void)clearAll{
    
    //lock all the list
    for(linkedListOnThread* list in _queueList){
        [list removeAllObjects];
    }
    
    
    //some thread may push new objects after we clear the list.
    //so, I should re-calculate the num of object in list
    [_condionLock lock];

    int _currCount = 0;
    for(linkedListOnThread* list in _queueList){
        _currCount += [list count];
    }
    
    _count = _currCount;
    [_condionLock unlockWithCondition:(0==_count)? _no_data_ : _has_data_];
}

    


-(id)pop{ //if return nil. means stop
    
    id obj = nil; 
    
    do {
        
        while(NO == [_condionLock lockWhenCondition:_has_data_ beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]){
            if(YES == _isStop)
                return nil; //this nil means stope
        }
        
        
        
        if (NO == _isStop) {
            for(linkedListOnThread* list in _queueList){
                
                if(YES == _isStop)//verify it second time
                    break;
                
                if(0 != [list count]){
                    obj = [list popFirstObject];
                    
                    if(nil != obj){
                        _count = _count - 1;
                        break;
                    }
                    
                    
                }
            }
            

        }
        
        
        assert(_count >= 0);
        [_condionLock unlockWithCondition:(YES == _isStop ||  0 != _count)? _has_data_ : _no_data_ ];
        
        pthread_yield_np();
        
        
        //if a thread called the 'clearAll' or 'clearWithPriority' fun.
        //the num of object in queue had changed, but the '_count' and "lock's condition" will mantain
        //the old value. until the that thread get the lock. so, '[list popFirstObject]' will return
        //nil(no element in list)
    }while(NO == _isStop  &&  nil == obj);
    
    

    
    return obj;
}

-(NSArray*)popAll{
    
    assert(_count >= 0);
    
    NSMutableArray* allObjs = [NSMutableArray arrayWithCapacity:_count];
    
    if(0 == _count)
        return allObjs;
    
        
    while(NO == [_condionLock lockWhenCondition:_has_data_ beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]){
        if(0 == _count ||  YES == _isStop)
            return allObjs;
    }
        
        
        
    if (NO == _isStop) {
        for(linkedListOnThread* list in _queueList){
                
            if(YES == _isStop)//verify it second time
                break;
                
            if(0 != [list count]){
                NSArray* objsInLists = [list popAllObjects];
                assert(nil != objsInLists);
                    
                [allObjs addObjectsFromArray:objsInLists];
                    
                _count -= [objsInLists count];
            }
        
        }
            
    }
        
        
    assert(_count >= 0);
    [_condionLock unlockWithCondition:(YES == _isStop ||  0 != _count)? _has_data_ : _no_data_ ];
        
    
    return allObjs;
}

-(int)numOfPriorityLevel{
    return (int)[_queueList count];
}


-(void)restart{
    _isStop = NO;
}

-(void)terminate:(BOOL)isWait{
    _isStop = YES;
}

//-(void)waitForTerminate{
//    [_condionLock lockWhenCondition:_no_data_];
//    _isStop = YES;
//    [_condionLock unlockWithCondition:_has_data_]; //"_has_data_" wakeup the pop operation immediately
//}


@end
