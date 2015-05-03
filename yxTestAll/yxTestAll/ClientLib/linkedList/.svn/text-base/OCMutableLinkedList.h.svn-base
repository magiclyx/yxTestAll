//
//  OCMutableLinkedList.h
//  ClientLib
//
//  Created by Yuxi Liu on 7/4/13.
//
//

#import <Foundation/Foundation.h>

@class OCMutableLinkedListNode;
@interface OCMutableLinkedList : NSObject{
    OCMutableLinkedListNode* _pHead;
    OCMutableLinkedListNode* _pTail;
    
    NSUInteger _count;
    
    @private
    unsigned long long _operationSeed;
}


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


//enum
-(NSEnumerator *)objectEnumerator;//pass
-(NSEnumerator *)reverseObjectEnumerator;//pass

//file
-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
- (BOOL)writeToURL:(NSURL *)aURL atomically:(BOOL)flag;


@end

@interface OCMutableLinkedList(FastEnum)<NSFastEnumeration>
@end

@interface OCMutableLinkedList(CopyWithZone)<NSCopying>
@end

@interface OCMutableLinkedList(MutableCopyWithZone)<NSMutableCopying>
@end

