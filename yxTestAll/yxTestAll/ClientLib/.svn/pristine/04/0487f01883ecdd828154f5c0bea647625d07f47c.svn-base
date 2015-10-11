//
//  tt.m
//  luaEngine
//
//  Created by Yuxi Liu on 9/24/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import "basictype_luaEngine.h"


const static NSString* luaEngineArrayDataTypeKey = @"_lua_oc_bridage_array_datatype_";



void luadebug_stack(lua_State *L)
{
    
    printf("stack info: \n");
    int height = lua_gettop(L);
    for(int i=height; i>0; i--)
    {
        switch (lua_type(L, i)) {
            case LUA_TNONE:
                printf("%d, none\n", i);
                break;
            case LUA_TNIL:
                printf("%d, nil\n", i);
                break;
            case LUA_TBOOLEAN:
                printf("%d, boolean  --(%d)\n", i, lua_toboolean(L, i));
                break;
            case LUA_TLIGHTUSERDATA:
                printf("%d, light userdata\n", i);
                break;
            case LUA_TNUMBER:
                printf("%d, number --(%lf)\n", i, lua_tonumber(L, i));
                break;
            case LUA_TSTRING:
                printf("%d, string --(%s)\n", i, lua_tostring(L, i));
                break;
            case LUA_TTABLE:
                printf("%d, table\n", i);
                break;
            case LUA_TFUNCTION:
                printf("%d, function\n", i);
                break;
            case LUA_TUSERDATA:
                printf("%d, userdata\n", i);
                break;
            case LUA_TTHREAD:
                printf("%d, thread\n", i);
                break;
        }
    }
}

NSString* luadebug_stackInfo(lua_State *L){
    
    NSString* str = @"stack info: \n";
    
    int height = lua_gettop(L);
    for(int i=height; i>0; i--)
    {
        switch (lua_type(L, i)) {
            case LUA_TNONE:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, none\n", i]];
                break;
            case LUA_TNIL:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, nil\n", i]];
                break;
            case LUA_TBOOLEAN:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, boolean  --(%d)\n", i, lua_toboolean(L, i)]];
                break;
            case LUA_TLIGHTUSERDATA:
                printf("%d, light userdata\n", i);
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, light userdata\n", i]];
                break;
            case LUA_TNUMBER:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, number --(%lf)\n", i, lua_tonumber(L, i)]];
                break;
            case LUA_TSTRING:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, string --(%s)\n", i, lua_tostring(L, i)]];
                break;
            case LUA_TTABLE:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, table\n", i]];
                break;
            case LUA_TFUNCTION:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, function\n", i]];
                break;
            case LUA_TUSERDATA:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, userdata\n", i]];
                break;
            case LUA_TTHREAD:
                str = [str stringByAppendingString:[NSString stringWithFormat:@"%d, thread\n", i]];
                break;
        }
    }
    
    return str;
}


@implementation NSObject (luaEngine)

-(void) pushValue:(lua_State*)luaRTContext{
    NSLog(@"can not support the object type:%@", [self class]);
    assert(0);
}
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx{
    NSLog(@"can not support the object type:%@", [self class]);
    assert(0);
    return nil;
}

@end



@implementation NSNumber (luaEngine)


-(void) pushValue:(lua_State*)luaRTContext
{
    lua_pushnumber(luaRTContext, [self doubleValue]);
}

+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx{
    
    if(lua_isboolean(luaRTContext, idx)){
        return [NSNumber numberWithBool:(lua_toboolean(luaRTContext, idx)==true)? YES : NO];
    }
    else if(lua_isnumber(luaRTContext, idx)){
        return [NSNumber numberWithDouble:lua_tonumber(luaRTContext, idx)];
    }
    else{
        NSLog(@"the value is not a number or bool");
        
        //it's not the correct datatype. However, I still try to convert it to a number
        return [NSNumber numberWithDouble:lua_tonumber(luaRTContext, idx)];
    }
}
@end




@implementation NSString(luaEngine)


