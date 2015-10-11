//
//  obj.m
//  testClass
//
//  Created by Yuxi Liu on 12/10/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#import "RMObject.h"

//#import <objc/objc-runtime.h>
#import "remoteObj.h"
#import "NSObject+remoteObj.h"

/*
 //:~ TODO
  Poor performance. merge bitMap
*/



@interface RMObject()


-(NSString*)_objc_classType2ClassNme:(NSString*)classTypeStr;

@end



@implementation RMObject



-(NSDictionary*) toDictionary{
    
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    
//    Class cls = [self class];
//    while (cls != [NSObject class])
//    {
//        unsigned int numberOfIvars = 0;
//        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
//        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
//        {
//            Ivar const ivar = *p;
//            const char *type = ivar_getTypeEncoding(ivar);
//            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
// 
//            unsigned int typeBufLen = (unsigned int)strlen(type);
//            NSObject* obj = nil;
//            if(strncmp(type, @encode(RMObject), typeBufLen) == 0){
//                RMObject* var = [self valueForKey:key];
//                if(nil != obj){
//                    obj = [var toDictionary];
//                }
//            }
//            else if(strncmp(type, "@\"NSString\"", typeBufLen) == 0  ||
//                    strncmp(type, "@\"NSMutableString\"", typeBufLen) == 0){
//                RMObject<remoteObj>* var = [self valueForKey:key];
//                if(nil != var){
//                    @try {
//                        obj = [var toRemoteObj];
//                    }
//                    @catch (NSException *exception) {
//                        NSArray *arr = [exception callStackSymbols];
//                        NSString *reason = [exception reason];
//                        NSString *name = [exception name];
//                        
//                        NSLog(@"an exception on remote object");
//                        NSString* log = [NSString stringWithFormat:@"%@\n%@\n%@\n", name, reason, arr];
//                        NSLog(@"%@", log);
//                        assert(0);
//                    }
//                }
//            }
//            else if(strncmp(type, "@\"NSNumber\"", typeBufLen) == 0){
//                RMObject<remoteObj>* var = [self valueForKey:key];
//                if(nil != var){
//                    obj = [var toRemoteObj];
//                }
//            }
//            else if(strncmp(type, "@\"NSDate\"", typeBufLen) == 0){
//                RMObject<remoteObj>* var = [self valueForKey:key];
//                if(nil != var){
//                    obj = [var toRemoteObj];
//                }
//            }
//            else if(strncmp(type, "@\"NSArray\"", typeBufLen) == 0  ||
//                    strncmp(type, "@\"NSMutableArray\"", typeBufLen) == 0){
//                RMObject<remoteObj>* var = [self valueForKey:key];
//                if(nil != var){
//                    obj = [var toRemoteObj];
//                }
//            }
//            else if(strncmp(type, "@\"NSDictionary\"", typeBufLen) == 0  ||
//                    strncmp(type, "@\"NSMutableDictionary\"", typeBufLen) == 0){
//                RMObject<remoteObj>* var = [self valueForKey:key];
//                if(nil != var){
//                    obj = [var toRemoteObj];
//                }
//            }
//            else if(strncmp(type, @encode(BOOL), typeBufLen) == 0){
//                NSUInteger ivarSize = 0;
//                NSUInteger ivarAlignment = 0;
//                // 取得变量的大小
//                NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
//                // ((const char *)self + ivar_getOffset(ivar))指向结构体变量
//                obj = [NSNumber numberWithBool:*((BOOL*)(((const char *)self + ivar_getOffset(ivar))))];
//            }
//            else if(strncmp(type, @encode(unsigned long long), typeBufLen) == 0){
//                NSUInteger ivarSize = 0;
//                NSUInteger ivarAlignment = 0;
//                // 取得变量的大小
//                NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
//                // ((const char *)self + ivar_getOffset(ivar))指向结构体变量
//                obj = [NSNumber numberWithUnsignedLongLong:*((unsigned long long*)(((const char *)self + ivar_getOffset(ivar))))];
//            }
//            else{
//                
//                BOOL isFound = NO;
//                RMObject *value = [self valueForKey:key];
//                Class s = class_getSuperclass([value class]);
//                while (Nil != s) {
//                    if([[class_getSuperclass([value class]) description] isEqualToString:@"RMObject"]){
//                        if(nil != value){
//                            obj = [value toDictionary];
//                            isFound = YES;
//                            break;
//                        }
//                    }
//                    
//                    s = class_getSuperclass(s);
//                }
//                
//                
////                if(NO == isFound){
////                    NSLog(@"unknow type :%s", type);
////                    assert(0);
////                }
//                
//            }
//            
//            if(nil != obj)
//                [dict setObject:obj forKey:key];
//        }
//        
//        
//        
//        cls = class_getSuperclass(cls);
//    }
    
    return dict;
}


