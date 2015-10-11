//
//  OCMutableLinkedList.m
//  ClientLib
//
//  Created by Yuxi Liu on 7/4/13.
//
//

#import "OCMutableLinkedList.h"


static const unsigned long long max_operation_seed = 99999999;



@interface OCMutableLinkedListNode : NSObject{
    id obj;
    OCMutableLinkedListNode* pNext;
    OCMutableLinkedListNode* pPre;
}

@property(readwrite, retain) id obj;
@property(readwrite, assign) OCMutableLinkedListNode* pNext;
@property(readwrite, assign) OCMutableLinkedListNode* pPre;

+(id)nodeWithObject:(id)anObject;
-(id)initWithObject:(id)anObject;


-(NSString *)description;
-(BOOL)isEqual:(id)object;

-(void)linkNodeAfter:(OCMutableLinkedListNode*)aNode;
-(void)linkNodeFront:(OCMutableLinkedListNode*)aNode;
-(void)unlink;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


//just implemented nextObject
@interface linkedListEnumerator : NSEnumerator{
    OCMutableLinkedListNode* _nextNode;
    BOOL _isReserve;
}

@property(readwrite, assign) OCMutableLinkedListNode* nextNode;
@property(readwrite, assign) BOOL isReserve;

@end



////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface OCMutableLinkedList()
-(void)_nextOperationSeed;
-(OCMutableLinkedListNode*)_head;
-(OCMutableLinkedListNode*)_tail;

@end

@implementation OCMutableLinkedList

-(void)dealloc{
    [self removeAllObjects];
    
    [super dealloc];
}

-(id)copy{
    return [self copyWithZone:[self zone]];
}

-(id)mutableCopy{
    return  [self mutableCopyWithZone:[self zone]];
}

-(BOOL)isEqual:(id)object{
    return [self isEqualToLinkedList:object];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


-(id)copyWithZone:(NSZone *)zone{
    return [self retain];
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    OCMutableLinkedList* copy = [[[self class] allocWithZone:zone] initWithLinkedList:self];
    
    return copy;
}



-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len{
    
    int index = 0;
    
    if(state->state == 0)
	{
        //state->mutationsPtr = (unsigned long*)(unsigned long)_operationSeed;
        state->mutationsPtr = (unsigned long*)(&_operationSeed);
        state->extra[0] = (unsigned long)_pHead;
        state->state = 0;
	}
    
    state->itemsPtr = stackbuf;
    
    OCMutableLinkedListNode* curNode = (OCMutableLinkedListNode*)(state->extra[0]);
    while(index < len  &&  nil != curNode){
        stackbuf[index] = [curNode obj];
        
        curNode = [curNode pNext];
        index++;
        state->state++;
    }
    
    state->extra[0] = (unsigned long)curNode;
    
    
    return index;
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


+(id)linkedList{
    return [[[OCMutableLinkedList alloc] init] autorelease];
}
+(id)linkedListWithLinkedList:(OCMutableLinkedList*)anLinkedList{
    return [[[OCMutableLinkedList alloc] initWithLinkedList:anLinkedList] autorelease];
}
+(id)linkedLIstWithArray:(NSArray*)anArray{
    return [[[OCMutableLinkedList alloc] initWithArray:anArray] autorelease];
}

//Initializing an linkedList
-(id)init{
    
    self = [super init];
    if(self){
        _pHead = nil;
        _pTail = nil;
        _count = 0;
        _operationSeed = 0;
    }
    
    return self;
    
}

-(id)initWithLinkedList:(OCMutableLinkedList*)anLinkedList{
    
    assert(nil != anLinkedList);
    
    self = [super init];
    if(self){
        
        _pHead = nil;
        _pTail = nil;
        _count = 0;
        _operationSeed = 0;
        
        OCMutableLinkedListNode* curNode = [anLinkedList _head];
        while (nil != curNode) {
            [self addObjectAtEnd:[curNode obj]];
            curNode = [curNode pNext];
        }
    }
    
    return self;
        
}
-(id)initWithArray:(NSArray*)anArray{
    
    assert(nil != anArray);
    
    self = [super init];
    if(self){
        
        _pHead = nil;
        _pTail = nil;
        _count = 0;
        _operationSeed = 0;
        
        for(id obj in anArray){
            [self addObjectAtEnd:obj];
        }
    }
    
    return self;
}


//modify
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    
    if(index > _count - 1)
        assert(0);//out of range
    
    OCMutableLinkedListNode* curNode = _pHead;
    for(int i=0; i< index; i++)
        curNode = [curNode pNext];
    
    
    [curNode setObj:anObject];
    
}

//add
-(void)addObjectAtFront:(id)anObject{
    
    assert(nil != anObject);
    
    OCMutableLinkedListNode* node = [[OCMutableLinkedListNode alloc] initWithObject:anObject];
    
    if(nil == _pHead){
        assert(0 == _count);
        assert(nil == _pTail);
        _pHead = _pTail = node;
    }
    else{
        assert(nil != _pTail);
        assert(0 != _count);
        
        [_pHead linkNodeFront:node];
        _pHead = node;
    }
    
    _count += 1;
    [self _nextOperationSeed];
}
-(void)addObjectAtEnd:(id)anObject{
    
    assert(nil != anObject);
    
    OCMutableLinkedListNode* node = [[OCMutableLinkedListNode alloc] initWithObject:anObject];
    
    if(nil == _pHead){
        assert(0 == _count);
        assert(nil == _pTail);
        
        _pHead = _pTail = node;
    }
    else{
        assert(nil != _pTail);
        assert(0 != _count);
        
        [_pTail linkNodeAfter:node];
        _pTail = node;
    }
    
    _count += 1; 
    [self _nextOperationSeed];
}

-(void)insertObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    
    if(index > _count - 1)
        assert(0); //the index out of range
    
    if(0 == index){
       [self addObjectAtFront:anObject];
    }
    else if(index == _count - 1){
        [self addObjectAtEnd:anObject];
    }
    else{
        
        OCMutableLinkedListNode* curNode = _pHead;
        for(int i=0; i< index; i++)
            curNode = [curNode pNext];

        OCMutableLinkedListNode* node = [[OCMutableLinkedListNode alloc] initWithObject:anObject]; 
        [curNode linkNodeFront:node];
        _count++;
        [self _nextOperationSeed];
        
    }
    
}


