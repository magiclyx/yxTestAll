//
//  AppDelegate.h
//  testNavigation
//
//  Created by Yuxi Liu on 6/12/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "rootViewController.h"
#import "rootNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) rootViewController *rootController;
@property (retain, nonatomic) rootNavigationController *rootNavigation;

@end
