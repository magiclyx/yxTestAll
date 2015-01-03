//
//  crashLogViewController.m
//  yxTestAll
//
//  Created by Yuxi Liu on 12/17/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "crashLogViewController.h"
#import "crashManager.h"
#import "logView.h"

@interface crashLogViewController (){
//    logView* _output;
}
-(void)_crashButtonPressed:(id)sender;
//-(void)_log:(NSString*)msg;
@end

@implementation crashLogViewController

#pragma mark lifecycle

-(instancetype)init
{
    self = [super init];
    if (self) {
        //_output = [[logView alloc] initWithFrame:CGRectZero];
        [[crashManager sharedManager] registCrashMonitor];
        
        NSUInteger continueCrashCount = [[crashManager sharedManager] continuousCrashCounter];
        
        [self log:[NSString stringWithFormat:@"continue crash count : %d", (int)continueCrashCount]];
        [self log:[NSString stringWithFormat:@"last crash time : %@", [[crashManager sharedManager] lastCrashDate] ]];
        [self log:[NSString stringWithFormat:@"%@", [[crashManager sharedManager] crashLog]]];
    }
    
    return self;
}

- (void)dealloc
{
    
    //[_output release], _output = nil;
    [[crashManager sharedManager] unregistCrashMonitor];
    
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    
    CGRect rect = [self.view bounds];
    
    CGFloat offsetY = 10.0f;
    
    UIView* logView = [self logView];
    
    logView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    logView.frame = CGRectMake(0,
                               offsetY,
                               rect.size.width,
                               300);
    
    
    offsetY += logView.frame.origin.y + logView.frame.size.height + 30.0f;
    UIButton* crashButton = [[UIButton alloc] init];
    [crashButton setTitle:@"Crash !!" forState:UIControlStateNormal];
    [crashButton.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [crashButton.layer setBorderWidth:2.0]; //边框宽度
    crashButton.frame = CGRectMake((rect.size.width - 100) / 2.0f,
                                   offsetY,
                                   100,
                                   50);
    crashButton.backgroundColor = [UIColor redColor];
    crashButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [crashButton addTarget:self action:@selector(_crashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view setAutoresizesSubviews:YES];
    [self.view addSubview:crashButton];
    
    [crashButton release];
    crashButton = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma private
-(void)_crashButtonPressed:(id)sender
{
    @throw [NSException exceptionWithName:@"testCrash" reason:@"for test" userInfo:nil];
}

//-(void)_log:(NSString*)msg
//{
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [_output log:msg];
//    });
//}


@end

