//
//  test.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/19/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "zoomScrollViewController.h"

@interface zoomScrollViewController ()<UIScrollViewDelegate>{
    UIButton* _bt;
}
@end

@implementation zoomScrollViewController

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
    
    /*创建scrollView*/
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    /*创建一个按钮，用来测试缩放*/
    _bt = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 250, 50)];
    [_bt setTitle:@"按住alt键进行缩放" forState:UIControlStateNormal];
    _bt.backgroundColor = [UIColor redColor];
    [scrollView addSubview:_bt];
    
    
    
    /*设置delegate*/
    [scrollView setDelegate:self];
    
    /*缩放比例控制*/
    scrollView.maximumZoomScale = 3.0f;
    scrollView.minimumZoomScale = 0.1f;
    
    
    /*这个方法会调用delegate方法, 因此在此之前必须设置了delegate, 并在delegate中设置要缩放的view*/
    scrollView.zoomScale = 2.0f;
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma scrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _bt;
}

@end
