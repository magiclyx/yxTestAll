//
//  messageTable.m
//  yxTestAll
//
//  Created by Yuxi Liu on 3/3/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "CHMessageListView.h"
#import "UIImage+skin.h"
#import "UIColor+Config.h"

static const CGFloat messageTableListHeight = 60.0f;
static const CGFloat messageTableListWidth = 300.0f;

#define messageTableLineFont LIGHTFONT24




@interface _messageListContentView : CHMessageContentView<UITableViewDelegate, UITableViewDataSource>
{
    UIButton* _cancelButton;
    UIButton* _conformButton;
    UILabel* _titleLabel;
    UIButton* _button;
}

- (instancetype)init;
- (void)didPressedCheckbox:(CHCheckbox*)sender;
- (void)didPressedCancelButton:(id)sender;
- (void)didPressedConfirmButton:(id)sender;
- (void)didPressedBottomButton:(id)sender;

- (void)setCheckBoxState:(CHCheckboxState)state atRow:(NSUInteger)row;
- (CHCheckboxState)checkboxStateForRow:(NSUInteger)row;


@property(readwrite, retain, nonatomic) NSString* title;
@property (readwrite, retain, nonatomic) NSString* bottomButtonText;
@property(readwrite, retain, nonatomic) UITableView* table;

@property (nonatomic, assign) id <CHMessageListViewDataSource> dataSource;
@property (nonatomic, assign) id <CHMessageListViewDelegate> delegate;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface messageTableContentViewCell : UITableViewCell

@property (readwrite, retain, nonatomic) CHCheckbox* checkbox;
@property (readwrite, retain, nonatomic) UIImageView* separatoryLine;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CHMessageListView(){
    id <CHMessageListViewDataSource> _dataSource;
    id <CHMessageListViewDelegate> _delegate;
    
    NSString* _title;
    NSString* _bootomButtonTitle;
}

@end

@implementation CHMessageListView

-(void)setDataSource:(id<CHMessageListViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _messageListContentView* contentView = (_messageListContentView*)self.contentView;
    if (nil != contentView) {
        assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
        [contentView setDataSource:dataSource];
    }
}

-(id<CHMessageListViewDataSource>)dataSource{
    return _dataSource;
//    _messageListContentView* contentView = (_messageListContentView*)self.contentView;
//    return [contentView dataSource];
}



-(void)setDelegate:(id<CHMessageListViewDelegate>)delegate
{
    _delegate = delegate;
    _messageListContentView* contentView = (_messageListContentView*)self.contentView;
    if (nil != contentView) {
        assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
        [contentView setDelegate:delegate];
    }
}

-(id<CHMessageListViewDelegate>)delegate
{
    return _delegate;
//    _messageListContentView* contentView = (_messageListContentView*)self.contentView;
//    return [contentView delegate];
}

- (void)setTitle:(NSString *)title
{
    [title retain];
    [_title release];
    _title = title;
    
    _messageListContentView* contentView = (_messageListContentView*)self.contentView;
    if (nil != contentView) {
        assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
        [contentView setTitle:title];
    }
    
}

- (NSString*)title
{
    return _title;
//    assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
//    return [((_messageListContentView*)self.contentView) title];
}

- (void)setBottomButtonText:(NSString *)bottomButtonText
{
    [bottomButtonText retain];
    [_bootomButtonTitle release];
    _bootomButtonTitle = bottomButtonText;
    
    _messageListContentView* contentView = (_messageListContentView*)self.contentView;
    if (nil != contentView)
    {
        assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
        
        [contentView setBottomButtonText:bottomButtonText];
    }
}

- (NSString*)bottomButtonText
{
    return _bootomButtonTitle;
//    assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
//    
//    return [((_messageListContentView*)self.contentView) bottomButtonText];
}


#pragma mark lifecycle

