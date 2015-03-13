//
//  UIImage+skin.m
//  yxTestAll
//
//  Created by Yuxi Liu on 3/3/15.
//  Copyright (c) 2015 Yuxi Liu. All rights reserved.
//

#import "UIImage+skin.h"

@implementation UIImage (skin)

+ (UIImage*)colorAnImage:(UIColor*)color image:(UIImage*)image
{
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;
{
    CGRect rect = CGRectMake(0.0f, 0.5f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}



@end
