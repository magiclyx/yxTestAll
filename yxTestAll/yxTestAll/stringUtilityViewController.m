//
//  stringUtilityViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 12/3/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "stringUtilityViewController.h"

typedef enum truncateStyle{
    truncateStyle_overflow,
    truncateStyle_truncation,
    truncateStyle_dot_left,
    truncateStyle_dot_mid,
    truncateStyle_dot_right
}truncateStyle;

@interface stringUtilityViewController (){
    /*test string truncation*/
    NSString* _truncation_testString;
    UILabel* _truncation_label;
    UILabel* _truncation_slider_label;
    UISlider* _truncation_slider;
}
- (void)_truncation_sliderChanged:(id)sender;
- (NSString*)_truncation_stringWithWidth:(CGFloat)width;

- (NSString*) _truncateString:(NSString*)str withStyle:(truncateStyle)style width:(CGFloat)width andAttribute:(NSDictionary*)attrDict;

- (NSString*) _2truncateString:(NSString*)str width:(CGFloat)width andAttribute:(NSDictionary*)attrDict;
@end

@implementation stringUtilityViewController

-(instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        CGFloat screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
        
        
        CGFloat truncation_init_width = screenWidth;
        _truncation_testString = @"一二三四五六七八九十1234567890";
        
        _truncation_label = [[UILabel alloc] init];
        CGRect _truncation_label_frame = CGRectMake(0.0f, 10.0f, truncation_init_width, 30.0f);
        _truncation_label.backgroundColor = [UIColor grayColor];
        _truncation_label.text = _truncation_testString;
        _truncation_label.lineBreakMode = NSLineBreakByWordWrapping;
        [_truncation_label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_truncation_label setFrame:_truncation_label_frame];
        
        [self.view addSubview:_truncation_label];
        
        
        
        
        
        _truncation_slider_label = [[UILabel alloc] init];
        CGRect _truncation_slider_label_frame = CGRectMake(0, CGRectGetMaxY(_truncation_label_frame) + 14.0f, screenWidth, 10.0f);
        _truncation_slider_label.font = [UIFont systemFontOfSize:12];
        _truncation_slider_label.backgroundColor = [UIColor clearColor];
        _truncation_slider_label.text = [NSString stringWithFormat:@"%lf", truncation_init_width];
        _truncation_slider_label.textAlignment = NSTextAlignmentCenter;
        _truncation_slider_label.textColor = [UIColor blackColor];
        [_truncation_slider_label setFrame:_truncation_slider_label_frame];
        [self.view addSubview:_truncation_slider_label];
        
        
        
        
        
        _truncation_slider = [[UISlider alloc] init];
        CGRect _truncation_slider_frame = CGRectMake(10.0f,
                                                     CGRectGetMaxY(_truncation_slider_label_frame) + 7.0f,
                                                     self.view.frame.size.width - 20.0f,
                                                     20.0f);
        [_truncation_slider setMinimumValue:0.0f];
        [_truncation_slider setMaximumValue:screenWidth];
        [_truncation_slider setContinuous:NO];
        [_truncation_label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_truncation_slider setFrame:_truncation_slider_frame];
        [_truncation_slider setValue:truncation_init_width];
        [_truncation_slider addTarget:self action:@selector(_truncation_sliderChanged:) forControlEvents:UIControlEventTouchDragInside];
        [self.view addSubview:_truncation_slider];
        
        
        
        [self.view setAutoresizesSubviews:YES];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma utility

- (NSString*) _truncateString:(NSString*)str withStyle:(truncateStyle)style width:(CGFloat)width andAttribute:(NSDictionary*)attrDict{
    
    CGSize fontSize = [str sizeWithAttributes:attrDict];
    if(fontSize.width < width)
    return str;
    
    static NSString* dotString = @"...";
    static NSString* dotString2 = @"..";
    static NSString* dotString1 = @".";
    unsigned int strCount = (unsigned int)[str length];
    NSString* omittedString = @"";
    
    CGSize dotStringSize = [dotString sizeWithAttributes:attrDict];
    
    
    /*length pre judgement*/
    if(truncateStyle_dot_left == style  ||  truncateStyle_dot_mid == style  ||  truncateStyle_dot_right == style){
        if(width <= dotStringSize.width){
            CGSize dotStringSize2 = [dotString2 sizeWithAttributes:attrDict];
            CGSize dotStringSize1 = [dotString1 sizeWithAttributes:attrDict];
            
            
            if(width == dotStringSize.width){
                omittedString = dotString;
            }
            else if(width <= dotStringSize.width  &&  width >= dotStringSize2.width){
                omittedString = dotString2;
            }
            else if(width <= dotStringSize.width  &&  width >= dotStringSize1.width){
                omittedString = dotString1;
            }
            else{
                omittedString = @"";
            }
            
            
            return omittedString;
        }
        
    }
    
    
    
    
    
    
    if(truncateStyle_overflow == style){
        omittedString = str;
    }
    else if(truncateStyle_overflow == style){
        NSString* resultString = @"";
        for(int count = strCount-1; count>0; count--){
            resultString = [str substringWithRange:NSMakeRange(0, count)];
            CGSize testStringSize = [resultString sizeWithAttributes:attrDict];
            if(testStringSize.width < width)
            break;
        }
        
        omittedString = resultString;
    }
    else if(truncateStyle_dot_left == style){
        CGSize dotStringSize = [dotString sizeWithAttributes:attrDict];
        NSString* resultString = @"";
        for(int count = strCount-1; count>0; count--){
            resultString = [str substringWithRange:NSMakeRange(0, count)];
            CGSize testStringSize = [resultString sizeWithAttributes:attrDict];
            if(testStringSize.width+dotStringSize.width < width)
            break;
        }
        
        omittedString = [dotString stringByAppendingString:resultString];
    }
    else if(truncateStyle_dot_mid == style){
        CGSize dotStringSize = [dotString sizeWithAttributes:attrDict];
        unsigned int halfCount = strCount / 2;
        NSString* leftResultString = [str substringWithRange:NSMakeRange(0, halfCount)];
        NSString* rightResultString = [str substringWithRange:NSMakeRange(halfCount, strCount - halfCount)];;
        for(int count = 0; count<strCount; count+=2){
            int leftCount = (unsigned int)[leftResultString length];
            int rightCount = (unsigned int)[rightResultString length];
            
            leftResultString = [leftResultString substringWithRange:NSMakeRange(0, ((leftCount-1 >= 0)? leftCount-1 : 0))];
            CGSize leftResultSize = [leftResultString sizeWithAttributes:attrDict];
            CGSize rightResultSize = [rightResultString sizeWithAttributes:attrDict];
            if(leftResultSize.width + rightResultSize.width + dotStringSize.width < width)
            break;
            
            rightResultString = [rightResultString substringWithRange:NSMakeRange(1, ((rightCount-1 >= 0)? rightCount-1 : 0))];
            rightResultSize = [rightResultString sizeWithAttributes:attrDict];
            if(leftResultSize.width + rightResultSize.width + dotStringSize.width < width)
            break;
        }
        
        omittedString = [NSString stringWithFormat:@"%@%@%@", leftResultString, dotString, rightResultString];
    }
    else if(truncateStyle_dot_right == style){
        CGSize dotStringSize = [dotString sizeWithAttributes:attrDict];
        NSString* resultString = @"";
        for(int count = strCount-1; count>0; count--){
            resultString = [str substringWithRange:NSMakeRange(0, count)];
            CGSize testStringSize = [resultString sizeWithAttributes:attrDict];
            if(testStringSize.width+dotStringSize.width < width)
            break;
        }
        
        omittedString = [resultString stringByAppendingString:dotString];
    }
    
    return omittedString;
}

- (NSString*) _2truncateString:(NSString*)str width:(CGFloat)width andAttribute:(NSDictionary*)attrDict{
    
    CGSize fontSize = [str sizeWithAttributes:attrDict];
    if(fontSize.width < width)
    return str;
    
    static NSString* dotString = @"...";
    static NSString* dotString2 = @"..";
    static NSString* dotString1 = @".";
    unsigned int strCount = (unsigned int)[str length];
    NSString* omittedString = @"";
    
    CGSize dotStringSize = [dotString sizeWithAttributes:attrDict];
    
    
    /*length pre judgement*/
    if(width <= dotStringSize.width){
        CGSize dotStringSize2 = [dotString2 sizeWithAttributes:attrDict];
        CGSize dotStringSize1 = [dotString1 sizeWithAttributes:attrDict];
        
        
        if(width == dotStringSize.width){
            omittedString = dotString;
        }
        else if(width <= dotStringSize.width  &&  width >= dotStringSize2.width){
            omittedString = dotString2;
        }
        else if(width <= dotStringSize.width  &&  width >= dotStringSize1.width){
            omittedString = dotString1;
        }
        else{
            omittedString = @"";
        }
        
        
        return omittedString;
    }
    
    
    unsigned int halfCount = strCount / 2;
    NSString* leftResultString = [str substringWithRange:NSMakeRange(0, halfCount)];
    NSString* rightResultString = [str substringWithRange:NSMakeRange(halfCount, strCount - halfCount)];;
    for(int count = 0; count<strCount; count+=2){
        int leftCount = (unsigned int)[leftResultString length];
        int rightCount = (unsigned int)[rightResultString length];
        
        leftResultString = [leftResultString substringWithRange:NSMakeRange(0, ((leftCount-1 >= 0)? leftCount-1 : 0))];
        CGSize leftResultSize = [leftResultString sizeWithAttributes:attrDict];
        CGSize rightResultSize = [rightResultString sizeWithAttributes:attrDict];
        if(leftResultSize.width + rightResultSize.width + dotStringSize.width < width)
        break;
        
        rightResultString = [rightResultString substringWithRange:NSMakeRange(1, ((rightCount-1 >= 0)? rightCount-1 : 0))];
        rightResultSize = [rightResultString sizeWithAttributes:attrDict];
        if(leftResultSize.width + rightResultSize.width + dotStringSize.width < width)
        break;
    }
    
    omittedString = [NSString stringWithFormat:@"%@%@%@", leftResultString, dotString, rightResultString];
    
    
    
    return omittedString;
}

#pragma private
- (void)_truncation_sliderChanged:(id)sender
{
    CGFloat screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    CGRect oldFrame = [_truncation_label frame];
    CGFloat width = _truncation_slider.value;
    NSString* newString = [self _truncation_stringWithWidth:width];
    
    _truncation_label.text = newString;
    [_truncation_label setFrame:CGRectMake((screenWidth - width) / 2.0f,
                                            oldFrame.origin.y,
                                            width,
                                            oldFrame.size.height)];
    
    _truncation_slider_label.text = [NSString stringWithFormat:@"%lf", width];
}

- (NSString*)_truncation_stringWithWidth:(CGFloat)width
{
    //truncateStyle_dot_mid
    
    NSDictionary* fontDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [_truncation_label font], NSFontAttributeName,
                              [_truncation_label textColor], NSForegroundColorAttributeName,
                              nil];
    
    return [self _2truncateString:_truncation_testString width:width andAttribute:fontDict];
//    return [self _truncateString:_truncation_testString withStyle:truncateStyle_dot_mid width:width andAttribute:fontDict];
}

@end


