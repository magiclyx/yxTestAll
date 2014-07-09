//
//  attributeStringViewController.m
//  testNavigation
//
//  Created by Yuxi Liu on 7/2/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "attributeStringViewController.h"


#import <CoreText/CoreText.h>

@interface attributeStringViewController ()
-(NSMutableAttributedString *)_getAttributedString;
@end

@implementation attributeStringViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UILabel *textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)] autorelease];
    NSAttributedString *attributeString = [self _getAttributedString];
    [textLabel setAttributedText:attributeString];
    
    [self.view addSubview:textLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(NSMutableAttributedString *)_getAttributedString{
    //创建一个NSMutableAttributedString
    NSMutableAttributedString *attriString = [[[NSMutableAttributedString alloc] initWithString:@"Come on, baby! Come on, baby!Come on,baby!"]autorelease];
    
    //NSForegroundColorAttributeName
    //kCTForegroundColorAttributeName
    //把this的字体颜色变为红色
    [attriString addAttribute:(NSString *)NSForegroundColorAttributeName
                        value:(id)[UIColor redColor].CGColor
                        range:NSMakeRange(0, 4)];
    //把is变为黄色
    [attriString addAttribute:(NSString *)NSForegroundColorAttributeName
                        value:(id)[UIColor yellowColor].CGColor
                        range:NSMakeRange(5, 16)];
    
    
//    //改变this的字体，value必须是一个CTFontRef
//    [attriString addAttribute:(NSString *)kCTFontAttributeName
//                        value:(id)CTFontCreateWithName((CFStringRef)[UIFont boldSystemFontOfSize:14].fontName,14,NULL)
//                        range:NSMakeRange(0, 4)];
//    //给this加上下划线，value可以在指定的枚举中选择
//    [attriString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
//                        value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble]
//                        range:NSMakeRange(0, 4)];
    
    /*
     换行的实现
     
     如果想要计算NSAttributedString所要的size，就需要用到这个API：
     CTFramesetterSuggestFrameSizeWithConstraints，用NSString的sizeWithFont算多行时会算不准的，因为在CoreText里，行间距也是你来控制的。
     设置行间距和换行模式都是设置一个属性：kCTParagraphStyleAttributeName，这个属性里面又分为很多子
     属性，其中就包括
     kCTLineBreakByCharWrapping
     kCTParagraphStyleSpecifierLineSpacingAdjustment
     设置如下：
     */
    
    
    /*
     //-------------取消注释，实现换行-------------
     
     CTParagraphStyleSetting lineBreakMode;
     CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
     lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
     lineBreakMode.value = &lineBreak;
     lineBreakMode.valueSize = sizeof(CTLineBreakMode);
     //行间距
     CTParagraphStyleSetting LineSpacing;
     CGFloat spacing = 4.0;  //指定间距
     LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
     LineSpacing.value = &spacing;
     LineSpacing.valueSize = sizeof(CGFloat);
     
     CTParagraphStyleSetting settings[] = {lineBreakMode,LineSpacing};
     CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);   //第二个参数为settings的长度
     [attriString addAttribute:(NSString *)kCTParagraphStyleAttributeName
     value:(id)paragraphStyle
     range:NSMakeRange(0, attriString.length)];
     */
    
    return attriString;
}




@end
