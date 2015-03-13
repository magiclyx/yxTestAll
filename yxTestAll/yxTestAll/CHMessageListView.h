//
//  messageTable.h
//  yxTestAll
//
//  Created by Yuxi Liu on 3/3/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "CHMessageView.h"
#import "CHCheckbox.h"

@class CHMessageListView;

@protocol CHMessageListViewDataSource <NSObject>
@required
- (NSInteger)messageListViewRowNumber:(CHMessageListView*)messageListView;
- (NSString*)messageListView:(CHMessageListView*)messageListView titleForRow:(NSUInteger)row;
- (CHCheckboxState)messageListView:(CHMessageListView*)messageListView checkboxStateForRow:(NSUInteger)row;
@end

@protocol CHMessageListViewDelegate <NSObject>
@optional
- (void)messageListViewDidPressConfirm:(CHMessageListView*)messageListView;
- (void)messageListViewDidPressCancel:(CHMessageListView*)messageListView;
- (void)messageListViewDidPressBottomButton:(CHMessageListView*)messageListView;
- (void)messageListView:(CHMessageListView*)messageListView checkboxDidChanged:(CHCheckboxState)newState inRow:(NSUInteger)row;
- (void)messageListView:(CHMessageListView*)messageListView didSelectRow:(NSUInteger)row;

@end





@interface CHMessageListView : CHMessageView

+ (instancetype)sharedInstance;
- (void)show;
- (void)dismiss;


//- (instancetype)initWithTitle:(NSString*)title;

- (void)setCheckBoxState:(CHCheckboxState)state atRow:(NSUInteger)row;
- (CHCheckboxState)checkboxStateForRow:(NSUInteger)row;

@property(readwrite, retain, nonatomic) NSString* title;
@property(readwrite, retain, nonatomic) NSString* bottomButtonText;

@property (nonatomic, assign) id <CHMessageListViewDataSource> dataSource;
@property (nonatomic, assign) id <CHMessageListViewDelegate> delegate;

@end