+ (instancetype)sharedInstance
{
    static dispatch_once_t  onceToken;
    static CHMessageListView* sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (void)show
{
    _messageListContentView* contentView = [[[_messageListContentView alloc] init] autorelease];
    [contentView setTitle:self.title];
    [contentView setBottomButtonText:self.bottomButtonText];
    [contentView setDataSource:self.dataSource];
    [contentView setDelegate:self.delegate];
    
    [super showWithContentView:contentView];
}

- (void)dismiss
{
    [super dismiss];
    
    [self setTitle:nil];
    [self setBottomButtonText:nil];
    [self setDelegate:nil];
    [self setDataSource:nil];
    
}


- (instancetype)init{
    self = [super init];
    if (self) {
        _dataSource = nil;
        _delegate = nil;
        
        _title = nil;
        _bootomButtonTitle = nil;
    }
    
    return self;
    
}


- (void)setCheckBoxState:(CHCheckboxState)state atRow:(NSUInteger)row
{
    assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
    
    [((_messageListContentView*)self.contentView) setCheckBoxState:state atRow:row];
}

- (CHCheckboxState)checkboxStateForRow:(NSUInteger)row
{
    assert(YES == [self.contentView isKindOfClass:[_messageListContentView class]]);
    
    return [((_messageListContentView*)self.contentView) checkboxStateForRow:row];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation _messageListContentView

- (void)setTitle:(NSString *)title {
    
    if (nil == title)
        title = @"";
    
    
    if (nil == _titleLabel) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setFont:messageTableLineFont];
        [_titleLabel setTextColor:[UIColor coach360ColorFF8833]];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_titleLabel];
    }
    
    CGSize size = [title sizeWithFont:[_titleLabel font]];
    
    [_titleLabel setText:title];
    _titleLabel.frame = CGRectMake((self.frame.size.width - size.width) / 2.0f,
                                   12,
                                   size.width,
                                   size.height);
    
}

- (NSString*)title{
    if (nil == _titleLabel)
        return nil;
    
    return _titleLabel.text;
}

- (void)setBottomButtonText:(NSString *)bottomButtonText
{
    [_button setTitle:bottomButtonText forState:UIControlStateNormal];
}

- (NSString*)bottomButtonText
{
    return [_button titleForState:UIControlStateNormal];
}


#pragma mark lifecycle
- (instancetype)init{
//- (instancetype)initWithTitle:(NSString*)title{
    self = [super initWithHeight:messageTableListHeight*6+4];
    if (self)
    {
        
        
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        
        
        UIColor* skinColor = [UIColor coach360ColorFF8833];
//        UIFont *font = LIGHTFONT15;
        
        
        /*
         title
         */
        _titleLabel = nil;
//        if (nil != title  &&  0 != title.length) {
//            self.title = title;
//        }
        
        
        
        /*
         left button
         right button
         */
        UIImage* cancel_image  = [UIImage colorAnImage:skinColor image:[UIImage imageNamed:@"account_arrow_go back"]];
        UIImage* confirm_image  = [UIImage colorAnImage:skinColor image:[UIImage imageNamed:@"account_confirm_check"]];
        
        
        CGSize confirmButton_size = confirm_image.size;
        CGSize cancelButton_size = cancel_image.size;
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(12,
                                                                   18,
                                                                   confirmButton_size.width,
                                                                   confirmButton_size.height)];
        
        _conformButton = [[UIButton alloc] initWithFrame:CGRectMake(width-cancelButton_size.width - 12,
                                                                    18,
                                                                    cancelButton_size.width,
                                                                    cancelButton_size.height)];
        
        
        [_cancelButton setImage:cancel_image forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(didPressedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [_conformButton setImage:confirm_image forState:UIControlStateNormal];
        [_conformButton addTarget:self action:@selector(didPressedConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_cancelButton];
        [self addSubview:_conformButton];
        
        
        /*table*/
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                               messageTableListHeight,
                                                               width,
                                                               height - (messageTableListHeight * 2))];
        [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_table setDelegate:self];
        [_table setDataSource:self];
        [self addSubview:_table];
        
        
        /**/
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                             height - messageTableListHeight,
                                                             width,
                                                             messageTableListHeight)];
        [_button.titleLabel setFont:messageTableLineFont];
        [_button setBackgroundImage:[UIImage
                                     imageWithColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
                                     size:CGSizeMake(width, messageTableListHeight)] forState:UIControlStateNormal];
        
        [_button setBackgroundImage:[UIImage
                                     imageWithColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]
                                     size:CGSizeMake(width, messageTableListHeight)] forState:UIControlStateHighlighted];
        
        [_button setTitleColor:[UIColor coach360ColorFF8833] forState:UIControlStateNormal];
        
        [self addSubview:_button];

    }
    
    return self;
}

