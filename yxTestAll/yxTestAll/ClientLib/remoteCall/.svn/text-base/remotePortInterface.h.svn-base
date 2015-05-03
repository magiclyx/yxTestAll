//
//  remotePortInterface.h
//  ClientLib
//
//  Created by Yuxi Liu on 6/28/13.
//
//

#import <Foundation/Foundation.h>

@protocol remotePortInterface <NSObject>
- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond :(int*)err, ... ;
- (int)performRemoteSelectorNoWait:(SEL)aSelector :(int*)err, ...;
- (id)performRemoteSelector:(SEL)aSelector :(int)maxWaitSecond  :(int*)err withPramArr:(NSArray*)params;
@end
