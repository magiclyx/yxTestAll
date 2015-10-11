//
//  luaEngineManager_oc.h
//  yxTestAll
//
//  Created by LiuYuxi on 15/5/13.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUInteger luaEngineInvalidateIdentifer;

@class luaEngine_oc;
@interface luaEngineManager_oc : NSObject

+ (instancetype)sharedManager;
+ (luaEngine_oc*)engineWithIdentifier:(NSUInteger)identifier;


- (luaEngine_oc*)getEngineWithIdentifier:(NSUInteger)identifier;
- (luaEngine_oc*)getEngineWithEngineName:(NSString*)engineName; //low performance

- (NSUInteger)registEngine:(luaEngine_oc*)engine;
- (void)unRegistEngine:(NSUInteger)identifier;

@end
