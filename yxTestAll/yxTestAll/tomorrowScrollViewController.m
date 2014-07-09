//
//  BScrollViewController.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/16/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "tomorrowScrollViewController.h"
#import "protypeManager.h"
#import "skinManager.h"

/**
 *  配置页View
 */
@interface _TomorowConfigView : UIView

@end

////////////////////////////////////////////////////////////////////////////////
/**
 *  记事本View
 */
@interface _TomorowDocView : UIView

@end
////////////////////////////////////////////////////////////////////////////////

/**
 *  main controller
 */
@interface tomorrowScrollViewController ()<UIScrollViewDelegate>{
    UIScrollView* _scrollView;
    _TomorowDocView *_docView;
    _TomorowConfigView *_configView;
    
    BOOL _isConfig;
}

@property(readonly, nonatomic) UIScrollView *scrollView;
@property(readonly, nonatomic) _TomorowDocView *docView;
@property(readonly, nonatomic) _TomorowConfigView *configView;

@property(readwrite, nonatomic) BOOL isConfig;


- (void) _setUpScrollViewForConfig;
- (void) _setUpScrollViewForDoc;

@end

@implementation tomorrowScrollViewController

@synthesize scrollView = _scrollView;
@synthesize docView = _docView;
@synthesize configView = _configView;
@synthesize isConfig = _isConfig;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isConfig = NO;
        _scrollView = nil;
        _docView = nil;
        _configView = nil;
    }
    return self;
}


-(void)dealloc{
    
    [_scrollView release], _scrollView = nil;
    [_docView release], _docView = nil;
    [_configView release], _configView = nil;
    
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated{
    CGRect bounds = self.view.bounds;
    
    /*创建滚动条*/
    _scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    /*设置代理*/
    [_scrollView setDelegate:self];
    
    /*设置滚动条属性*/
    [_scrollView setScrollEnabled:YES]; //可滚动
    [_scrollView setShowsVerticalScrollIndicator:NO]; //垂直滚动条
    [_scrollView setShowsHorizontalScrollIndicator:YES]; //水平滚动条
    [_scrollView setBackgroundColor:[UIColor blackColor]]; //背景色
    [_scrollView setAlwaysBounceHorizontal:YES];
    
    
    [self.view addSubview:_scrollView];
    
    
    
    /*
     创建docView
     */
    CGRect docRect = CGRectMake(0, 0, bounds.size.width * 2, bounds.size.height);
    _docView = [[_TomorowDocView alloc] initWithFrame:docRect];
    _docView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [_scrollView addSubview:_docView];
    
    
    
    
    /*
     创建configView
     */
    
    _configView = [[_TomorowConfigView alloc] initWithFrame:CGRectMake(bounds.size.width * 2, 0, bounds.size.width, bounds.size.height)];
    [_scrollView addSubview:_configView];
    _configView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    
    _scrollView.contentSize = CGSizeMake(bounds.size.width * 3, bounds.size.height);
    _scrollView.contentOffset = CGPointMake(0, 0);
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, bounds.size.width * -1);

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma scrollView delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    CGPoint pt = [scrollView contentOffset];
    CGRect bounds = _scrollView.bounds;
    
    if (self.isConfig) {
        if (pt.x < 590/*610*/) {
            [UIView animateWithDuration:0.6f animations:^{
                _scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
                 _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, bounds.size.width * -1);
            }];
            
            _isConfig = NO;
        }
    }
    else{
        if (pt.x > /*350*/370) {
            [UIView animateWithDuration:0.6f animations:^{
                _scrollView.contentOffset = CGPointMake(bounds.size.width * 2, 0);
                _scrollView.contentInset = UIEdgeInsetsMake(0, bounds.size.width * -2, 0, 0);
            }];
            
            _isConfig = YES;
        }
    }
    
    
 
}



- (void) _setUpScrollViewForConfig{
    CGRect bounds = [_scrollView bounds];
    
    _scrollView.contentOffset = CGPointMake(bounds.size.width * 2, 0);
    _scrollView.contentInset = UIEdgeInsetsMake(0, bounds.size.width * -2, 0, 0);
    
    
    _isConfig = YES;
}
- (void) _setUpScrollViewForDoc{
    CGRect bounds = [_scrollView bounds];
    
    _scrollView.contentOffset = CGPointMake(0, 0);
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, bounds.size.width * -1);
    
    _isConfig = NO;
}



@end


////////////////////////////////////////////////////////////////////////////////

@implementation _TomorowDocView

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

-(void)drawRect:(CGRect)rect{
    UIImage* image = [[skinManager sharedManager] imageByName:@"tomorrow_background"];
    [image drawInRect:self.bounds];
    
    [@"一直向右拉，显示右侧的配置页" drawInRect:CGRectMake(30, 30, 300, 300) withAttributes:nil];
    [@"再向右拉，灰色的才是" drawInRect:CGRectMake(350, 30, 300, 300) withAttributes:nil];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation _TomorowConfigView

-(void)drawRect:(CGRect)rect{
    [[UIColor grayColor] set];
    [[UIBezierPath bezierPathWithRect:rect] fill];
    
    [@"我是配置页" drawInRect:CGRectMake(30, 30, 300, 300) withAttributes:nil];
}

@end