-(void) pushValue:(lua_State*)luaRTContext{
    lua_pushstring(luaRTContext, [self UTF8String]);
}


+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx;
{
    if(!lua_isstring(luaRTContext, idx))
        NSLog(@"the value is not a string");
    
    return [NSString stringWithUTF8String:lua_tostring(luaRTContext, idx)];
}

@end



@implementation NSArray(luaEngine)

-(void) pushValue:(lua_State*)luaRTContext{
    
    NSMutableDictionary<luaBinding>* dict = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    
    int index = 1;
    for(NSObject* obj in self){
        //NSString* key = [NSString stringWithFormat:@"%d", index];
        NSNumber* key = [NSNumber numberWithInt:index];
        
        [dict setObject:obj forKey:key];
        index++;
    }
    
    [dict setObject:[NSNumber numberWithBool:YES] forKey:luaEngineArrayDataTypeKey];
    
    
    [dict pushValue:luaRTContext];
    
}
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx{
    
    //you can not get here.
    //all value in lua is tread as a table.
    assert(0);
    
    return nil;
}

@end



@implementation NSDictionary(luaEngine)


-(id) autoGet :(lua_State*)luaRTContext :(int)idx
{
    switch (lua_type(luaRTContext, idx)) {
        case LUA_TNUMBER:
        case LUA_TBOOLEAN:
            return [NSNumber valueWithLuaState:luaRTContext :idx];
            break;
        case LUA_TSTRING:
            return [NSString valueWithLuaState:luaRTContext :idx];
            break;
        case LUA_TTABLE:
            /*number or array*/
            return [NSMutableDictionary valueWithLuaState:luaRTContext :idx];
            break;
        defaut:
            NSLog(@"unknow datatype");
            
    }
    
    return nil;
}


-(void) pushValue:(lua_State*)luaRTContext{
    
    lua_newtable(luaRTContext);
    
    NSEnumerator* keys = [self keyEnumerator];
    for(NSObject<luaBinding>* key in keys)
    {
        NSObject<luaBinding>* obj = [self objectForKey:key];
        [key pushValue:luaRTContext];
        [obj pushValue:luaRTContext];
        lua_settable(luaRTContext, -3);
    }
}

+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx{
    
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    
    lua_pushnil(luaRTContext);  /* first key */
    while (lua_next(luaRTContext, idx) != 0) {
        /* uses 'key' (at index -2) and 'value' (at index -1) */
        int newIdx = lua_gettop(luaRTContext);
        
        id val = [dict autoGet :luaRTContext: newIdx];
        val = (nil == val)? [NSNull null] : val;
        id key = [dict autoGet :luaRTContext :newIdx-1];
        key = (nil == key)? [NSNull null] : key;
        [dict setObject:val forKey: key];

        /* removes 'value'; keeps 'key' for next iteration */
        lua_pop(luaRTContext, 1);
    }
    
    NSNumber* isArrayDataType = [dict objectForKey:luaEngineArrayDataTypeKey];
    if(nil != isArrayDataType  &&  YES == [isArrayDataType boolValue]){
        
        //convert the mutable dictionary to nsarray
        [dict removeObjectForKey:luaEngineArrayDataTypeKey];
        
        NSUInteger count = [dict count];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:count];
        
        for(int i=0; i<count; i++){
            id obj = [dict objectForKey:[NSNumber numberWithInt:i+1]];
            if(nil == obj)
                obj = [NSNull null];
            
            [arr addObject:obj];
        }
        
        return arr;
    }
    else
    {
        //convert the mutable dictionary to dictionary
        NSDictionary* rtDict = [NSDictionary dictionaryWithDictionary:dict];
        return rtDict;
    }
}



@end




@implementation NSNull(luaEngine)

-(void) pushValue:(lua_State*)luaRTContext{
    lua_pushnil(luaRTContext);
}
+(id) valueWithLuaState:(lua_State*)luaRTContext :(int)idx{
    return nil;
}

@end