//remove objects
-(void)removeAllObjects{
    OCMutableLinkedListNode* curNode = _pHead;
    while (nil != curNode) {
        OCMutableLinkedListNode* delNode = curNode;
        curNode = [curNode pNext];
        
        [delNode unlink];
        [delNode release];
    }
    
    _pHead = nil;
    _pTail = nil;
    _count = 0;
    [self _nextOperationSeed];
}


-(id)popFirstObject{
    
    assert(nil != _pHead);
    
    id obj = nil;
    
    if(nil != _pHead){
        
        if(1 == _count){
            obj = [_pHead obj];
            [_pHead unlink];
            [_pHead release];
            
            _pHead = _pTail = nil;
        }
        else{
            OCMutableLinkedListNode* node = [_pHead pNext];
            
            obj = [_pHead obj];
            [_pHead unlink];
            [_pHead release];
            
            _pHead = node;
        }
        
        _count--;
        if(0 == _count){
            _pHead = nil;
            _pTail = nil;
        }
        [self _nextOperationSeed];
    }
    
    return obj;
}


-(id)popLastObject{
    assert(nil != _pTail);
    
    id obj = nil;
    
    if(nil != _pTail){
        
        if(1 == _count){
            obj = [_pTail obj];
            [_pTail unlink];
            [_pTail release];
            
            _pHead = _pTail = nil;
        }
        else{
            OCMutableLinkedListNode* node = [_pTail pPre];
            
            obj = [_pTail obj];
            [_pTail unlink];
            [_pTail release];
            
            
            _pTail = node;
        }
        
        _count--;
        if(0 == _count){
            _pHead = nil;
            _pTail = nil;
        }
        [self _nextOperationSeed];
    }
    
    return obj;
}

