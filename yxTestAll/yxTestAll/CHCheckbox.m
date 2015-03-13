//
//  checkbox.m
//  yxTestAll
//
//  Created by Yuxi Liu on 3/5/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "CHCheckbox.h"



@interface CHCheckbox(){
    id _checkboxTarget;
    SEL _checkboxSelect;
}

- (void)_touchedInside:(id)sender;

@end

@implementation CHCheckbox

#pragma public
- (CGFloat)checkboxSize
{
    return 14;
}

- (void)changeState
{
    [self setCheckboxState:(CHCheckboxState_checked == self.checkboxState)? CHCckboxState_uncheck : CHCheckboxState_checked];
}

- (void)setCheckboxState:(CHCheckboxState)checkboxState
{
    if (_checkboxState != checkboxState)
    {
        _checkboxState = checkboxState;
        
        [self setSelected:(CHCheckboxState_checked == _checkboxState)? YES : NO];
        
        if (nil != _checkboxTarget  &&  0 != _checkboxSelect  &&  [_checkboxTarget respondsToSelector:_checkboxSelect])
        {
            [_checkboxTarget performSelector:_checkboxSelect withObject:self];
        }
    }
}


- (void)setTargetWhenCheckboxChanged:(id)target action:(SEL)action
{
    _checkboxTarget = target;
    _checkboxSelect = action;
}


#pragma mark lifecrycle
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _checkboxTarget = nil;
        _checkboxSelect = 0;
        
        UIImage* checkbox_checked = [UIImage imageNamed:@"check_box_at"];
        UIImage* checkbox_uncheck = [UIImage imageNamed:@"check_box_un"];
        
        self.frame = frame;
        
        [self setImage:checkbox_uncheck forState:UIControlStateNormal];
        [self setImage:checkbox_checked forState:UIControlStateSelected];
        
        [self addTarget:self action:@selector(_touchedInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)dealloc
{
    [_userdata release], _userdata = nil;
    
    [super dealloc];
}


-(void)setFrame:(CGRect)frame
{
    
    CGFloat size = [self checkboxSize];
    
    if (frame.size.width < size)
        frame.size.width = size;
    
    if (frame.size.height < size)
        frame.size.height = size;
    
    [super setFrame:CGRectMake(frame.origin.x + (frame.size.width - size) / 2.0f,
                               frame.origin.y + (frame.size.height - size) / 2.0f,
                               size,
                               size)];
}



#pragma mark private
- (void)_touchedInside:(id)sender
{
    [self setCheckboxState:self.isSelected? CHCckboxState_uncheck : CHCheckboxState_checked];
}

@end
