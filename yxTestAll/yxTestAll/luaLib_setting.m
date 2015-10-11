//
//  luaLib_setting.m
//  yxTestAll
//
//  Created by LiuYuxi on 15/5/21.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import "luaLib_setting.h"

@implementation luaLib_setting

- (bool)luaLib_test:(id)obj
{
    NSLog(@"luaLib_test");
    NSLog(@"%@", [obj class]);
    
    return true;
}


@end
