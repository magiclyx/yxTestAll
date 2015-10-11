//
//  luaListViewController.m
//  yxTestAll
//
//  Created by LiuYuxi on 15/5/3.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import "luaListViewController.h"
#import "luaConfigList.h"
#import "luaEngine_oc.h"

#import "luaLib_setting.h"

@interface luaListViewController ()<luaConfigListDelegate>
{
    UIButton* _settingButton;
    luaEngine_oc* _luaEngine;
    
    luaLib_setting* _settting_lib;
}

- (void)_test;
- (void)_showSettingList:(id)sender;

@end

@implementation luaListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _settting_lib = [[luaLib_setting alloc] init];
        
        /*load stdlib*/
        NSString* stdLibPath = [[NSBundle mainBundle] resourcePath] ;
        stdLibPath = [stdLibPath stringByAppendingPathComponent:@"luaScript"];
        stdLibPath = [stdLibPath stringByAppendingPathComponent:@"stdlib"];
        
        _luaEngine = [[luaEngine_oc alloc] initWithStdLibPath:stdLibPath];
        
        [_luaEngine RegistObject:_settting_lib];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor redColor]];
    
    _settingButton = [[[UIButton alloc] initWithFrame:CGRectMake(60, 30, 200, 50)] autorelease];
    
    [_settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [_settingButton setBackgroundColor:[UIColor grayColor]];
    [_settingButton addTarget:self action:@selector(_showSettingList:) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:_settingButton];
    
    
    UIButton* testButton = [[[UIButton alloc] initWithFrame:CGRectMake(60, 100, 200, 50)] autorelease];
    
    [testButton setTitle:@"test" forState:UIControlStateNormal];
    [testButton setBackgroundColor:[UIColor grayColor]];
    [testButton addTarget:self action:@selector(_test) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:testButton];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    
    [_luaEngine release], _luaEngine = nil;
    
    [_settting_lib release], _settting_lib = nil;
    
    [super dealloc];
}


#pragma mark delegate-configList
- (void)configList:(luaConfigList*)list didSelectScript:(NSString*)scriptPath inTable:(UITableView*)table
{
    if (nil != scriptPath)
    {
        [_luaEngine runChunkByPath:scriptPath];
        
        
    }
    
}




//////////////////////////////////////////////////////////////////////////////////

- (void)_showSettingList:(id)sender
{
    luaConfigList* cfgController = [[[luaConfigList alloc] init] autorelease];
    [cfgController setDelegate:self];
    
    [self.navigationController pushViewController:cfgController animated:YES];
}

- (void)_test
{
    luaEngineError err = [_luaEngine callFunction:@"test" withReturnValues:nil andParamsNum:1, @(33)];
    if (err != luaEngine_error_success)
    {
        NSLog(@"%d", err);
    }
}

@end



