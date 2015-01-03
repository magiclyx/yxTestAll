//
//  Device.h
//  yxTestAll
//
//  Created by Yuxi Liu on 12/20/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

+ (id)sharedManager;

- (NSString*)CPUArch;

@end




