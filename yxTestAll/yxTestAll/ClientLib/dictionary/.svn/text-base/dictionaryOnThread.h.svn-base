//
//  dictionaryOnThread.h
//  ClientLib
//
//  Created by Yuxi Liu on 7/3/13.
//
//

#import <Foundation/Foundation.h>
#import <pthread.h>

/*
 dictionaryOnThread just using for debug
 
 NSDictionary is thread-safe
 */

@interface dictionaryOnThread : NSObject{
    @private
    NSMutableDictionary* _dict;
    pthread_rwlock_t _rwl;
}


//kernel array
-(void)lockForRead; //must use for the NSMutableDictionary returned by "kernelDictionary" function
-(void)lockFroWrite; //must use for the NSMutableDictionary returned by "kernelDictionary" function
-(void)unlock; //must use for the NSMutableDictionary returned by "kernelDictionary" function
-(NSMutableDictionary*)kernelDictionary;

//Creating a Dictionary
+(id)dictionary;
+(id)dictionaryWithContentsOfFile:(NSString *)path;
+(id)dictionaryWithContentsOfURL:(NSURL *)aURL;
+(id)dictionaryWithDictionary:(NSDictionary *)otherDictionary;
+(id)dictionaryWithCapacity:(NSUInteger)numItems;


-(id)init;
-(id)initWithContentsOfFile:(NSString *)path;
-(id)initWithContentsOfURL:(NSURL *)aURL;
-(id)initWithDictionary:(NSDictionary *)otherDictionary;
-(id)initWithCapacity:(NSUInteger)numItems;

//Counting Entries
-(NSUInteger)count;


//Comparing Dictionaries
-(BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary;


//Adding Entries to a Mutable Dictionary
-(void)setObject:(id)anObject forKey:(id < NSCopying >)aKey;
-(void)addEntriesFromDictionary:(NSDictionary *)otherDictionary;
-(void)setDictionary:(NSDictionary *)otherDictionary;


//Removing Entries From a Mutable Dictionary
-(void)removeObjectForKey:(id)aKey;
-(void)removeAllObjects;
-(void)removeObjectsForKeys:(NSArray *)keyArray;



//Accessing Keys and Values
-(NSArray *)allKeys;
-(NSArray *)allKeysForObject:(id)anObject;
-(NSArray *)allValues;
-(id)objectForKey:(id)aKey;



//sorting Dictionary
-(NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr;
-(NSArray *)keysSortedByValueUsingSelector:(SEL)comparator;
-(NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;

//Storing Dictionaries
-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
-(BOOL)writeToURL:(NSURL *)aURL atomically:(BOOL)flag;


@end

@interface dictionaryOnThread(CopyWithZone)<NSCopying>
@end

@interface dictionaryOnThread(MutableCopyWithZone)<NSMutableCopying>
@end


