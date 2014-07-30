//
//  logLineView.h
//  yxTestAll
//
//  Created by Yuxi Liu on 7/28/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "logItem.h"

/**
 *  log 中每行cell的View
 */
@interface logLineView : UIView

@property(readwrite, retain, nonatomic) logItem* item;

@end