-(void)removeLastObject{
    [self popLastObject];
}
-(void)removeFirstObject{
    [self popFirstObject];
}
-(int)removeObject:(id)anObject{
    NSMutableArray* removeArr = [[NSMutableArray alloc] init];
    
    OCMutableLinkedListNode* curNode = _pHead;
    @try {
        while (nil != curNode) {
            if(YES == [[curNode obj] isEqual:anObject])
                [removeArr addObject:curNode];
            
            curNode = [curNode pNext];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"->%@", exception);
    }


    
    for(OCMutableLinkedListNode* delNode in removeArr){
        
        if(delNode == _pHead)
            _pHead = [delNode pNext];
        
        if(delNode == _pTail)
            _pTail = [delNode pPre];
        
        [delNode unlink];
        [delNode release];
        
        _count--;
        if(0 == _count){
            _pHead = nil;
            _pTail = nil;
        }
    }
    
    [self _nextOperationSeed];
    
    int rmNum = (int)[removeArr count];
    
    [removeArr release];
    removeArr = nil;
    
    return rmNum;
}
-(void)removeObjectAtIndex:(NSUInteger)index{
    if(index > _count - 1)
        assert(0); //the index out of range
    
    if(0 == index){
        [self removeFirstObject];
    }
    else if(index == _count - 1){
        [self removeLastObject];
    }
    else{
        
        OCMutableLinkedListNode* curNode = _pHead;
        for(int i=0; i< index; i++)
            curNode = [curNode pNext];
        
        [curNode unlink];
        [curNode release];
        
        _count--;
        if(0 == _count){
            _pHead = nil;
            _pTail = nil;
        }
        [self _nextOperationSeed];
        
    }
}
-(void)removeObjectsInLinkedList:(OCMutableLinkedList*)otherLinkedList{
    OCMutableLinkedListNode* curNode = [otherLinkedList _head];
    while (nil != curNode) {
        [self removeObject:[curNode obj]];
        curNode = [curNode pNext];
    }
}
-(void)removeObjectsInArray:(NSArray*)otherArray{
    for(id obj in otherArray){
        [self removeObject:obj];
    }
}


//Querying an linkedList
-(NSUInteger)count{
    return _count;
}
-(BOOL)containsObject:(id)anObject{
    
    BOOL isContain = NO;
    
    OCMutableLinkedListNode* curNode = _pHead;
    while (nil != curNode) {
        if(YES == [[curNode obj] isEqual:anObject]){
            isContain = YES;
            break;
        }
        curNode = [curNode pNext];
    }
    
    return isContain;
}
-(NSString *)description{
    
    NSMutableString* desc = [NSMutableString stringWithString:@"[\r\n"];
    
    OCMutableLinkedListNode* curNode = _pHead;
    while (nil != curNode) {
        [desc appendFormat:@"%@\r\n", curNode];
        curNode = [curNode pNext];
    }
    
    [desc appendFormat:@"]\r\ncount=%ld", (unsigned long)_count];
    
    return desc;
}

-(NSArray*)array{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:_count];
    OCMutableLinkedListNode* curNode = _pHead;
    while (nil != curNode) {
        [array addObject:[curNode obj]];
    }
    
        
    return array;
}

-(NSArray*)popAllObjects{
    
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:_count];
    OCMutableLinkedListNode* curNode = _pHead;
    while (nil != curNode) {
        [array addObject:[curNode obj]];
        
        
        OCMutableLinkedListNode* delNode = curNode;
        curNode = [curNode pNext];
        
        [delNode unlink];
        [delNode release];
    }
    
    _pHead = nil;
    _pTail = nil;
    _count = 0;
    [self _nextOperationSeed];
    
    
    return array;
}


//Finding Objects in an linkedList
-(NSUInteger)indexOfObject:(id)anObject{
    
    NSUInteger index = NSNotFound;
    
    
    OCMutableLinkedListNode* curNode = _pHead;
    for(int i = 0;  i < _count;  i++){
        
        if(YES == [[curNode obj] isEqual:anObject]){
            index = i;
            break;
        }
        
        curNode = [curNode pNext];
    }
    
    
    return index;
}

-(id)objectAtIndex:(NSUInteger)index{
    OCMutableLinkedListNode* curNode = _pHead;
    for(int i=0; i< index; i++)
        curNode = [curNode pNext];
    
    
    return [curNode obj];
}


