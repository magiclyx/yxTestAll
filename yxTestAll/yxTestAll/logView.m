//
//  logView.m
//  yxTestAll
//
//  Created by Yuxi Liu on 7/28/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "logView.h"
#import "logLineView.h"
#import "logItem.h"

static const CGFloat logView_autoScrollToBottom_timeInterval = 3.0f;



/**
 *  log 中的cell
 */
@interface _logTableViewcell : UITableViewCell{
    logLineView* _lineView;
}
@property(readwrite, retain, nonatomic) logItem* logItem;
@end






@interface logView()<UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray* _lines;
    CGFloat _linespacing;
    
    
    BOOL _autoScrollToBottomFlag; //是否自动滚动到表格尾部(插入时判断)
}

- (void) _scrollToBottomIfNeed; //如果_autoScrollToBottomFlag为True, 自动滚动到尾部

- (void) _autoScrollToBottom; //设置_autoScrollToBottomFlag标记
- (void) _notAutoScrollToBottom; //清楚_autoScrollToBottomFlag标记

@end





@implementation logView

@synthesize lineSpacing = _linespacing;

- (void)separateBar{
    logItem* item = [logItem itemWithText:@""];
    [item setBackgroundColor:[UIColor grayColor]];
    [_lines addObject:item];
    [self reloadData];
    
    [self _scrollToBottomIfNeed];
}

- (void)log:(NSString*)text{
    if (nil != text) {
        logItem* item = [logItem itemWithText:text];
        [_lines addObject:item];
        [self reloadData];
        
        [self _scrollToBottomIfNeed];
    }
}





#pragma mark - lifecrycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _autoScrollToBottom];
        _lines = [[NSMutableArray alloc] init];
        [self setLineSpacing:10.0f];
        
        [self setBackgroundColor:[UIColor blackColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [self setDataSource:self];
        [self setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_lines release], _lines = nil;
    
    [super dealloc];
}


#pragma mark dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_lines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _logTableViewcell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.logView.logTableViewCell.line"];
    
    
    if (nil == cell) {
        cell = [[_logTableViewcell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.logView.logTableViewCell.line"];
    }
    
    assert(YES == [cell isKindOfClass:[_logTableViewcell class]]);
    
    logItem* logItem = [_lines objectAtIndex:indexPath.row];
    [cell setLogItem:logItem];

    
    return cell;
}

#pragma mark delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    logItem* logItem = [_lines objectAtIndex:indexPath.row];
    
    
    CGSize textSize = [logItem textSize];
    
    if (CGSizeEqualToSize(textSize, CGSizeZero)) {
        textSize = [logItem.text sizeWithAttributes:logItem.attributeDict];
        
        [logItem setTextSize:textSize];
    }
    
    
    return textSize.height + self.lineSpacing;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_autoScrollToBottom) object:nil];
    [self _notAutoScrollToBottom];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_autoScrollToBottom) object:nil];
    [self performSelector:@selector(_autoScrollToBottom) withObject:nil afterDelay:logView_autoScrollToBottom_timeInterval];
}

#pragma mark private
- (void) _scrollToBottomIfNeed{
    
    
    if (YES == _autoScrollToBottomFlag) {
        NSInteger section = [self numberOfSections];
        if (section < 1)
            return;
        
        NSInteger row = [self numberOfRowsInSection:(section-1)];
        if (row < 1)
            return;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:section-1];
        
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

- (void) _autoScrollToBottom{
    _autoScrollToBottomFlag = YES;
}
- (void) _notAutoScrollToBottom{
    _autoScrollToBottomFlag = NO;
}


@end






@implementation _logTableViewcell

- (void)setLogItem:(logItem *)logItem{
    [_lineView setItem:logItem];
}

- (logItem*)logItem{
    return [_lineView item];
}



#pragma mark lifecrycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _lineView = [[logLineView alloc] initWithFrame:[self.contentView bounds]];
        [_lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        [self.contentView setBackgroundColor:[UIColor blackColor]];
        [self.contentView setAutoresizesSubviews:YES];
        [self.contentView addSubview:_lineView];
    }
    return self;
}

-(void)dealloc{
    [_lineView release], _lineView = nil;
    [super dealloc];
}

@end