//
//  helpOverlay.m
//  yxTestAll
//
//  Created by Yuxi Liu on 1/11/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "helpOverlay.h"

#import "popoverWindow.h"

@interface helpOverlay(){
    popoverWindow* _window;
    UIImageView* _imageView;
}


-(instancetype) _initWithImage:(UIImage*)image andPopWindow:(popoverWindow*)popWindow;
@end

@implementation helpOverlay

+(void)showHelpOverlayWithImage:(UIImage*)image
{
    
    popoverWindow* overlayWindow = [[popoverWindow alloc] init];
    helpOverlay* overlayView = [[[self class] alloc] _initWithImage:image andPopWindow:overlayWindow];
    
    UIWindow *window = [[[UIApplication sharedApplication] keyWindow] retain];
    CGRect rect = window.bounds;

    
    [overlayWindow presentContentView:overlayView inRect:rect withUserInfo:nil andDelegate:nil];
    
    
//    double delayInSeconds = 5.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [overlayWindow dismiss:YES];
//    });

    
    
    [window release];
    [overlayWindow release];
    [overlayView release];
}

#pragma mark private

-(instancetype)_initWithImage:(UIImage*)image andPopWindow:(popoverWindow*)popWindow
{
    self = [super init];
    if (self) {
        
        _window = [popWindow retain];
        
        _imageView = [[UIImageView alloc] initWithImage:image];
        [_imageView setFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        [self addSubview:_imageView];
        [self setAutoresizesSubviews:YES];
        
        
    }
    
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [_window dismiss:YES];
    
   // [_window release];
}


- (void)dealloc
{
    [_window release], _window = nil;
    [_imageView release], _imageView = nil;
    
    [super dealloc];
}

@end

