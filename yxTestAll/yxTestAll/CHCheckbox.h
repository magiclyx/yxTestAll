//
//  checkbox.h
//  yxTestAll
//
//  Created by Yuxi Liu on 3/5/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CHCheckboxState{
    CHCheckboxState_checked,
    CHCckboxState_uncheck,
}CHCheckboxState;

@interface CHCheckbox : UIButton
- (CGFloat)checkboxSize;
- (void)changeState;
- (void)setTargetWhenCheckboxChanged:(id)target action:(SEL)action;

@property(readwrite, assign, nonatomic) CHCheckboxState checkboxState;
@property(readwrite, retain, nonatomic) id userdata;

@end
