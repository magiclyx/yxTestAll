//
//  runtime.h
//  yxTestAll
//
//  Created by Yuxi Liu on 12/20/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface runtime : NSObject

+ (id)sharedManager;

- (int)threadIndex;
- (NSArray*)callStacks;

- (NSString*)executablePath;
- (NSString*)uuid;
- (NSString*)loadAddress;
- (BOOL)isJailBroken;
- (NSDate*)systemBootTime;
- (NSString*)appVersion;





#pragma mark - basic function
/**
 *  some of the basic function
 */


/*!
 *  获取当前imageName名称的动态链接库对应的编号，不存在则返回UINT32_MAX
 *
 *
 *  @param imageName  需要查找的dylib名称
 *  @param exactMatch 一个布尔类型的值，Yes：表示需要查找的库名和所给的完全相等
 *                    No:使用包含所给参数的库名的方式来查找
 *
 *  @return 返回一个uint32_t类型的值
 */
- (UInt32)indexOfImage:(NSString*)imageName shouldFullMatch:(BOOL)fullMathch;

/*!
 *  获取用于标记 dSYM file 的 UUID.
 *
 *
 *  @param imageName  需要查找的dylib名称
 *  @param exactMatch 一个布尔类型的值，Yes：表示需要查找的库名和所给的完全相等
 *                    No:使用包含所给参数的库名的方式来查找
 *
 *  @return 返回用于标记 dSYM file 的 UUID
 */
- (const uint8_t*) uuidBytesOfImage:(NSString*)imageName shouldFullMatch:(BOOL)fullMathch;

/*!
 *  获取用于mach-O 文件的 mach_header.
 *
 *
 *  @param imageName  需要查找的dylib名称
 *  @param exactMatch 一个布尔类型的值，Yes：表示需要查找的库名和所给的完全相等
 *                    No:使用包含所给参数的库名的方式来查找
 *
 *  @return 返回mach-O 文件的 mach_header
 */
- (const uintptr_t) addressOfImage:(NSString*)imageName shouldFullMatch:(BOOL)fullMathch;

@end





