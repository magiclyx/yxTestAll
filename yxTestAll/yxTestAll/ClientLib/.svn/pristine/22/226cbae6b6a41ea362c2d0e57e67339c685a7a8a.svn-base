//
//  dictionaryOnThread.m
//  ClientLib
//
//  Created by Yuxi Liu on 7/3/13.
//
//dictionaryOnThread* copy

#import "dictionaryOnThread.h"

@implementation dictionaryOnThread


-(void)dealloc{
    [_dict release];
    _dict = nil;
    
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
    dictionaryOnThread* theCopy;
    
    pthread_rwlock_rdlock(&_rwl);
    theCopy = [[[self class] allocWithZone:zone] initWithDictionary:_dict];
    pthread_rwlock_unlock(&_rwl);
    
    return theCopy;
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
-(NSMutableDictionary*)kernelDictionary{
    return _dict;
}

//Creating a Dictionary
+(id)dictionary{
    return [[[dictionaryOnThread alloc] init] autorelease];
}
+(id)dictionaryWithContentsOfFile:(NSString *)path{
    return [[[dictionaryOnThread alloc] initWithContentsOfFile:path] autorelease];
}
+(id)dictionaryWithContentsOfURL:(NSURL *)aURL{
    return [[[dictionaryOnThread alloc] initWithContentsOfURL:aURL] autorelease];
}
+(id)dictionaryWithDictionary:(NSDictionary *)otherDictionary{
    return [[[dictionaryOnThread alloc] initWithDictionary:otherDictionary] autorelease];
}
+(id)dictionaryWithCapacity:(NSUInteger)numItems{
    return [[[dictionaryOnThread alloc] initWithCapacity:numItems] autorelease];
}


-(id)init{
    self = [super init];
    if(self){
        _dict = [[NSMutableDictionary alloc] init];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}
-(id)initWithContentsOfFile:(NSString *)path{
    self = [super init];
    if(self){
        _dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}
-(id)initWithContentsOfURL:(NSURL *)aURL{
    self = [super init];
    if(self){
        _dict = [[NSMutableDictionary alloc] initWithContentsOfURL:aURL];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}
-(id)initWithDictionary:(NSDictionary *)otherDictionary{
    self = [super init];
    if(self){
        _dict = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}
-(id)initWithCapacity:(NSUInteger)numItems{
    self = [super init];
    if(self){
        _dict = [[NSMutableDictionary alloc] initWithCapacity:numItems];
        pthread_rwlock_init(&_rwl, NULL);
    }
    
    return self;
}

//Counting Entries
-(NSUInteger)count{
    NSUInteger ct;
    pthread_rwlock_rdlock(&_rwl);
    ct = [_dict count];
    pthread_rwlock_unlock(&_rwl);
    
    return ct;
}


//Comparing Dictionaries
-(BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary{
    BOOL isEqual;
    pthread_rwlock_rdlock(&_rwl);
    isEqual = [_dict isEqualToDictionary:otherDictionary];
    pthread_rwlock_unlock(&_rwl);
    
    return isEqual;
}


//Adding Entries to a Mutable Dictionary
-(void)setObject:(id)anObject forKey:(id < NSCopying >)aKey{
    pthread_rwlock_wrlock(&_rwl);
    [_dict setObject:anObject forKey:aKey];
    pthread_rwlock_unlock(&_rwl);
}
-(void)addEntriesFromDictionary:(NSDictionary *)otherDictionary{
    pthread_rwlock_wrlock(&_rwl);
    [_dict addEntriesFromDictionary:otherDictionary];
    pthread_rwlock_unlock(&_rwl);
}
-(void)setDictionary:(NSDictionary *)otherDictionary{
    pthread_rwlock_wrlock(&_rwl);
    [_dict setDictionary:otherDictionary];
    pthread_rwlock_unlock(&_rwl);
}


//Removing Entries From a Mutable Dictionary
-(void)removeObjectForKey:(id)aKey{
    pthread_rwlock_wrlock(&_rwl);
    [_dict removeObjectForKey:aKey];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeAllObjects{
    pthread_rwlock_wrlock(&_rwl);
    [_dict removeAllObjects];
    pthread_rwlock_unlock(&_rwl);
}
-(void)removeObjectsForKeys:(NSArray *)keyArray{
    pthread_rwlock_wrlock(&_rwl);
    [_dict removeObjectForKey:keyArray];
    pthread_rwlock_unlock(&_rwl);
}



//Accessing Keys and Values
-(NSArray *)allKeys{
    NSArray* keys;
    
    pthread_rwlock_rdlock(&_rwl);
    keys = [_dict allKeys];
    pthread_rwlock_unlock(&_rwl);
    
    return keys;
}
-(NSArray *)allKeysForObject:(id)anObject{
    NSArray* keys;
    
    pthread_rwlock_rdlock(&_rwl);
    keys = [_dict allKeysForObject:anObject];
    pthread_rwlock_unlock(&_rwl);
    
    return keys;
}
-(NSArray *)allValues{
    NSArray* values;
    
    pthread_rwlock_rdlock(&_rwl);
    values = [_dict allValues];
    pthread_rwlock_unlock(&_rwl);
    
    return values;
}
-(id)objectForKey:(id)aKey{
    
    id obj;
    
    pthread_rwlock_rdlock(&_rwl);
    obj = [_dict objectForKey:aKey];
    pthread_rwlock_unlock(&_rwl);
    
    return obj;
}



//sorting Dictionary
-(NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr{
    NSArray* sorted;
    
    pthread_rwlock_rdlock(&_rwl);
    sorted = [_dict keysSortedByValueUsingComparator:cmptr];
    pthread_rwlock_unlock(&_rwl);
    
    return sorted;
}
-(NSArray *)keysSortedByValueUsingSelector:(SEL)comparator{
    NSArray* sorted;
    
    pthread_rwlock_rdlock(&_rwl);
    sorted = [_dict keysSortedByValueUsingSelector:comparator];
    pthread_rwlock_unlock(&_rwl);
    
    return sorted;
}
-(NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr{
    NSArray* sorted;
    
    pthread_rwlock_rdlock(&_rwl);
    sorted = [_dict keysSortedByValueWithOptions:opts usingComparator:cmptr];
    pthread_rwlock_unlock(&_rwl);
    
    return sorted;
}

//Storing Dictionaries
-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag{
    BOOL isSuccess;
    
    pthread_rwlock_rdlock(&_rwl);
    isSuccess = [_dict writeToFile:path atomically:flag];
    pthread_rwlock_unlock(&_rwl);
    
    return isSuccess;
}
-(BOOL)writeToURL:(NSURL *)aURL atomically:(BOOL)flag{
    BOOL isSuccess;
    
    pthread_rwlock_rdlock(&_rwl);
    isSuccess = [_dict writeToURL:aURL atomically:flag];
    pthread_rwlock_unlock(&_rwl);
    
    return isSuccess;
}


@end
