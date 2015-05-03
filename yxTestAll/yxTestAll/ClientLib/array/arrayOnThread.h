//
//  arrayOnThread.h
//  ClientLib
//
//  Created by Yuxi Liu on 7/3/13.
//
//

#import <Foundation/Foundation.h>
#import <pthread.h>


/*
 arrayOnThread just using for debug
 
 NSArray is thread-safe
*/


@interface arrayOnThread : NSObject{
    @private
    NSMutableArray* _array;
    pthread_rwlock_t _rwl;
}

//kernel array
-(void)lockForRead; //must use for the NSMutableArray returned by "kernelArray" function
-(void)lockFroWrite; //must use for the NSMutableArray returned by "kernelArray" function
-(void)unlock; //must use for the NSMutableArray returned by "kernelArray" function
-(NSMutableArray*)kernelArray;

//Creating an Array
+(id)array;
+(id)arrayWithArray:(NSArray*)anArray;
+(id)arrayWithCapacity:(NSUInteger)numItems;

//Initializing an Array
-(id)init;
-(id)initWithCapacity:(NSUInteger)numItems;
-(id)initWithArray:(NSArray*)anArray;


//modify
-(void)setArray:(NSArray*)otherArray;
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

-(void)addObject:(id)obj;
-(void)addObjectsFromArray:(NSArray *)otherArray;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

//Querying an Array
-(NSUInteger)count;
-(BOOL)containsObject:(id)anObject;
-(NSString *)description;

//Finding Objects in an Array
-(NSUInteger)indexOfObject:(id)anObject;

//Comparing Arrays
-(id)firstObjectCommonWithArray:(NSArray *)otherArray;
-(BOOL)isEqualToArray:(NSArray *)otherArray;


//remove objects
-(void)removeAllObjects;
-(void)removeLastObject;
-(void)removeObject:(id)anObject;
-(void)removeObjectAtIndex:(NSUInteger)index;
-(void)removeObjectsInArray:(NSArray*)otherArray;

//sort
-(void)sortUsingComparator:(NSComparator)cmptr;
-(void)sortUsingDescriptors:(NSArray *)sortDescriptors;

@end

@interface arrayOnThread(FastEnum)<NSFastEnumeration>
@end

@interface arrayOnThread(CopyWithZone)<NSCopying>
@end

@interface arrayOnThread(MutableCopyWithZone)<NSMutableCopying>
@end
