//
//  popupWindow.h
//  yxTestAll
//
//  Created by Yuxi Liu on 1/8/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol popoverWindowDelegate <NSObject>
@optional
@end

@interface popoverWindow : UIWindow

@property (readwrite, retain) UIView* contentView;
@property (readwrite, retain) id userInfo;
@property (readwrite, assign) id<popoverWindowDelegate> popoverDelegate;


- (void)dismiss:(BOOL)animated;
- (void)presentContentView:(UIView *)contentView inRect:(CGRect)inRect withUserInfo:(id)userInfo andDelegate:(id<popoverWindowDelegate>)popOverDelegate;

@end
