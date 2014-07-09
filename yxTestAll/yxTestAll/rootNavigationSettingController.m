//
//  rootNavigationSettingController.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/12/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "rootNavigationSettingController.h"

@interface rootNavigationSettingController (){

}

@end





@implementation rootNavigationSettingController

+ (id)settingController{
    return [[[[self class] alloc] init] autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)loadView{
    self.view = [[[settingView alloc] init] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end


////////////////////////////////////////////////////////////
@implementation settingView

-(void)drawRect:(CGRect)rect{
    [[UIColor yellowColor] set];
    [[UIBezierPath bezierPathWithRect:rect] fill];
}

@end
