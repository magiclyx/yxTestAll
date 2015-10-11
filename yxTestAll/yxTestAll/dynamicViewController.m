//
//  dynamicViewController.m
//  yxTestAll
//
//  Created by LiuYuxi on 15/8/26.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import "dynamicViewController.h"

@interface dynamicViewController ()<UICollisionBehaviorDelegate>

@end

@implementation dynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    /*
     创建要支持动画的view
     */
    UIView *aView = [[[UIView alloc] initWithFrame:CGRectMake(100, 50, 100, 100)] autorelease];
    aView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:aView];
    self.square1 = aView;
    
    /*给aView添加一个角度，掉落的时候用*/
    aView.transform = CGAffineTransformRotate(aView.transform, 45);
    
    /*
     动画的播放者，动力行为（UIDynamicBehavior）的容器，添加到容器内的行为将发挥作用
     */
    UIDynamicAnimator* animator = [[[UIDynamicAnimator alloc] initWithReferenceView:self.view] autorelease];
    
    
    /*
     动力行为的描述，用来指定UIDynamicItem应该如何运动，即定义适用的物理规则。一般我们使用这个类的子类对象来对一组UIDynamicItem应该遵守的行为规则进行描述；
     */
    UIGravityBehavior* gravityBeahvior = [[[UIGravityBehavior alloc] initWithItems:@[aView]] autorelease];
    [animator addBehavior:gravityBeahvior];
    
    
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[aView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [animator addBehavior:collisionBehavior];
    collisionBehavior.collisionDelegate = self;
    
    
    self.animator = animator;
    self.gravityBeahvior = gravityBeahvior;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleAttachmentGesture:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan){
        
        CGPoint squareCenterPoint = CGPointMake(self.square1.center.x, self.square1.center.y - 100.0);
        CGPoint attachmentPoint = CGPointMake(-25.0, -25.0);
        
//        UIAttachmentBehavior* attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.square1 point:attachmentPoint attachedToAnchor:squareCenterPoint];
        
        UIAttachmentBehavior* attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.square1 attachedToAnchor:squareCenterPoint];
        
        self.attachmentBehavior = attachmentBehavior;
        [self.animator addBehavior:attachmentBehavior];
        
    } else if ( gesture.state == UIGestureRecognizerStateChanged) {
        
        [self.attachmentBehavior setAnchorPoint:[gesture locationInView:self.view]];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.attachmentBehavior];
    } 
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
