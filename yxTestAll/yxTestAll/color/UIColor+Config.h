//
//  UIColor+Config.h
//
//  Created by creatino@coach360.net on 4/01/14.
//  Copyright (c) 2014 Great Oak, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_FONT_FAMILY                  @"HelveticaNeue-Light"
#define LIGHTFONT15                      [UIFont fontWithName:APP_FONT_FAMILY size:15]
#define LIGHTFONT20                      [UIFont fontWithName:APP_FONT_FAMILY size:20]
#define LIGHTFONT24                      [UIFont fontWithName:APP_FONT_FAMILY size:24]


@interface UIColor (Config)

+ (UIColor *) coach360BlueColor;
+ (UIColor *) coach360LightBlueColor;

+ (UIColor *) coach360LightOrangeColor;

+ (UIColor *) coach360GreenColor;
+ (UIColor *) coach360LightGreenColor;

+ (UIColor *) coach360BackgroundWhiteColor;
+ (UIColor *) coach360DarkBackgroundWhiteColor;
+ (UIColor *) coach360ProfileBackgroundWhiteColor;

+ (UIColor *) coach360ProgressBackgroundColor;

+ (UIColor *) thumbnailLoadingColor;
+ (UIColor *) thumbnailLoadingFailColor;

+ (UIColor *) coach360LightGrayColor;
+ (UIColor *) coach360GrayColor;
+ (UIColor *) coach360DarkGrayColor;

+ (UIColor *) coach360LightBrownColor;

+ (UIColor *) coach360HeaderColor;

+ (UIColor *) navBarColor;
+ (UIColor *) navBarButtonColor;
+ (UIColor *) navTitleColor;
+ (UIColor *) navSubtitleColor;


+ (UIColor *)menuTextColor;
+ (UIColor *)menuItemBackgroundColor;
+ (UIColor *)menuItemSelectedBackgroundColor;


//
//  Left Nav Menu Colors
//
+ (UIColor *) leftNavBackgroundColor;
+ (UIColor *) leftNavMenuItemColor;
+ (UIColor *) leftNavCellBoarderColor;
+ (UIColor *) leftNavMenuItemCircleColor;
+ (UIColor *) leftNavMenuItemCircleImageColor;
+ (UIColor *) leftNavMenuTitleColor;

//
//  Login Screen Colors
//
+ (UIColor *) loginBackgroundColor;
+ (UIColor *) loginTitleColor;
+ (UIColor *) loginButtonColor;
+ (UIColor *) loginButtonTextColor;
+ (UIColor *) loginLegalLinkColor;


//
//  Settings Colors
//
+ (UIColor *) settingBackgroundColor;
+ (UIColor *) settingSectionTitleColor;
+ (UIColor *) settingTitleColor;
+ (UIColor *) settingDescrColor;
+ (UIColor *) settingItemSelectedBackgroundColor;
+ (UIColor *) settingsItemCircleColor;
+ (UIColor *) settingsIconColor;

//
//  Acconts Module Colors
//
+ (UIColor *) accountsButtonTextColor;

//
//  Login Buttons
//
+ (UIColor *) coach360ColorFF8833WithOpacity;
+ (UIColor *) facebookButtonColor;
+ (UIColor *) facebookButtonColorWithOpacity;

+ (UIColor *) coach360ColorAAAAAA;
+ (UIColor *) coach360ColorFFFFFF;
+ (UIColor *) coach360ColorFF8833;
+ (UIColor *) coach360ColorF7F7F7;
+ (UIColor *) coach360ColorCCCCCC;
+ (UIColor *) coach360ColorCC3333;
+ (UIColor *) coach360Color33CC00;
+ (UIColor *) coach360Color33CCFF;
+ (UIColor *) coach360Color4C4C4C;
+ (UIColor *) coach360Color4D4D4D;
+ (UIColor *) coach360Color999999;
+ (UIColor *) coach360Color0095FF;
+ (UIColor *) coach360Color808080;
+ (UIColor *) coach360ColorE52E2E;
+ (UIColor *) coach360Color333333;
+ (UIColor *) coach360ColorFFCC00;
+ (UIColor *) coach360Color66CC66;
+ (UIColor *) coach360Color66CC33;
+ (UIColor *) coach360Color00CCFF;
+ (UIColor *) coach360ColorEEEEEE;
+ (UIColor *) coach360ColorFF3333;
+ (UIColor *) coach360Color555555WithOpacity;
@end
