//
//  UIColor+Config.m
//
//  Created by creatino@coach360.net on 4/01/14.
//  Copyright (c) 2014 Great Oak, Inc. All rights reserved.
//

#import "UIColor+Config.h"


@implementation UIColor (Config)


+ (UIColor *) coach360BlueColor
{
    return [UIColor colorWithRed:0.15 green:0.6 blue:0.98 alpha:1];
}

+ (UIColor *) coach360LightBlueColor
{
    return [UIColor colorWithRed:0.26 green:0.78 blue:0.89 alpha:1];
}

+ (UIColor *) coach360ColorFF8833WithOpacity
{
    return [UIColor colorWithRed:1.0 green:(float)0x88/0xff blue:(float)0x33/0xff alpha:0.5];
}
+ (UIColor *) facebookButtonColor
{
    return [UIColor colorWithRed:(float)0x53/0xff green:(float)0x7b/0xff blue:(float)0xbd/0xff alpha:1];
}
+ (UIColor *) facebookButtonColorWithOpacity
{
    return [UIColor colorWithRed:(float)0x53/0xff green:(float)0x7b/0xff blue:(float)0xbd/0xff alpha:0.5];
}

+ (UIColor *) coach360Color333333
{
    return [UIColor colorWithRed:(float)0x33/0xff green:(float)0x33/0xff blue:(float)0x33/0xff alpha:1];
}


+ (UIColor *) coach360LightOrangeColor
{
    return [UIColor colorWithRed:0.98 green:0.71 blue:0.53 alpha:1];
}


+ (UIColor *) coach360GreenColor
{
    return [UIColor colorWithRed:0.23 green:0.69 blue:0.17 alpha:1];
}

+ (UIColor *) coach360LightGreenColor
{
    return [UIColor colorWithRed:0.43 green:0.79 blue:0.44 alpha:1];
}



