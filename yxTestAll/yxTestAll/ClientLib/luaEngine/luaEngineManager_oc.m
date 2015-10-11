//
//  luaEngineManager_oc.m
//  yxTestAll
//
//  Created by LiuYuxi on 15/5/13.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import "luaEngineManager_oc.h"
#import "luaEngine_oc.h"
#import <pthread/pthread.h>
//#import "hash.h"
//#import "yx_log_server"

const NSUInteger luaEngineManager_max_engine = 1024;

NSUInteger luaEngineInvalidateIdentifer = ((NSUInteger)-1);


@interface luaEngineManager_oc(){
    luaEngine_oc** _enginelist;
    
    NSUInteger _free_position;
    NSUInteger _cached_position;
    
    pthread_rwlock_t _rwl;
    
    NSMutableDictionary* _name_mapping;
}
@end


@implementation luaEngineManager_oc

#pragma mark public

- (luaEngine_oc*)getEngineWithIdentifier:(NSUInteger)identifier
{
    luaEngine_oc* engine = nil;
    
    pthread_rwlock_rdlock(&_rwl);
    if (identifier < luaEngineManager_max_engine)
    {
        engine = _enginelist[identifier];
    }
    pthread_rwlock_unlock(&_rwl);

    
    
    return engine;
}

- (luaEngine_oc*)getEngineWithEngineName:(NSString*)engineName
{
    luaEngine_oc* engine = nil;

    pthread_rwlock_rdlock(&_rwl);
    engine = [_name_mapping objectForKey:engineName];
    pthread_rwlock_unlock(&_rwl);
    
    return engine;
}

+ (luaEngine_oc*)engineWithIdentifier:(NSUInteger)identifier
{
    return [[luaEngineManager_oc sharedManager] getEngineWithIdentifier:identifier];
}




- (NSUInteger)registEngine:(luaEngine_oc*)engine
{
    if (NULL == engine)
        return luaEngineInvalidateIdentifer;
    
    NSUInteger identifier = luaEngineInvalidateIdentifer;
    
    pthread_rwlock_wrlock(&_rwl);
    
    if (_free_position <= luaEngineManager_max_engine)
    {
        [_name_mapping setObject:engine forKey:[engine engineName]];
        _enginelist[_free_position] = engine;
        identifier = _free_position;
        _free_position++;
    }
    else if(_cached_position != luaEngineInvalidateIdentifer)
    {
        //yx_log_server_send("luaEngineManager low performance", yx_log_warning, yx_log_nosync);
        assert(0);//low performance !!!!
        for (NSUInteger i = _cached_position; i < luaEngineManager_max_engine; i++)
        {
            if (NULL == _enginelist[i])
            {
                [_name_mapping setObject:engine forKey:[engine engineName]];
                _enginelist[i] = engine;
                _cached_position = i;
            }
        }
        
        if (_cached_position >= luaEngineManager_max_engine)
        {
            _cached_position = luaEngineInvalidateIdentifer;
        }
    }
    
    pthread_rwlock_unlock(&_rwl);
    
    
    return identifier;
}
- (void)unRegistEngine:(NSUInteger)identifier
{
    
    pthread_rwlock_wrlock(&_rwl);
    
    if (identifier < luaEngineManager_max_engine)
    {
        [_name_mapping removeObjectForKey: [_enginelist[identifier] engineName]];
        [_enginelist[identifier] release];
        _enginelist[identifier] = NULL;
        
        
        if (identifier < _cached_position)
        {
            _cached_position = identifier;
        }
    }
    
    pthread_rwlock_unlock(&_rwl);

}


#pragma mark lifecrycle
+ (instancetype)sharedManager
{
    static dispatch_once_t  onceToken;
    static luaEngineManager_oc* sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enginelist = malloc(sizeof(luaEngine_oc*) * luaEngineManager_max_engine);
        
        pthread_rwlock_init(&_rwl, NULL);
        
        _name_mapping = [[NSMutableDictionary alloc] init];
        
        _free_position = 0;
        _cached_position = luaEngineInvalidateIdentifer;
    }
    return self;
}



-(void)dealloc
{
    if (NULL != _enginelist)
    {
        pthread_rwlock_wrlock(&_rwl);
        
        [_name_mapping release], _name_mapping = nil;
        
        free(_enginelist);
        _enginelist = NULL;
        pthread_rwlock_unlock(&_rwl);
    }
    
    pthread_rwlock_destroy(&_rwl);
    
    [super dealloc];
}


@end
