//
//  linkedListOnThread.m
//  ClientLib
//
//  Created by Yuxi Liu on 7/4/13.
//
//

#import "linkedListOnThread.h"

@implementation linkedListOnThread



-(void)dealloc{
    [_list release];
    _list = nil;
    
    pthread_rwlock_destroy(&_rwl);
    
    [super dealloc];
}

-(id)copy{
    return [self copyWithZone:[self zone]];
}


-(id)mutableCopy{
    return [self mutableCopyWithZone:[self zone]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)copyWithZone:(NSZone *)zone{
    return [self retain];
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    
    linkedListOnThread*  theCopy;
    
    pthread_rwlock_rdlock(&_rwl);
    theCopy = [[[self class] allocWithZone:zone] initWithLinkedList:_list];
    pthread_rwlock_unlock(&_rwl);
    
    return theCopy;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len{
    
    NSUInteger rtVal;
    
    if(0 == state->state &&  0 == state->itemsPtr  &&  0 == state->itemsPtr  && 0 == state->extra[0])
        pthread_rwlock_rdlock(&_rwl);
    
    rtVal = [_list countByEnumeratingWithState:state objects:stackbuf count:len];
    
    if(0 == rtVal)
        pthread_rwlock_unlock(&_rwl);
    
    
    return rtVal;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////



//kernel array
-(void)lockForRead{
    pthread_rwlock_rdlock(&_rwl);
}
-(void)lockFroWrite{
    pthread_rwlock_wrlock(&_rwl);
}
-(void)unlock{
    pthread_rwlock_unlock(&_rwl);
}
-(OCMutableLinkedList*)kernelList{
    return _list;
}




+(id)linkedList{
    return [[[linkedListOnThread alloc] init] autorelease];
}
+(id)linkedListWithLinkedList:(OCMutableLinkedList*)anLinkedList{
    return [[[linkedListOnThread alloc] initWithLinkedList:anLinkedList] autorelease];
}
+(id)linkedLIstWithArray:(NSArray*)anArray{
    return [[[linkedListOnThread alloc] initWithArray:anArray] autorelease];
}

//Initializing an linkedList
-(id)init{
    self = [super init];
    if(self){
        _list = [[OCMutableLinkedList alloc] init];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}
-(id)initWithLinkedList:(OCMutableLinkedList*)anLinkedList{
    
    self = [super init];
    if(self){
        _list = [[OCMutableLinkedList alloc] initWithLinkedList:anLinkedList];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}
-(id)initWithArray:(NSArray*)anArray{
    
    self = [super init];
    if(self){
        _list = [[OCMutableLinkedList alloc] initWithArray:anArray];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}

//modify
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    pthread_rwlock_rdlock(&_rwl);
    [_list replaceObjectAtIndex:index withObject:anObject];
    pthread_rwlock_unlock(&_rwl);
}

//add
-(void)addObjectAtFront:(id)anObject{
    pthread_rwlock_wrlock(&_rwl);
    [_list addObjectAtFront:anObject];
    pthread_rwlock_unlock(&_rwl);
}
-(void)addObjectAtEnd:(id)anObject{
    pthread_rwlock_wrlock(&_rwl);
    [_list addObjectAtEnd:anObject];
    pthread_rwlock_unlock(&_rwl);
}

-(void)insertObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    pthread_rwlock_wrlock(&_rwl);
    [_list insertObjectAtIndex:index withObject:anObject];
    pthread_rwlock_unlock(&_rwl);
}

//pop
-(id)popFirstObject{
    id obj;
    
    pthread_rwlock_wrlock(&_rwl);
    obj = [_list popFirstObject];
    pthread_rwlock_unlock(&_rwl);
    
    return obj;
}
-(id)popLastObject{
    id obj;
    
    pthread_rwlock_wrlock(&_rwl);
    obj = [_list popLastObject];
    pthread_rwlock_unlock(&_rwl);
    
    return obj;
}

-(NSArray*)popAllObjects{
    NSArray* allObj;
    
    pthread_rwlock_wrlock(&_rwl);
    allObj = [_list popAllObjects];
    pthread_rwlock_unlock(&_rwl);
    
    return allObj;
}

//remove objects
-(void)removeAllObjects{
    pthread_rwlock_wrlock(&_rwl);
    [_list removeAllObjects];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeLastObject{
    pthread_rwlock_wrlock(&_rwl);
    [_list removeLastObject];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeFirstObject{
    pthread_rwlock_wrlock(&_rwl);
    [_list removeFirstObject];
    pthread_rwlock_unlock(&_rwl);
}
-(int)removeObject:(id)anObject{
    int rmNum;
    pthread_rwlock_wrlock(&_rwl);
    rmNum = [_list removeObject:anObject];
    pthread_rwlock_unlock(&_rwl);
    
    return rmNum;
}
-(void)removeObjectAtIndex:(NSUInteger)index{
    pthread_rwlock_wrlock(&_rwl);
    [_list removeObjectAtIndex:index];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeObjectsInLinkedList:(OCMutableLinkedList*)otherLinkedList{
    pthread_rwlock_wrlock(&_rwl);
    [_list removeObjectsInLinkedList:otherLinkedList];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeObjectsInArray:(NSArray*)otherArray{
    pthread_rwlock_wrlock(&_rwl);
    [_list removeObjectsInArray:otherArray];
    pthread_rwlock_unlock(&_rwl);
}


//Querying an linkedList
-(NSUInteger)count{
    NSUInteger ct;
    pthread_rwlock_rdlock(&_rwl);
    ct = [_list count];
    pthread_rwlock_unlock(&_rwl);
    
    return ct;
}
-(BOOL)containsObject:(id)anObject{
    BOOL isContains;
    pthread_rwlock_rdlock(&_rwl);
    isContains = [_list containsObject:anObject];
    pthread_rwlock_unlock(&_rwl);
    
    return isContains;
}
-(NSString *)description{
    NSString* des;
    
    pthread_rwlock_rdlock(&_rwl);
    des = [_list description];
    pthread_rwlock_unlock(&_rwl);
    
    return des;
}
-(NSArray*)array{
    NSArray* arr;
    
    pthread_rwlock_rdlock(&_rwl);
    arr = [_list array];
    pthread_rwlock_unlock(&_rwl);
    
    return arr;
}


//Finding Objects in an linkedList
-(NSUInteger)indexOfObject:(id)anObject{
    NSUInteger index;
    pthread_rwlock_rdlock(&_rwl);
    index = [_list indexOfObject:anObject];
    pthread_rwlock_unlock(&_rwl);
    
    return index;
}
-(id)objectAtIndex:(NSUInteger)index{
    id obj;
    pthread_rwlock_rdlock(&_rwl);
    obj = [_list objectAtIndex:index];
    pthread_rwlock_unlock(&_rwl);
    
    return obj;
}


//Comparing Arrays
-(BOOL)isEqualToLinkedList:(OCMutableLinkedList*)otherLiknedList{
    BOOL isEual;
    
    pthread_rwlock_rdlock(&_rwl);
    isEual = [_list isEqualToLinkedList:otherLiknedList];
    pthread_rwlock_unlock(&_rwl);
    
    return isEual;
}


//file
-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag{
    BOOL isSuccess;
    
    pthread_rwlock_rdlock(&_rwl);
    isSuccess = [_list writeToFile:path atomically:flag];
    pthread_rwlock_unlock(&_rwl);
    
    return isSuccess;
}
- (BOOL)writeToURL:(NSURL *)aURL atomically:(BOOL)flag{
    BOOL isSuccess;
    
    pthread_rwlock_rdlock(&_rwl);
    isSuccess = [_list writeToURL:aURL atomically:flag];
    pthread_rwlock_unlock(&_rwl);
    
    return isSuccess;
}




@end
