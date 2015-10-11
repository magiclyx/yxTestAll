//
//  dynamicViewController.h
//  yxTestAll
//
//  Created by LiuYuxi on 15/8/26.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dynamicViewController : UIViewController
@property(readwrite, retain, atomic) UIView* square1;
@property(readwrite, retain, atomic) UIDynamicAnimator* animator;
@property(readwrite, retain, atomic) UIGravityBehavior* gravityBeahvior;
@property(readwrite, retain, atomic) UIAttachmentBehavior* attachmentBehavior;
@end
