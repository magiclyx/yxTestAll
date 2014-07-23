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
    BOOL _autoScrollToEnd;
    NSDate *_timeStamp;
}

@property(readwrite, assign, atomic) BOOL autoScrollToEnd;

- (void)_scrollToEndIfNeed;

- (void)_resetTimeCounter;
- (void)_stopTimeCounter;

@end

@implementation outputView

@synthesize autoScrollToEnd = _autoScrollToEnd;


- (void)testLog:(NSString*)log{
    NSString* str = [self text];
    str = [str stringByAppendingFormat:@"%@\n", log];
    [self setText:str];
    
    
    [self _scrollToEndIfNeed];

}


#pragma delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _stopTimeCounter];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self _resetTimeCounter];
}



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
    }
    return self;
}


#pragma mark privat
- (void)_scrollToEndIfNeed{
    
    if (NO ==  [self autoScrollToEnd]) {
        return;
    }
    
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

- (void)_resetTimeCounter{
    
    [self setAutoScrollToEnd:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_scrollToEndIfNeed) object:nil];
    [self performSelector:@selector(_scrollToEndIfNeed) withObject:nil afterDelay:outputView_autoScroll_timeInterval];
}
- (void)_stopTimeCounter{
    
   [self setAutoScrollToEnd:NO];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_scrollToEndIfNeed) object:nil];
}

@end
