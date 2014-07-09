//
//  ctRunDelegateViewController.m
//  testNavigation
//
//  Created by Yuxi Liu on 7/3/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "ctRunDelegateViewController.h"

#import <CoreText/CoreText.h>


@interface ctRunDelegateViewController (){

}

@end

@implementation ctRunDelegateViewController

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
    
    textRenderView* renderView = [[[textRenderView alloc] initWithFrame:self.view.bounds] autorelease];
    [self.view setAutoresizesSubviews:YES];
    [renderView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:renderView];
    [self.view setBackgroundColor:[UIColor redColor]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end




//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

@interface textRenderView(){
    NSMutableAttributedString *_content;
    NSString *_originalStr;
    CTFrameRef _frame;
}

-(void)_buildAttribute;

void _runDelegateDeallocCallback( void* refCon ); //CTRun的回调，销毁内存的回调
CGFloat _runDelegateGetAscentCallback( void *refCon ); //CTRun的回调，获取高度  字幕上半部分
CGFloat _runDelegateGetDescentCallback(void *refCon); //CTRun的回调，获取高度  字幕下半部分
CGFloat _runDelegateGetWidthCallback(void *refCon); //CTRun的回调，获取宽度


@end

@implementation textRenderView


-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _content = nil;
        _originalStr = [@"Hello world yg sdfsdafsdafsfsdfsdfsadfsdfsdfsfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsfsdfsdfsdfgg!" retain];
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    
    return self;
}

-(void)dealloc{
    [_originalStr release], _originalStr = nil;
    
    [super dealloc];
}



- (void)drawRect:(CGRect)rect
{
    //设置NSMutableAttributedString的所有属性
    [self _buildAttribute];
    
    NSLog(@"rect:%@",NSStringFromCGRect(rect));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //设置context的ctm，用于适应core text的坐标体系
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, rect.size.height + 10.f);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //设置CTFramesetter
    CTFramesetterRef framesetter =  CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_content);
    
    //创建绘制路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, rect.size.height + 10));
    
    //创建CTFrame
    _frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _content.length), path, NULL);
    
    //把文字内容绘制出来
    CTFrameDraw(_frame, context);
    
    //获取画出来的内容的行数
    CFArrayRef lines = CTFrameGetLines(_frame);
    
    //获取每行的原点坐标
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), lineOrigins);
    NSLog(@"line count = %ld",CFArrayGetCount(lines));
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        
        //获取每行的宽度和高度
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        NSLog(@"ascent = %f,descent = %f,leading = %f",lineAscent,lineDescent,lineLeading);
        
        //获取每个CTRun
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        NSLog(@"run count = %ld",CFArrayGetCount(runs));
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            //获取每个CTRun
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            //调整CTRun的rect
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            NSLog(@"width = %f",runRect.size.width);
            CGFloat lineAscent;
            CGFloat lineDescent;
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
            
            runRect=CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            
            NSString *imageName = [attributes objectForKey:@"imageName"];
            //图片渲染逻辑，把需要被图片替换的字符位置画上图片
            if (imageName) {
                UIImage *image = [UIImage imageNamed:imageName];
                if (image) {
                    CGRect imageDrawRect;
                    imageDrawRect.size = CGSizeMake(30, 30);
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y - lineDescent;
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
                    CGContextStrokeRect(context, imageDrawRect);
                }
            }
            
            
        }
    }
    CGContextRestoreGState(context);
}

//接受触摸事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //获取UITouch对象
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    NSLog(@"touch:%@",NSStringFromCGPoint(location));
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(_frame);
    CGPoint origins[CFArrayGetCount(lines)];
    //获取每行的原点坐标
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    for (int i= 0; i < CFArrayGetCount(lines); i++)
    {
        CGPoint origin = origins[i];
        CGPathRef path = CTFrameGetPath(_frame);
        //获取整个CTFrame的大小
        CGRect rect = CGPathGetBoundingBox(path);
        NSLog(@"origin:%@",NSStringFromCGPoint(origin));
        NSLog(@"rect:%@",NSStringFromCGRect(rect));
        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        NSLog(@"y:%f",y);
        //判断点击的位置处于那一行范围内
        if ((location.y <= y) && (location.x >= origin.x))
        {
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    
    location.x -= lineOrigin.x;
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    NSLog(@"index:%ld",index);
    //判断点击的字符是否在需要处理点击事件的字符串范围内，这里是hard code了需要触发事件的字符串范围
    if (index>=1&&index<=10) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"click event" message:[_originalStr substringWithRange:NSMakeRange(0, 10)] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [alert show];
    }
    
}


