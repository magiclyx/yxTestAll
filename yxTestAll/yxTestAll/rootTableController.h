//
//  rootTableController.h
//  testNavigation
//
//  Created by Yuxi Liu on 6/12/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "protypeManager.h"

@interface rootTableController : UIViewController

@property (retain, nonatomic) protypeInfo *info;


- (id)initWithProtypeInfo:(protypeInfo *)protypeInfo;
- (id)initWithProtypeKey:(NSString *)key;

- (void)reload;

@end

@interface testTableView : UIView;

@end