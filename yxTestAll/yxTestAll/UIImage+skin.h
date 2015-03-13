//
//  UIImage+skin.h
//  yxTestAll
//
//  Created by Yuxi Liu on 3/3/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (skin)
+ (UIImage*)colorAnImage:(UIColor*)color image:(UIImage*)image;
+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;
@end
