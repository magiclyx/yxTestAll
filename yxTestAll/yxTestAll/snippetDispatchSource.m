//
//  snippetDispatchSource.m
//  testNavigation
//
//  Created by Yuxi Liu on 7/7/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "snippetDispatchSource.h"
#import "outputView.h"

@interface snippetDispatchSource (){
    outputView* _output;
}
-(void)_timerDo:(NSTimer *)timer;
@end

@implementation snippetDispatchSource

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
    //[self.view setBackgroundColor:[UIColor redColor]];
    // Do any additional setup after loading the view.
    
    _output = [[outputView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_output];
    [self.view setAutoresizesSubviews:YES];
    [_output setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_timerDo:) userInfo:nil repeats:YES] fire];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)_timerDo:(NSTimer *)timer{
    
    static NSUInteger times = 0;
    
//    if (times > 50) {
//        return;
//    }
    
    NSString* testSnip = @"";
    for (int i=0; i<=15; i++) {
        testSnip = [testSnip stringByAppendingString:[NSString stringWithFormat:@"%ld, ", times]];
    }
    
    [_output testLog:testSnip];
    
    times++;
}


@end
