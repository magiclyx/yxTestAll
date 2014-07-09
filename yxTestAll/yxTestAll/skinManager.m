//
//  skinManager.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/17/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "skinManager.h"
#import "Environment.h"

@implementation skinManager

+ (id)sharedManager
{
    static dispatch_once_t  onceToken;
    static id sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}


- (UIImage *)imageByName:(NSString *)name{
    
    if (nil == name)
        return nil;
    
    if([[Environment sharedManager] isIPhone5]){
        name = [name stringByAppendingString:@"@1096"];
    }
    else{
        name = [name stringByAppendingString:@"@920"];
    }
    
    UIImage* image = [UIImage imageNamed:name];
    
    return image;
}

@end