-(id) initWithDictionary:(NSDictionary*)dict{
//    if(nil == (self = [self init]))
//        return nil;
//    
//    Class cls = [self class];
//    while (cls != [NSObject class]) {
//        unsigned int numberOfIvars = 0;
//        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);
//        
//        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)
//        {
//            Ivar const ivar = *p;
//            const char* type = ivar_getTypeEncoding(ivar);
//            NSString* key = [NSString stringWithUTF8String:ivar_getName(ivar)];
//            NSObject* value = [dict objectForKey:key];
//            
//            if(nil == value)
//                continue;
//            
//            
//            NSUInteger ivarSize = 0;
//            NSUInteger ivarAlignment = 0;
//            NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
//            void *sourceIvarLocation = (char*)self+ ivar_getOffset(ivar);
//            
//            unsigned int typeBufLen = (unsigned int)strlen(type);
//            if(strncmp(type, @encode(RMObject), typeBufLen) == 0){
//                RMObject* obj = [[[value class] alloc] initWithRemoteObj:value];
//                [self setValue:obj forKey:key];
//            }
//            else if(strncmp(type, "@\"NSString\"", typeBufLen) == 0){
//                [self setValue:value forKey:key];
//            }
//            else if(strncmp(type, "@\"NSNumber\"", typeBufLen) == 0){                
//                [self setValue:value forKey:key];
//            }
//            else if(strncmp(type, "@\"NSDate\"", typeBufLen) == 0){
//                [self setValue:value forKey:key];
//            }
//            else if(strncmp(type, "@\"NSArray\"", typeBufLen) == 0  ||
//                    strncmp(type, "@\"NSMutableArray\"", typeBufLen) == 0){
//                
//                [self setValue:value forKey:key];
//            }
//            else if(strncmp(type, "@\"NSDictionary\"", typeBufLen) == 0  ||
//                    strncmp(type, "@\"NSMutableDictionary\"", typeBufLen) == 0){
//                [self setValue:value forKey:key];
//            }
//            else if(strncmp(type, @encode(BOOL), typeBufLen) == 0){               
//                BOOL valBuf = [((NSNumber*)value) boolValue];
//                memcpy(sourceIvarLocation, &valBuf, ivarSize);
//            }
//            else if(strncmp(type, @encode(unsigned long long), typeBufLen) == 0){
//                unsigned long long valBuf = [((NSNumber*)value) unsignedLongLongValue];
//                memcpy(sourceIvarLocation, &valBuf, ivarSize);
//            }
//            else{
//                BOOL isFound = NO;
//                NSString* clsName = [self _objc_classType2ClassNme:[NSString stringWithUTF8String:type]];
//                Class s = NSClassFromString(clsName);
//                //Class s = class_getSuperclass([value class]);
//                while (Nil != s) {
//                    if([[s description] isEqualToString:@"RMObject"]){
//                        if(nil != value){
//                            assert([value isKindOfClass:[NSDictionary class]] == YES  || [value isKindOfClass:[NSMutableDictionary class]] == YES);
//                            RMObject* obj = [[NSClassFromString(clsName) alloc] initWithRemoteObj:value];
//                            [self setValue:obj forKey:key];
//                            isFound = YES;
//                            break;
//                        }
//                    }
//                    
//                    s = class_getSuperclass(s);
//                }
//                
//                
////                if(NO == isFound){
////                    NSLog(@"unknow type :%s", type);
////                    assert(0);
////                }
//            }
//            
//            
//            
//        }
//        cls = class_getSuperclass(cls);
//    }
    
    
    
    
    
    
    return self;
}


-(NSString*)_objc_classType2ClassNme:(NSString*)classTypeStr{
    return [classTypeStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\"@"]];
}



@end