//创建NSMutableAttributedString，解析所有触发点击事件和替换所有需要显示图片的位置
-(void)_buildAttribute{
    
    _content = [[NSMutableAttributedString alloc]initWithString:_originalStr];
    
    
    
    //创建图片的名字
    NSString *imgName = @"d_aini.png";
    
    
    //设置CTRun的回调，用于针对需要被替换成图片的位置的字符，可以动态设置图片预留位置的宽高
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = _runDelegateDeallocCallback;
    imageCallbacks.getAscent = _runDelegateGetAscentCallback;
    imageCallbacks.getDescent = _runDelegateGetDescentCallback;
    imageCallbacks.getWidth = _runDelegateGetWidthCallback;
    
    
    //创建CTRun回调
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, imgName);
    CTRunDelegateRef runDelegate2 = CTRunDelegateCreate(&imageCallbacks, NULL);
    
    //这里为了简化解析文字，所以直接认为最后一个字符是需要显示图片的位置，对需要显示图片的位置，都用空字符来替换原来的字符，空格用于给图片留位置
    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];
    
    //设置图片预留字符使用CTRun回调
    [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(id)runDelegate range:NSMakeRange(0, 1)];
    
//    [_content addAttribute:(NSString *)kCTRunDelegateAttributeName value:(id)runDelegate2 range:NSMakeRange(0, _originalStr.length)];
    
    CFRelease(runDelegate);
    
    //设置图片预留字符使用一个imageName的属性，区别于其他字符
    [imageAttributedString addAttribute:@"imageName" value:imgName range:NSMakeRange(0, 1)];
    
    [_content appendAttributedString:imageAttributedString];
    
    [_content appendAttributedString:[[NSAttributedString alloc] initWithString:@"abdfdsfsf" attributes:[NSDictionary dictionaryWithObject:(id)CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 16, NULL) forKey:(NSString *)kCTFontAttributeName]]];
    
    
    //换行模式，设置段落属性
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    CTParagraphStyleSetting settings[] = {
        lineBreakMode
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)style forKey:(id)kCTParagraphStyleAttributeName ];
    
    [_content addAttributes:attributes range:NSMakeRange(0, [_content length])];
    [_content addAttribute:(NSString *)kCTFontAttributeName  value:(id)CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 16, NULL) range:NSMakeRange(0, [_originalStr length])];
    
    //这里对需要进行点击事件的字符heightlight效果，这里简化解析过程，直接hard code需要heightlight的范围
    [_content addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[UIColor blueColor]CGColor] range:NSMakeRange(0, 10)];
}

#pragma mark ctRun-delegate
//CTRun的回调，销毁内存的回调
void _runDelegateDeallocCallback( void* refCon ){
    
}

//CTRun的回调，获取高度
CGFloat _runDelegateGetAscentCallback( void *refCon ){
    
    if (NULL == refCon) {
        return 100;
    }
    else{
        NSString *imageName = (NSString *)refCon;
        CTFontRef ctfont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 16, NULL);
        CGFloat a = CTFontGetAscent(ctfont);
        CGFloat d = CTFontGetDescent(ctfont);
        
        return a + ([UIImage imageNamed:imageName].size.height - a - d) / 2;
        return 0.;
        return [UIImage imageNamed:imageName].size.height;
        
    }
    
    //return 2;
}

CGFloat _runDelegateGetDescentCallback(void *refCon){
    
    if (NULL == refCon) {
        return 0;
    }
    else{
        NSString *imageName = (NSString *)refCon;
        CTFontRef ctfont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 16, NULL);
        CGFloat a = CTFontGetAscent(ctfont);
        CGFloat d = CTFontGetDescent(ctfont);
        
        return d + ([UIImage imageNamed:imageName].size.height - a - d) / 2;
        return 0.;
    }
    
    //return 0;
}
//CTRun的回调，获取宽度
CGFloat _runDelegateGetWidthCallback(void *refCon){
    
    if (NULL == refCon) {
        return 0;
    }
    else
    {
        NSString *imageName = (NSString *)refCon;
        return [UIImage imageNamed:imageName].size.width;
    }
}
@end
