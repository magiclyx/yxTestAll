//
//  skinManager.h
//  testNavigation
//
//  Created by Yuxi Liu on 6/17/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface skinManager : NSObject

+ (id)sharedManager;

- (UIImage *)imageByName:(NSString *)name;

@end
