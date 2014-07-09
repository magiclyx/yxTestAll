//
//  Environment.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/17/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "Environment.h"

@implementation Environment

+ (id)sharedManager
{
    static dispatch_once_t  onceToken;
    static id sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (BOOL) isIPhone5{
    static dispatch_once_t  onceToken;
    static NSNumber* isIphone5; //BOOL
    
    dispatch_once(&onceToken, ^{
        isIphone5 = [NSNumber numberWithBool:(([[UIScreen mainScreen] bounds].size.height == 568)? YES : NO)];
        
    });
    
    return isIphone5.boolValue;
}

@end
