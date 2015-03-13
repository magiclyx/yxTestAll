//
//  CHTempView.h
//  coach360
//
//  Created by Yuxi Liu on 3/1/15.
//  Copyright (c) 2015 creatino@coach360.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHTempView;

typedef void (^CHTEmpViewAlertTapButtonBlock)(CHTempView *alertView, NSInteger buttonIndex);

@protocol CHTempViewDelegate <NSObject>

- (void)alertView:(CHTempView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end




@interface CHTempView : UIView

@property (nonatomic, readwrite, assign) id<CHTempViewDelegate> delegate;

@property (nonatomic, readwrite, copy) CHTEmpViewAlertTapButtonBlock buttonDidTappedBlock;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;


- (void)show;

- (void)dismiss;

@end
