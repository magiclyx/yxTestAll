//
//  messageView.m
//  yxTestAll
//
//  Created by Yuxi Liu on 3/2/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//


#import "CHMessageView.h"

static const CGFloat messageView_defaultWidth = 300.0f;


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CHMessageContentView()
@property (readwrite, assign) CGFloat height;
@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CHMessageView(){
    CHMessageContentView* _contentView;
}

@property(readwrite, retain, nonatomic) CHMessageContentView* contentView;
@property(readwrite, retain, nonatomic) UIMotionEffectGroup *group;


@end


@implementation CHMessageView


- (void)setContentView:(CHMessageContentView *)contentView
{
    [contentView retain];
    
    if (nil != _contentView) {
        [_contentView removeFromSuperview];
        [_contentView release];
        _contentView = nil;
    }
    
    _contentView = contentView;
    
    if (nil != contentView) {
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = 2;
        
        [self addSubview:self.contentView];
    }
    
}

- (CHMessageContentView*)contentView
{
    return _contentView;
}

- (instancetype)init
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self = [super initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        
        
        
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis] autorelease];
        horizontalMotionEffect.minimumRelativeValue = @(-30);
        horizontalMotionEffect.maximumRelativeValue = @(30);
        
        UIInterpolatingMotionEffect *verticalMotionEffect = [[[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis] autorelease];
        verticalMotionEffect.minimumRelativeValue = @(-30);
        verticalMotionEffect.maximumRelativeValue = @(30);
        
        UIMotionEffectGroup *group = [[UIMotionEffectGroup new] autorelease];
        group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
        [self addMotionEffect:group];
    }
    
    return self;
}


- (void)showWithContentView:(CHMessageContentView*)contentView
{
    self.alpha = 0.0f;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    self.userInteractionEnabled = YES;
    
    
    [self setContentView:contentView];
    
    
    CGAffineTransform scale = CGAffineTransformMakeScale(5, 5);
    self.transform = scale;
    [[[UIApplication sharedApplication] windows][0] addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
        
        self.window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        self.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    }];
    
}



- (void)dismiss
{
    self.userInteractionEnabled = NO;
    
    CATransform3D currentTransform = self.contentView.layer.transform;
    
    CGFloat startRotation = [[self.contentView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
    
    self.contentView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    self.contentView.layer.opacity = 1.0f;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.contentView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.contentView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
    
    [self.contentView removeMotionEffect:_group];
    _group = nil;
    
    [self setContentView:nil];
}

- (void)dealloc
{
    [_contentView release], _contentView = nil;
    
    [super dealloc];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation CHMessageContentView

- (id)init
{
    return [self initWithHeight:100];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = frame.size.height;
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    }
    
    return self;
}


- (id)initWithSize:(CGSize)size{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return [self initWithFrame:CGRectMake(
                                          (screenSize.width - size.width) / 2.0f,
                                          (screenSize.height - size.height) / 2.0f,
                                          size.width,
                                          size.height)];
}


- (id)initWithHeight:(CGFloat)height{
    return [self initWithSize:CGSizeMake(messageView_defaultWidth, height)];
}
@end





