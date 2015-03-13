//
//  messageViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 3/2/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "messageViewController.h"
#import "CHTempView.h"
#import "CHMessageListView.h"


@interface messageViewController ()<CHTempViewDelegate, CHMessageListViewDataSource, CHMessageListViewDelegate>
{
    UIButton* _button;
    
//    CHMessageListView* _messageView;
}

- (void)_buttonPressed:(id)sender;

@end

@implementation messageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(130, 50, 70, 40)];
    [_button setTitle:@"点我" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_button setBackgroundColor:[UIColor grayColor]];
    
    [self.view addSubview:_button];
    
    
    
}


- (void)dealloc
{
    [_button release], _button = nil;
    
    [super dealloc];
}

- (void)_buttonPressed:(id)sender
{
    
    CHMessageListView* messageView = [CHMessageListView sharedInstance];
    [messageView setBottomButtonText:@"button"];
    [messageView setTitle:@"title"];
    [messageView setDataSource:self];
    [messageView setDelegate:self];
    [messageView show];
    
    NSLog(@"pressed");
}

- (void)alertView:(CHTempView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[CHMessageListView sharedInstance] dismiss];
}

#pragma mark datasource
- (NSInteger)messageListViewRowNumber:(CHMessageListView*)messageListView
{
    return 10;
}
- (NSString*)messageListView:(CHMessageListView*)messageListView titleForRow:(NSUInteger)row
{
    return @"123123123";
}
- (CHCheckboxState)messageListView:(CHMessageListView*)messageListView checkboxStateForRow:(NSUInteger)row
{
    return CHCckboxState_uncheck;
}

#pragma mark delegate
- (void)messageListViewDidPressConfirm:(CHMessageListView*)messageListView
{
    [messageListView dismiss];
}
- (void)messageListViewDidPressCancel:(CHMessageListView*)messageListView
{
    [messageListView dismiss];
}
- (void)messageListView:(CHMessageListView*)messageListView checkboxDidChanged:(CHCheckboxState)newState inRow:(NSUInteger)row
{
    [messageListView dismiss];
}

- (void)messageListViewDidPressBottomButton:(CHMessageListView*)messageListView
{
    [messageListView dismiss];
}

- (void)messageListView:(CHMessageListView *)messageListView didSelectRow:(NSUInteger)row
{
    CHCheckboxState state = [messageListView checkboxStateForRow:row];
    
    [messageListView setCheckBoxState:(CHCheckboxState_checked == state)? CHCckboxState_uncheck : CHCheckboxState_checked  atRow:row];
}


@end






