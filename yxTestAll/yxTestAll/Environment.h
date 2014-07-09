//
//  Environment.h
//  testNavigation
//
//  Created by Yuxi Liu on 6/17/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Environment : NSObject

+ (id)sharedManager;
- (BOOL) isIPhone5;

@end