//Comparing Arrays
-(BOOL)isEqualToLinkedList:(OCMutableLinkedList*)otherLiknedList{
    BOOL isEqual = YES;
    
    
    OCMutableLinkedListNode* curNode_self = _pHead;
    OCMutableLinkedListNode* curNode_other = [otherLiknedList _head];
    
    while (nil != curNode_self  &&  nil != curNode_other) {
        if(NO == [curNode_self isEqual:curNode_other]){
            isEqual = NO;
            break;
        }
        
        curNode_self = [curNode_self pNext];
        curNode_other = [curNode_other pNext];
    }
    
    
    
    if(nil != curNode_self  ||  nil != curNode_other)
        isEqual = NO;
    
    
    return isEqual;
}


//enum
-(NSEnumerator *)objectEnumerator{
    linkedListEnumerator* enumerator = [[linkedListEnumerator alloc] init];
    [enumerator setNextNode:_pHead];
    [enumerator setIsReserve:NO];
    
    return enumerator;
}

-(NSEnumerator *)reverseObjectEnumerator{
    linkedListEnumerator* enumerator = [[linkedListEnumerator alloc] init];
    [enumerator setNextNode:_pTail];
    [enumerator setIsReserve:YES];
    
    return enumerator;
}

//file
-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag{
    return [[self array] writeToFile:path atomically:flag];
}
- (BOOL)writeToURL:(NSURL *)aURL atomically:(BOOL)flag{
    return [[self array] writeToURL:aURL atomically:flag];
}

//private
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)_nextOperationSeed{
    _operationSeed++;
    if(_operationSeed > max_operation_seed)
        _operationSeed = 1;
}


-(OCMutableLinkedListNode*)_head{
    return _pHead;
}
-(OCMutableLinkedListNode*)_tail{
    return _pTail;
}

@end




@implementation OCMutableLinkedListNode



@synthesize obj;
@synthesize pNext;
@synthesize pPre;




+(id)nodeWithObject:(id)anObject{
    return [[[OCMutableLinkedListNode alloc] initWithObject:anObject] autorelease];
}

-(id)initWithObject:(id)anObject{
    self = [super init];
    
    if(self){
        
        assert(nil != anObject);
        [self setObj:anObject];
        [self setPNext:nil];
        [self setPPre:nil];
    }
    
    return self;
}


-(void)linkNodeAfter:(OCMutableLinkedListNode*)aNode{
    assert(nil != aNode);
    
    OCMutableLinkedListNode* nextNode = [self pNext];
    
    [self setPNext:aNode];
    [aNode setPPre:self];
    
    [aNode setPNext:nextNode];
    [nextNode setPPre:aNode];
}
-(void)linkNodeFront:(OCMutableLinkedListNode*)aNode{
    assert(nil != aNode);
    
    OCMutableLinkedListNode* preNode = [self pPre];
    
    [preNode setPNext:aNode];
    [aNode setPPre:preNode];
    
    [aNode setPNext:self];
    [self setPPre:aNode];
}

-(void)unlink{
    OCMutableLinkedListNode* preNode = [self pPre];
    OCMutableLinkedListNode* nextNode = [self pNext];
    
    [preNode setPNext:nextNode];
    [nextNode setPPre:preNode];
    
    [self setPPre:nil];
    [self setPNext:nil];
}

-(NSString *)description{
    return [[self obj] description];
}


-(BOOL)isEqual:(id)object{
    BOOL isEqual = NO;
    
    if(self == object  ||  (YES == [object isKindOfClass:[OCMutableLinkedListNode class]]  &&  YES == [[self obj] isEqual:[((OCMutableLinkedListNode*)object) obj]]))
        isEqual = YES;
    
    return isEqual;
}

-(void)dealloc{
    
    [self setObj:nil];
    
    [super dealloc];
}

@end



@implementation linkedListEnumerator

@synthesize nextNode = _nextNode;
@synthesize isReserve = _isReserve;

-(id)init{
    self = [super init];
    if(self){
        _nextNode = nil;
        _isReserve = NO;
    }
    
    return self;
}

-(id)nextObject{
    
    if(nil == _nextNode)
        return nil;
    
    id obj = [_nextNode obj];
    
    
    if(YES == _isReserve)
        _nextNode = [_nextNode pPre];
    else
        _nextNode = [_nextNode pNext];
    
    return obj;
}

@end



