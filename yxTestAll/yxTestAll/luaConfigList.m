//
//  luaConfigList.m
//  yxTestAll
//
//  Created by LiuYuxi on 15/5/3.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import "luaConfigList.h"

@interface luaConfigList ()<UITableViewDelegate, UITableViewDataSource>{
    UITableView* _tableList;
    NSArray* _scriptArray;
}
@end

@implementation luaConfigList

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString* scriptPath = [[NSBundle mainBundle] resourcePath] ;
        scriptPath = [scriptPath stringByAppendingPathComponent:@"luaScript"];
        scriptPath = [scriptPath stringByAppendingPathComponent:@"settings"];
        
       
        
        NSArray* scriptFileNameArray = [[NSFileManager defaultManager] subpathsAtPath:scriptPath];
        NSMutableArray* scriptArray = [NSMutableArray arrayWithCapacity:[scriptFileNameArray count]];
        for (NSString* scriptFileName in scriptFileNameArray)
        {
            NSString* fullPath = [scriptPath stringByAppendingPathComponent:scriptFileName];
            [scriptArray addObject:fullPath];
        }
        
        _scriptArray = [scriptArray retain];
    }
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _tableList = [[UITableView alloc] initWithFrame:self.view.bounds];
    [_tableList setDelegate:self];
    [_tableList setDataSource:self];
    _tableList.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_tableList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    [_tableList release], _tableList = nil;
    [_scriptArray release], _scriptArray = nil;
    
    [super dealloc];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil != _scriptArray)
        return [_scriptArray count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* path = [_scriptArray objectAtIndex:indexPath.row];
    NSString* scriptName = @"unknown";
    if (nil != path)
    {
        NSString* fileName = [path lastPathComponent];
        if ([fileName hasSuffix:@"lua"])
        {
            scriptName = [fileName stringByDeletingPathExtension];
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"luaSettingCell"];
    if (nil == cell) {
        //UITableViewCellStyleSubtitle /*支持显示subTitle*/
        //UITableViewCellStyleDefault /*默认*/
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"luaSettingCell"];
    }
    
    [[cell textLabel] setText:scriptName];
    
    return cell;
}

#pragma mark delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* path = [_scriptArray objectAtIndex:indexPath.row];
    
    if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(configList:didSelectScript:inTable:)])
    {
        [_delegate configList:self didSelectScript:path inTable:tableView];
    }
}




@end