-(void)dealloc{
    
    [_cancelButton release], _cancelButton = nil;
    [_conformButton release], _conformButton = nil;
    [_titleLabel release], _titleLabel = nil;
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint aPoints[2];
    aPoints[0] =CGPointMake(0.0f, 50.0f);
    aPoints[1] =CGPointMake(messageTableListWidth, 50.0f);
    CGContextAddLines(context, aPoints, 2);
    CGContextSetLineWidth(context, 1.0f / [[UIScreen mainScreen] scale]);
    CGContextSetStrokeColorWithColor(context, [UIColor coach360ColorFF8833].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return messageTableListHeight + 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    messageTableContentViewCell* cell = (messageTableContentViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    assert([cell isKindOfClass:[messageTableContentViewCell class]]);
    
//    [cell.checkbox changeState];
    
    
    assert(YES == [self.superview isKindOfClass:[CHMessageListView class]]);
    if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(messageListView:didSelectRow:)]) {
        [_delegate messageListView:(CHMessageListView*)self.superview didSelectRow:indexPath.row];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark table datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil != _dataSource) {
        assert(YES == [_dataSource respondsToSelector:@selector(messageListViewRowNumber:)]);
        assert(YES == [self.superview isKindOfClass:[CHMessageListView class]]);
 
        return [_dataSource messageListViewRowNumber:(CHMessageListView*)self.superview];
    }
    
    return 0;
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    messageTableContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.coach360.CHMessageListView.cell"];
    
    
    if (nil == cell) {
        cell = [[messageTableContentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.coach360.CHMessageListView.cell"];
        
        [cell.checkbox addTarget:self action:@selector(didPressedCheckbox:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    [cell.checkbox setUserdata:indexPath];
    
    if (nil != _dataSource) {
        [cell.checkbox setHidden:NO];
        [cell.textLabel setHidden:NO];
        
        assert(YES == [self.superview isKindOfClass:[CHMessageListView class]]);
        
        
        assert(YES == [_dataSource respondsToSelector:@selector(messageListView:titleForRow:)]);
        NSString* title = [_dataSource messageListView:(CHMessageListView*)self.superview titleForRow:[indexPath row]];
        [cell.textLabel setText:title];
        
        
        assert(YES == [_dataSource respondsToSelector:@selector(messageListView:checkboxStateForRow:)]);
        CHCheckboxState state = [_dataSource messageListView:(CHMessageListView*)self.superview checkboxStateForRow:[indexPath row]];
        [cell.checkbox setCheckboxState:state];
    }
    else
    {
        [cell.checkbox setHidden:YES];
        [cell.textLabel setHidden:YES];
    }
    
    
    return cell;
    
}


#pragma mark _checkbox
- (void)didPressedCheckbox:(CHCheckbox*)sender
{
    assert(YES == [self.superview isKindOfClass:[CHMessageListView class]]);

    if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(messageListView:checkboxDidChanged:inRow:)])
    {
        NSIndexPath* indexPath = sender.userdata;
        [_delegate messageListView:(CHMessageListView*)self.superview checkboxDidChanged:sender.checkboxState inRow:indexPath.row];
    }
}

- (void)didPressedCancelButton:(id)sender
{
    assert(YES == [self.superview isKindOfClass:[CHMessageListView class]]);
    
    if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(messageListViewDidPressCancel:)]) {
        [_delegate messageListViewDidPressCancel:(CHMessageListView*)self.superview];
    }
}

- (void)didPressedConfirmButton:(id)sender
{
    assert(YES == [self.superview isKindOfClass:[CHMessageListView class]]);
    
    if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(messageListViewDidPressConfirm:)]) {
        [_delegate messageListViewDidPressConfirm:(CHMessageListView*)self.superview];
    }
}

- (void)didPressedBottomButton:(id)sender
{
    assert(YES == [self.superview isKindOfClass:[CHMessageListView class]]);
    
    if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(message)]) {
        [_delegate messageListViewDidPressBottomButton:(CHMessageListView*)self.superview];
    }
}

- (void)setCheckBoxState:(CHCheckboxState)state atRow:(NSUInteger)row
{
    messageTableContentViewCell* cell = (messageTableContentViewCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    [cell.checkbox setCheckboxState:state];
}

- (CHCheckboxState)checkboxStateForRow:(NSUInteger)row
{
    messageTableContentViewCell* cell = (messageTableContentViewCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
    return [[cell checkbox] checkboxState];
}


@end

@implementation messageTableContentViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        
        /*checkbox*/
        _checkbox = [[CHCheckbox alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_checkbox];
        
        
        /*line separatory*/
        UIImage* image =  [UIImage imageWithColor:[UIColor grayColor] size:CGSizeMake(messageTableListWidth, 1.0f /  [[UIScreen mainScreen] scale])];
        
        _separatoryLine = [[UIImageView alloc] initWithFrame:CGRectZero];
        _separatoryLine.image = image;
        
        [self.contentView addSubview:_separatoryLine];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        self.backgroundColor = [UIColor clearColor];
        
        [self layoutSubviews];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
   
    CGRect textFrame = self.textLabel.frame;
    textFrame.size.width -= 20.0f;
    self.textLabel.frame = textFrame;
    
    
    _checkbox.frame = CGRectMake(messageTableListWidth - 50.0f,
                                 0,
                                 50.0f,
                                 messageTableListHeight);
    
   
    _separatoryLine.frame = CGRectMake(0.0f, messageTableListHeight+0.0f, messageTableListWidth, 0.5f);

}

- (void)dealloc
{
    [_checkbox release], _checkbox = nil;
    [_separatoryLine release], _separatoryLine = nil;
    
    [super dealloc];
}

@end



