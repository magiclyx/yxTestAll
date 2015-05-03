//
//  NSNumber_luaEngine.h
//  luaEngine
//
//  Created by Yuxi Liu on 9/24/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "./lua/lua.h"
#import "./lua/lualib.h"
#import "./lua/lauxlib.h"


void luadebug_stack(lua_State *L);
NSString* luadebug_stackInfo(lua_State *L);



@protocol luaBinding <NSObject>

@required
-(void) pushValue:(lua_State*)luaRTContext;
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx;

@end


@interface NSObject (luaEngine)<luaBinding>
-(void) pushValue:(lua_State*)luaRTContext;
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx;
@end



@interface NSNumber (luaEngine)<luaBinding>
-(void) pushValue:(lua_State*)luaRTContext;
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx;
@end


@interface NSString (luaEngine)<luaBinding>
-(void) pushValue:(lua_State*)luaRTContext;
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx;
@end


@interface NSArray (luaEngine)<luaBinding>
-(void) pushValue:(lua_State*)luaRTContext;
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx;
@end





@interface NSDictionary (luaEngine)<luaBinding>
-(id) autoGet :(lua_State*)luaRTContext :(int)idx;
-(void) pushValue:(lua_State*)luaRTContext;
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx; //this is ugly, NSDictionary may return an array here !!!!
@end




@interface NSNull (luaEngine)<luaBinding>
-(void) pushValue:(lua_State*)luaRTContext;
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx;
@end




