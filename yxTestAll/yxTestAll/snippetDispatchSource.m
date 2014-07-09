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
    
    [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerDo:) userInfo:nil repeats:YES] fire];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)_timerDo:(NSTimer *)timer{
    NSString* text = [_output text];
    text = [text stringByAppendingString:@"abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890\n"];
    [_output setText:text];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
