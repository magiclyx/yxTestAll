//
//  logItem.m
//  yxTestAll
//
//  Created by Yuxi Liu on 7/29/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "logItem.h"

@implementation logItem

#pragma overwrite

- (BOOL)isEqual:(id)object{
    
    
    BOOL isEqual = NO;
    
    
    if (self  ==  object)
        return YES;
    
    
    do{
        if (nil == object)
            break;
        
        if (NO == [object isKindOfClass:[logItem class]])
            break;
        
        logItem* anotherItem = (logItem*)object;
        
        if (NO == [self.text isEqual:anotherItem.text])
            break;
        
        
        isEqual = YES;
        
    }while (0);
    
    
    return isEqual;
}


#pragma mark lifecrycle

- (id)init{
    self = [super init];
    if (self) {
        [self setTextSize:CGSizeZero];
        [self setBackgroundColor:[UIColor blackColor]];
        
        _attributeDict = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:14]};
        [_attributeDict retain];
    }
    return self;
}

-(void)dealloc{
    
    [_text release], _text = nil;
    [_attributeDict release], _attributeDict = nil;
    
    [super dealloc];
}

+ (id)itemWithText:(NSString*)text{
    logItem* item = [[[[self class] alloc] init] autorelease];
    [item setText:text];
    
    return item;
}

@end
