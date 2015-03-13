//
//  CHTempView.m
//  coach360
//
//  Created by Yuxi Liu on 3/1/15.
//  Copyright (c) 2015 creatino@coach360.net. All rights reserved.
//

#import "CHTempView.h"

#import "color/UIColor+Config.h"


#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define VIEWWIDTH   300


#define APP_FONT_FAMILY                  @"HelveticaNeue-Light"
#define LIGHTFONT15                      [UIFont fontWithName:APP_FONT_FAMILY size:15]
#define LIGHTFONT20                      [UIFont fontWithName:APP_FONT_FAMILY size:20]
#define LIGHTFONT24                      [UIFont fontWithName:APP_FONT_FAMILY size:24]



@interface CHTempView ()
@property (nonatomic, readwrite, retain) UIDynamicAnimator *animator;
@property (nonatomic, readwrite, retain) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, readwrite, retain) UIGravityBehavior *gravityBehavior;
@property (nonatomic, readwrite, retain) UILabel *titleLabel;
@property (nonatomic, readwrite, retain) UIView *topPart;
@property (nonatomic, readwrite, retain) UIButton *cancelButton;
@property (nonatomic, readwrite, retain) NSArray *otherButtons;
@property (nonatomic, readwrite, retain) UIView *dialogView;
@end

@implementation CHTempView

#pragma mark -

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}




#pragma mark - Actions

- (void)show {
    self.alpha = 0.0;
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

- (void)dismiss {
    self.userInteractionEnabled = NO;
    
    CATransform3D currentTransform = self.dialogView.layer.transform;
    
    CGFloat startRotation = [[self.dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
    
    self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    self.dialogView.layer.opacity = 1.0f;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
    
}


#pragma mark - initializers


- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
    self = [super init];
    if (self) {
        _delegate = delegate;
        UIFont *font = LIGHTFONT15;
        
        CGFloat currentWidth = VIEWWIDTH;
        CGFloat extraHeight = 40;
        
        CGSize maximumSize = CGSizeMake(currentWidth, CGFLOAT_MAX);
        CGRect boundingRect = [message boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : font} context:nil];
        CGFloat height = boundingRect.size.height + 16.0+80+extraHeight;
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        
        self.dialogView = [[UIView alloc] initWithFrame:CGRectMake(10, (screenHeight-height)/2, VIEWWIDTH, height)];
        //        self.frame = CGRectMake(10, (screenHeight-height)/2, VIEWWIDTH, height);
        self.dialogView.backgroundColor = [UIColor coach360ColorFFFFFF];
        self.dialogView.layer.masksToBounds = YES;
        self.dialogView.layer.cornerRadius = 2;
        [self addSubview:self.dialogView];
        
//        /**/
//        {
//            //Title View
//            self.topPart = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH, 40)];
//            self.titleBackgroundColor = [UIColor clearColor];
//            [self.dialogView addSubview:self.topPart];
//            
//            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, VIEWWIDTH, 40)];
//            self.titleLabel.text = title;
//            self.titleLabel.textAlignment = NSTextAlignmentCenter;
//            self.titleLabel.font = LIGHTFONT24;
//            self.titleLabel.textColor = [UIColor coach360Color4C4C4C];
//            if(title.length)
//                [self.topPart addSubview:self.titleLabel];
//            
//            
//            //Message view
//            UITextView *messageView = [[UITextView alloc] init];
//            CGFloat newLineHeight = boundingRect.size.height + 36.0;
//            if (title.length)
//                messageView.frame = CGRectMake(5, 60, VIEWWIDTH - 5, newLineHeight);
//            else
//                messageView.frame = CGRectMake(5, 45, VIEWWIDTH - 5, newLineHeight);
//            messageView.text = message;
//            messageView.font = font;
//            messageView.textColor = [UIColor coach360Color4C4C4C];
//            messageView.editable = NO;
//            messageView.dataDetectorTypes = UIDataDetectorTypeAll;
//            messageView.userInteractionEnabled = NO;
//            messageView.textAlignment = NSTextAlignmentCenter;
//            [self.dialogView addSubview:messageView];
//        }
//        
//        
//        //buttons
//        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, height-extraHeight, VIEWWIDTH, extraHeight)];
//        
//        CALayer *horizontalBorder = [CALayer layer];
//        horizontalBorder.frame = CGRectMake(0.0f, 0.0f, buttonView.frame.size.width, 0.5f);
//        horizontalBorder.backgroundColor = [UIColor colorWithRed:0.824 green:0.827 blue:0.831 alpha:1.000].CGColor;
//        [buttonView.layer addSublayer:horizontalBorder];
//        
//        [self.dialogView addSubview:buttonView];
//        
//        if (cancelButtonTitle) {
//            self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            if ([otherButtonTitles count] == 1) {
//                self.cancelButton.frame = CGRectMake(0, 0, 141, 40);
//            }
//            else self.cancelButton.frame = CGRectMake(0, CGRectGetHeight(buttonView.frame)-40, VIEWWIDTH, 40);
//            
//            [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
//            self.normalCancelButtonForgroundColor = [UIColor coach360ColorFF8833];
//            //            self.highlightedCancelButtonForegroundColor = [UIColor colorWithRed:0.769 green:0.000 blue:0.071 alpha:1.000];
//            //            self.highlightedCancelButtonBackgroundColor = [UIColor colorWithRed:0.933 green:0.737 blue:0.745 alpha:1.000];
//            self.cancelButton.titleLabel.font = LIGHTFONT20;
//            [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//            self.cancelButton.tag = 0;
//            [self.cancelButton addTarget:self action:@selector(alertButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
//            [buttonView addSubview:self.cancelButton];
//        }
        
        
        
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-20);
        horizontalMotionEffect.maximumRelativeValue = @(20);
        
        UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-20);
        verticalMotionEffect.maximumRelativeValue = @(20);
        
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
        [self addMotionEffect:group];
        
    }
    return self;
}

@end
