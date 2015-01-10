//
//  popupWindow.m
//  yxTestAll
//
//  Created by Yuxi Liu on 1/8/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "popoverWindow.h"

@interface popoverWindow()
- (UIWindow *)_applicationWindow;
- (void)_dismiss;
@end

@implementation popoverWindow

static const CGFloat KPopoverWindowAnimationDuration = 0.2f;

#pragma mark public

- (void)presentContentView:(UIView *)contentView inRect:(CGRect)inRect withUserInfo:(id)userInfo andDelegate:(id<popoverWindowDelegate>)popOverDelegate
{
    BOOL animated = NO;
    if (contentView != _contentView) {
        [self dismiss:YES];
        _contentView = [contentView retain];
        animated = YES;
    }
    
    if (userInfo != _userInfo) {
        [userInfo release];
        userInfo = [_userInfo retain];
    }
    
    _popoverDelegate = popOverDelegate;
    
    
    UIWindow *window = [[[UIApplication sharedApplication] keyWindow] retain];
    self.frame = window.frame;
    
    _contentView.frame = inRect;
    
    self.hidden = NO;
    
    [self makeKeyAndVisible];
    [window makeKeyWindow];
    [window release];
    
    
    [self addSubview:_contentView];
    
    
    if (YES == animated) {
        [_contentView setAlpha:0.0f];
        [self setBackgroundColor:[UIColor clearColor]];
        [UIView beginAnimations:@"FadeInPopoverContentView" context:nil];
        [UIView setAnimationDuration:KPopoverWindowAnimationDuration];
    }
    
    [_contentView setAlpha:1.0f];
    
    if (YES == animated) {
        [UIView commitAnimations];
    }
}

- (void)dismiss:(BOOL)animated
{
    if (YES == self.hidden) {
        return;
    }
    
    if (YES == animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:KPopoverWindowAnimationDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(_dismiss)];
        _contentView.alpha = 0;
        [UIView commitAnimations];
    }
    else
    {
        [self _dismiss];
    }
}



#pragma mark lifecrycle
- (instancetype)init{
    self = [super init];
    if (self) {
        _contentView = nil;
        _userInfo = nil;
        _popoverDelegate = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [_contentView release], _contentView = nil;
    [_userInfo release], _userInfo = nil;
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark private

- (void)_dismiss
{
    [_userInfo release], _userInfo = nil;
    
    [_contentView removeFromSuperview];
    [_contentView release], _contentView = nil;
    
    [[self _applicationWindow] makeKeyWindow];
    
    self.hidden = YES;
    
    _popoverDelegate = nil;
}



- (UIWindow *)_applicationWindow
{
    UIApplication * application = [UIApplication sharedApplication];
    id<UIApplicationDelegate> appDelegate = [application delegate];
    if ([appDelegate respondsToSelector:@selector(window)])
    {
        return [appDelegate window];
    }
    else if ([[application windows] count])
    {
        return [[application windows] objectAtIndex:0];
    }
    
    return nil;
}

@end
