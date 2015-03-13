//
//  messageView.h
//  yxTestAll
//
//  Created by Yuxi Liu on 3/2/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHMessageContentView : UIView
- (id)initWithHeight:(CGFloat)height;
- (id)initWithSize:(CGSize)size;
@end

@interface CHMessageView : UIView

- (instancetype)init;
//- (void)show;
- (void)showWithContentView:(CHMessageContentView*)contentView;
- (void)dismiss;
//- (void)showWithContentView:(CHMessageContentView*)contentView;

@property(readonly, retain, nonatomic) CHMessageContentView* contentView;


@end


