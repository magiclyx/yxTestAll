//
//  arrayOnThread.m
//  ClientLib
//
//  Created by Yuxi Liu on 7/3/13.
//
//

#import "arrayOnThread.h"

@implementation arrayOnThread



-(void)dealloc{
    [_array release];
    _array = nil;
    
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
    
    arrayOnThread* theCopy;
    
    pthread_rwlock_rdlock(&_rwl);
    theCopy = [[[self class] allocWithZone:zone] initWithArray:_array];
    pthread_rwlock_unlock(&_rwl);
    
    return theCopy;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len{
    
    NSUInteger rtVal;
    
    if(0 == state->state &&  0 == state->itemsPtr  &&  0 == state->itemsPtr  && 0 == state->extra[0])
        pthread_rwlock_rdlock(&_rwl);
    
    rtVal = [_array countByEnumeratingWithState:state objects:stackbuf count:len];
    
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
-(NSMutableArray*)kernelArray{
    return _array;
}

//Creating an Array
+(id)array{
    return [[[arrayOnThread alloc] init] autorelease];
}
+(id)arrayWithArray:(NSArray*)anArray{
    return [[[arrayOnThread alloc] initWithArray:anArray] autorelease];
}
+(id)arrayWithCapacity:(NSUInteger)numItems{
    return [[[arrayOnThread alloc] initWithCapacity:numItems] autorelease];
}

//Initializing an Array
-(id)init{
    self = [super init];
    if(self){
        _array = [[NSMutableArray alloc] init];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}

-(id)initWithCapacity:(NSUInteger)numItems{
    self = [super init];
    if(self){
        _array = [[NSMutableArray alloc] initWithCapacity:numItems];
        pthread_rwlock_init(&_rwl, NULL); 
    }
    
    return self;
}
-(id)initWithArray:(NSArray*)anArray{
    
    self = [super init];
    if(self){
        _array = [[NSMutableArray alloc] initWithArray:anArray];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}


//modify
-(void)setArray:(NSArray*)otherArray{
    pthread_rwlock_wrlock(&_rwl);
    [_array setArray:otherArray];
    pthread_rwlock_unlock(&_rwl);
}
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    pthread_rwlock_wrlock(&_rwl);
    [_array replaceObjectAtIndex:index withObject:anObject];
    pthread_rwlock_unlock(&_rwl);
}

-(void)addObject:(id)obj{
    pthread_rwlock_wrlock(&_rwl);
    [_array addObject:obj];
    pthread_rwlock_unlock(&_rwl);
}
-(void)addObjectsFromArray:(NSArray *)otherArray{
    pthread_rwlock_wrlock(&_rwl);
    [_array addObjectsFromArray:otherArray];
    pthread_rwlock_unlock(&_rwl);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index{
    pthread_rwlock_wrlock(&_rwl);
    [_array insertObject:anObject atIndex:index];
    pthread_rwlock_unlock(&_rwl);
}

//Querying an Array
-(NSUInteger)count{
    NSUInteger ct;
    pthread_rwlock_rdlock(&_rwl);
    ct = [_array count];
    pthread_rwlock_unlock(&_rwl);
    
    return ct;
}
-(BOOL)containsObject:(id)anObject{
    BOOL isContain;
    pthread_rwlock_rdlock(&_rwl);
    isContain = [_array containsObject:anObject];
    pthread_rwlock_unlock(&_rwl);
    
    return isContain;
}
-(NSString *)description{
    NSString* des;
    pthread_rwlock_rdlock(&_rwl);
    des = [_array description];
    pthread_rwlock_unlock(&_rwl);
    
    return des;
}




//Finding Objects in an Array
-(NSUInteger)indexOfObject:(id)anObject{
    NSUInteger index;
    pthread_rwlock_rdlock(&_rwl);
    index = [_array indexOfObject:anObject];
    pthread_rwlock_unlock(&_rwl);
    
    return index;
}




//Comparing Arrays
-(id)firstObjectCommonWithArray:(NSArray *)otherArray{
    id obj;
    pthread_rwlock_rdlock(&_rwl);
    obj = [_array firstObjectCommonWithArray:otherArray];
    pthread_rwlock_unlock(&_rwl);
    
    return obj;
}
-(BOOL)isEqualToArray:(NSArray *)otherArray{
    BOOL isEqual;
    pthread_rwlock_rdlock(&_rwl);
    isEqual = [_array isEqualToArray:otherArray];
    pthread_rwlock_unlock(&_rwl);
    
    return isEqual;
}


//remove objects
-(void)removeAllObjects{
    pthread_rwlock_wrlock(&_rwl);
    [_array removeAllObjects];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeLastObject{
    pthread_rwlock_wrlock(&_rwl);
    [_array removeLastObject];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeObject:(id)anObject{
    pthread_rwlock_wrlock(&_rwl);
    [_array removeObject:anObject];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeObjectAtIndex:(NSUInteger)index{
    pthread_rwlock_wrlock(&_rwl);
    [_array removeObjectAtIndex:index];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeObjectsInArray:(NSArray*)otherArray{
    pthread_rwlock_wrlock(&_rwl);
    [_array removeObjectsInArray:otherArray];
    pthread_rwlock_unlock(&_rwl);
}

//sort
-(void)sortUsingComparator:(NSComparator)cmptr{
    pthread_rwlock_wrlock(&_rwl);
    [_array sortUsingComparator:cmptr];
    pthread_rwlock_unlock(&_rwl);
}
-(void)sortUsingDescriptors:(NSArray *)sortDescriptors{
    pthread_rwlock_wrlock(&_rwl);
    [_array sortUsingDescriptors:sortDescriptors];
    pthread_rwlock_unlock(&_rwl);
}

@end
