//
//  logItem.h
//  yxTestAll
//
//  Created by Yuxi Liu on 7/29/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  保存每行要绘制的上下文
 */
@interface logItem : NSObject

+ (id)itemWithText:(NSString*)text;

@property(readwrite, retain, nonatomic) NSString* text;
@property(readwrite, assign) CGSize textSize;
@property(readonly, retain, nonatomic) NSDictionary* attributeDict;

@property(readwrite, retain) UIColor* backgroundColor;

@end
