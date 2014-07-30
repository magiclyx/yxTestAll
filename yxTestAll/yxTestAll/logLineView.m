//
//  logLineView.m
//  yxTestAll
//
//  Created by Yuxi Liu on 7/28/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "logLineView.h"

@interface logLineView(){
    logItem* _item;
    UIColor* _backgroundColor;
}

@end

@implementation logLineView


-(void)setItem:(logItem *)item{
    
    
    if (NO == [_item isEqual:item])
        [self setNeedsDisplay];
    
    [item retain];
    [_item release];
    
    _item = item;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setItem:nil];
    }
    return self;
}

- (void)dealloc
{
    [_item release], _item = nil;
    
    [super dealloc];
}

-(void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    /*drawing background*/
    UIColor* backGroundColor = [_item backgroundColor];
    if (nil != backGroundColor) {
        CGContextSaveGState(context);
        
        [backGroundColor setFill];
        [[UIBezierPath bezierPathWithRect:bounds] fill];
        CGContextRestoreGState(context);
    }
    
    
    NSString* text = [_item text];
    /*draw text*/
    if (nil != text  &&  0 != [text length]) {
        
        CGRect rect = CGRectMake(0,
                                 ((bounds.size.height - _item.textSize.height) / 2.0f),
                                 _item.textSize.width,
                                 _item.textSize.height);
        
        [text drawInRect:rect withAttributes:_item.attributeDict];
    }
    
}


@end






