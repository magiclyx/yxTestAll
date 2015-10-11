//
//  linkedListOnThread.h
//  ClientLib
//
//  Created by Yuxi Liu on 7/4/13.
//
//

#import <Foundation/Foundation.h>
#import <pthread.h>

#import "OCMutableLinkedList.h"

@interface linkedListOnThread : NSObject{
    @private
    OCMutableLinkedList* _list;
    pthread_rwlock_t _rwl;
}

//kernel array
-(void)lockForRead; //must use for the OCMutableLinkedList returned by "kernelList" function
-(void)lockFroWrite; //must use for the OCMutableLinkedList returned by "kernelList" function
-(void)unlock; //must use for the OCMutableLinkedList returned by "kernelList" function
-(OCMutableLinkedList*)kernelList;




+(id)linkedList;
+(id)linkedListWithLinkedList:(OCMutableLinkedList*)anLinkedList;
+(id)linkedLIstWithArray:(NSArray*)anArray;

//Initializing an linkedList
-(id)init;
-(id)initWithLinkedList:(OCMutableLinkedList*)anLinkedList;
-(id)initWithArray:(NSArray*)anArray;

//modify
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;//pass

//add
-(void)addObjectAtFront:(id)anObject;//pass
-(void)addObjectAtEnd:(id)anObject;//pass

-(void)insertObjectAtIndex:(NSUInteger)index withObject:(id)anObject;//pass

//pop

-(id)popFirstObject;
-(id)popLastObject;
-(NSArray*)popAllObjects;

//remove objects
-(void)removeAllObjects; //pass
-(void)removeLastObject; //pass
-(void)removeFirstObject; //pass
-(int)removeObject:(id)anObject; //pass
-(void)removeObjectAtIndex:(NSUInteger)index; //pass
-(void)removeObjectsInLinkedList:(OCMutableLinkedList*)otherLinkedList;
-(void)removeObjectsInArray:(NSArray*)otherArray;


//Querying an linkedList
-(NSUInteger)count;//pass
-(BOOL)containsObject:(id)anObject; //pass
-(NSString *)description;//pass
-(NSArray*)array;


//Finding Objects in an linkedList
-(NSUInteger)indexOfObject:(id)anObject;//pass
-(id)objectAtIndex:(NSUInteger)index;//pass


//Comparing Arrays
-(BOOL)isEqualToLinkedList:(OCMutableLinkedList*)otherLiknedList;


//file
-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
- (BOOL)writeToURL:(NSURL *)aURL atomically:(BOOL)flag;


@end

@interface linkedListOnThread(FastEnum)<NSFastEnumeration>
@end

@interface linkedListOnThread(CopyWithZone)<NSCopying>
@end

@interface linkedListOnThread(MutableCopyWithZone)<NSMutableCopying>
@end
