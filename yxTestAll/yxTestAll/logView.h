//
//  logView.h
//  yxTestAll
//
//  Created by Yuxi Liu on 7/28/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  日志视图
 */
@interface logView : UITableView

@property(readwrite, assign) CGFloat lineSpacing;

- (void)separateBar;
- (void)log:(NSString*)text;

@end
