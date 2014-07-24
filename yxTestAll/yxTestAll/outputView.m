//
//  outputView.m
//  testNavigation
//
//  Created by Yuxi Liu on 7/8/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "outputView.h"

static const CGFloat outputView_autoScroll_timeInterval = 3.0f;


@interface outputView()<UITextViewDelegate>{
    
    BOOL _lockedAutoScroll;
    BOOL _autoScrollToEnd;
    NSDate *_timeStamp;
}

@property(readwrite, assign, atomic) BOOL autoScrollToEnd;

- (void)_scrollToEndIfNeed;


- (void)_resetTimeCounter:(BOOL)forceUnlocked;
- (void)_pauseTimerCounter:(BOOL)locked;


- (void)_setAutoScrollFlag;
- (void)_removeAutoScrollFlag;

@end

@implementation outputView

@synthesize autoScrollToEnd = _autoScrollToEnd;


- (void)log:(NSString*)log{
    NSString* str = [self text];
    str = [str stringByAppendingFormat:@"%@\n", log];
    [self setText:str];
    
    [self _scrollToEndIfNeed];
}


#pragma delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _pauseTimerCounter:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self _resetTimeCounter:NO];
}

//- (void)textViewDidBeginEditing:(UITextView *)textView{
//    [self _pauseTimerCounter:YES];
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView{
//    [self _pauseTimerCounter:NO];
//}


#pragma mark lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setAutoScrollToEnd:YES];
        
        [self setDelegate:self];
        
        [self setBackgroundColor:[UIColor blackColor]];
        [self setTextColor:[UIColor whiteColor]];
        
        /*Temporarily does not support ediwt*/
        _lockedAutoScroll = NO;
        [self setEditable:NO];
    }
    return self;
}


#pragma mark privat
- (void)_scrollToEndIfNeed{
    
    
    if (NO ==  [self autoScrollToEnd])
        return;
    
    
    CGPoint contentOffsetPoint = self.contentOffset;
    CGSize frameSize = self.frame.size;
    CGSize contentSize = self.contentSize;
    
    /*判断是否滚到最下面*/
    if ( (frameSize.height < contentSize.height)  &&  (contentOffsetPoint.y != (contentSize.height - frameSize.height)) )
    {
        /*滚动到最下面*/
        [self scrollRangeToVisible:NSMakeRange([self.text length]-1,0)];
    }
}

- (void)_resetTimeCounter:(BOOL)forceUnlocked{
    
    if (NO == forceUnlocked) {
        if (YES == _lockedAutoScroll)
            return;
    }
    else{
        if (YES == _lockedAutoScroll)
            _lockedAutoScroll = NO;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setAutoScrollFlag) object:nil];
    [self performSelector:@selector(_setAutoScrollFlag) withObject:nil afterDelay:outputView_autoScroll_timeInterval];
    
}
- (void)_pauseTimerCounter:(BOOL)locked{
    
    _lockedAutoScroll = locked;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setAutoScrollFlag) object:nil];
    
   [self setAutoScrollToEnd:NO];
    
}



- (void)_setAutoScrollFlag{
    [self setAutoScrollToEnd:YES];
}
- (void)_removeAutoScrollFlag{
    [self setAutoScrollToEnd:NO];
}

@end

