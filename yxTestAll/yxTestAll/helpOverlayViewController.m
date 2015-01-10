//
//  helpOverlayViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 1/8/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "helpOverlayViewController.h"
#import "helpOverlay.h"

//#import "popoverWindow.h"

@implementation helpOverlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [helpOverlay showHelpOverlayWithImage:[UIImage imageNamed:@"popOver.png"]];
    

}

@end
