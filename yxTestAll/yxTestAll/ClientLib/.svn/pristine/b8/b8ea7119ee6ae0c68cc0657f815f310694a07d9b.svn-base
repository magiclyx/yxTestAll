//
//  queue.h
//  ClientLib
//
//  Created by Yuxi Liu on 7/4/13.
//
//

#import <Foundation/Foundation.h>
#import <pthread.h>

//dangerous. not...verify...deadlock...

@interface queue : NSObject{
    NSUInteger _count;
    
    @private
    NSArray* _queueList;
    NSConditionLock* _condionLock;
    BOOL _isStop;
}

-(id)init; 
-(id)initWithNumOfPriorityLevel:(int)num;


-(void)pushObjectAtFront:(id)obj;
-(void)pushObjectAtEnd:(id)obj;

-(void)pushObjectAtFront:(id)obj withPriority:(int)priority;
-(void)pushObjectAtEnd:(id)obj withPriority:(int)priority;

-(void)moveObjectAtFront:(id)obj withPriority:(int)priority;
-(void)moveObjectAtEnd:(id)obj withPriority:(int)priority;

-(void)clearWithPriority:(int)priority;
-(void)clearAll;

-(id)pop; //if return nil. means stop
-(NSArray*)popAll;
-(int)numOfPriorityLevel;

-(void)restart;
-(void)terminate:(BOOL)isWait;



@property(readonly, assign, atomic) NSUInteger count;

@end