+ (UIColor *) coach360BackgroundWhiteColor
{
    return [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
}

+ (UIColor *) coach360ProgressBackgroundColor
{
    return [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
}

+ (UIColor *) coach360ProfileBackgroundWhiteColor
{
    return [UIColor colorWithRed:0x59/0xff green:0x4a/0xff blue:0x3e/0xff alpha:1];
}

+ (UIColor *) thumbnailLoadingColor
{
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

+ (UIColor *) thumbnailLoadingFailColor
{
    return [UIColor colorWithRed:0xee/0xff green:0x00/0xff blue:0x00/0xff alpha:0.5];
}

+ (UIColor *) coach360DarkBackgroundWhiteColor
{
    return [UIColor colorWithRed:0.95 green:0.93 blue:0.92 alpha:1];
}


+ (UIColor *) coach360LightGrayColor
{
    return [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
}

+ (UIColor *) coach360GrayColor
{
    return [UIColor coach360Color999999];
}

+ (UIColor *) coach360DarkGrayColor
{
    return [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
}

+ (UIColor *) coach360LightBrownColor
{
    return [UIColor colorWithRed:0.74 green:0.64 blue:0.57 alpha:1];
}

+ (UIColor *) coach360HeaderColor
{
    return [UIColor colorWithRed:(float)0xF7/0xFF green:(float)0xF7/0xFF blue:(float)0xF7/0xFF alpha:1];
}

+ (UIColor *) navBarColor
{
    return [UIColor coach360ColorFFFFFF];
}


+ (UIColor *) navBarButtonColor
{
    return [UIColor coach360ColorFF8833];
}

+ (UIColor *) navTitleColor
{
    return [UIColor coach360BlueColor];
}

+ (UIColor *) navSubtitleColor
{
    return [UIColor coach360LightBlueColor];
}



+ (UIColor *)menuTextColor
{
    return [UIColor colorWithWhite:1.0 alpha:0.65];
}

+ (UIColor *)menuItemBackgroundColor
{
    return [UIColor colorWithWhite:1.0 alpha:0.15];
}

+ (UIColor *)menuItemSelectedBackgroundColor
{
    return [UIColor colorWithWhite:0.5 alpha:1.0];
}


#pragma mark Left Nav Menu Colors

+ (UIColor *) leftNavBackgroundColor
{
    return [UIColor colorWithWhite:0.85 alpha:1.0];
}

+ (UIColor *) leftNavMenuItemColor
{
    return [UIColor colorWithWhite:1.0 alpha:1.0];
}

+ (UIColor *) leftNavCellBoarderColor
{
    return [UIColor colorWithRed:(float)0x66/0xff green:(float)0x66/0xff blue:(float)0x66/0xff alpha:1];
}

+ (UIColor *) leftNavMenuItemCircleColor
{
    return [UIColor colorWithWhite:1.0 alpha:0.1];
}

+ (UIColor *) leftNavMenuItemCircleImageColor
{
    return [UIColor colorWithWhite:1.0 alpha:1.0];
}

+ (UIColor *) leftNavMenuTitleColor
{
    return [UIColor colorWithWhite:1.0 alpha:0.2];
}


#pragma mark Login Screen Colors

+ (UIColor *) loginBackgroundColor
{
    return [UIColor colorWithWhite:0.98 alpha:1.0];
}

+ (UIColor *) loginTitleColor
{
    return [UIColor colorWithWhite:0.25 alpha:1.0];
}

+ (UIColor *) loginButtonColor
{
    return [UIColor coach360ColorFF8833];
}

+ (UIColor *) loginButtonTextColor
{
    return [UIColor colorWithWhite:1.0 alpha:1.0];
}

+ (UIColor *) loginLegalLinkColor
{
    return [UIColor colorWithWhite:0.5 alpha:1.0];
}


#pragma mark Settings Colors

+ (UIColor *) settingBackgroundColor
{
    return [UIColor colorWithWhite:0.95 alpha:1.0];
}

+ (UIColor *) settingSectionTitleColor
{
    return [UIColor coach360Color999999];
}

+ (UIColor *) settingTitleColor
{
    return [UIColor coach360Color333333];
}

+ (UIColor *) settingDescrColor
{
    return [UIColor coach360Color999999];
}

+ (UIColor *)settingItemSelectedBackgroundColor
{
    return [UIColor coach360ColorFFFFFF];
}


+ (UIColor *) settingsItemCircleColor
{
    return [UIColor colorWithWhite:1.0 alpha:1.0];
}

+ (UIColor *) settingsIconColor
{
    return [UIColor coach360ColorFF8833];
}



+ (UIColor *) accountsButtonTextColor
{
    return [UIColor colorWithWhite:1.0 alpha:1.0];
}

+ (UIColor *) coach360ColorFFFFFF
{
    return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
}

+ (UIColor *) coach360ColorFF8833
{
    return [UIColor colorWithRed:(float)0xff/0xff green:(float)0x88/0xff blue:(float)0x33/0xff alpha:1];
}

+ (UIColor *) coach360ColorF7F7F7
{
    return [UIColor colorWithRed:(float)0xf7/0xff green:(float)0xf7/0xff blue:(float)0xf7/0xff alpha:1];
}

+ (UIColor *) coach360ColorCCCCCC
{
    return [UIColor colorWithRed:(float)0xcc/0xff green:(float)0xcc/0xff blue:(float)0xcc/0xff alpha:1];
}

+ (UIColor *) coach360ColorCC3333
{
    return [UIColor colorWithRed:(float)0xcc/0xff green:(float)0x33/0xff blue:(float)0x33/0xff alpha:1];
}

+ (UIColor *) coach360Color33CC00
{
    return [UIColor colorWithRed:(float)0x33/0xff green:(float)0xcc/0xff blue:0.0 alpha:1];
}

+ (UIColor *) coach360Color33CCFF
{
    return [UIColor colorWithRed:(float)0x33/0xff green:(float)0xcc/0xff blue:(float)0xff/0xff alpha:1];
}

+ (UIColor *) coach360Color4C4C4C
{
    return [UIColor colorWithRed:(float)0x4C/0xff green:(float)0x4C/0xff blue:(float)0x4C/0xff alpha:1];
}

+ (UIColor *) coach360Color4D4D4D
{
    return [UIColor colorWithRed:(float)0x4D/0xff green:(float)0x4D/0xff blue:(float)0x4D/0xff alpha:1];
}

+ (UIColor *) coach360Color999999
{
    return [UIColor colorWithRed:(float)0x99/0xff green:(float)0x99/0xff blue:(float)0x99/0xff alpha:1];
}

+ (UIColor *) coach360Color0095FF
{
    return [UIColor colorWithRed:(float)0x00/0xff green:(float)0x95/0xff blue:(float)0xff/0xff alpha:1];
}
+ (UIColor *) coach360Color555555WithOpacity
{
    return [UIColor colorWithRed:(float)0x55/0xff green:(float)0x55/0xff blue:(float)0x55/0xff alpha:0.5];
}

+ (UIColor *) coach360Color808080
{
    return [UIColor colorWithRed:(float)0x80/0xff green:(float)0x80/0xff blue:(float)0x80/0xff alpha:1];
}

+ (UIColor *) coach360ColorFFCC00
{
    return [UIColor colorWithRed:1.0 green:(float)0xcc/0xff blue:0.0 alpha:1];
}

+ (UIColor *) coach360Color66CC66
{
    return [UIColor colorWithRed:(float)0x66/0xff green:(float)0xcc/0xff blue:(float)0x66/0xff alpha:1];
}

+ (UIColor *) coach360Color66CC33
{
    return [UIColor colorWithRed:(float)0x66/0xff green:(float)0xcc/0xff blue:(float)0x33/0xff alpha:1];
}

+ (UIColor *) coach360Color00CCFF
{
    return [UIColor colorWithRed:0.0 green:(float)0xcc/0xff blue:1.0 alpha:1];
}

+ (UIColor *) coach360ColorAAAAAA
{
    return [UIColor colorWithRed:(float)0xAA/0xff green:(float)0xAA/0xff blue:(float)0xAA/0xff alpha:1];
}

+ (UIColor *) coach360ColorE52E2E
{
    return [UIColor colorWithRed:(float)0xE5/0xff green:(float)0x2E/0xff blue:(float)0x2E/0xff alpha:1];
}
+ (UIColor *) coach360ColorEEEEEE
{
    return [UIColor colorWithRed:(float)0xee/0xff green:(float)0xee/0xff blue:(float)0xee/0xff alpha:1];
}

+ (UIColor *) coach360ColorFF3333
{
    return [UIColor colorWithRed:(float)0xFF/0xff green:(float)0x33/0xff blue:(float)0x33/0xff alpha:1];
}
@end
