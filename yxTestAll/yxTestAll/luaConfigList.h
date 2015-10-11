//
//  luaConfigList.h
//  yxTestAll
//
//  Created by LiuYuxi on 15/5/3.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class luaConfigList;


@protocol luaConfigListDelegate <NSObject>

- (void)configList:(luaConfigList*)list didSelectScript:(NSString*)scriptPath inTable:(UITableView*)table;

@end

@interface luaConfigList : UIViewController

@property(readwrite, assign, nonatomic) id<luaConfigListDelegate> delegate;
@end
