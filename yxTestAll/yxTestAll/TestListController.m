//
//  TestListController.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/20/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "TestListController.h"

typedef enum _TestContextState{
    TestContext_prepare,
    TestContext_testing,
    TestContext_finish,
    TestContext_skip
}_TestContextState;

@interface TestContext()

@property(readwrite, assign) NSTimeInterval timeInterval;
@property(readwrite, assign) _TestContextState state;

@end

//////////////////////////////////////////////////////////////////////////////////////////

@interface TestListController ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray* _testList;
    UITableView* _tableView;
}

@end

@implementation TestListController

-(void)dealloc{
    
    [_testList release], _testList = nil;
    
    [super dealloc];
}

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _testList = [[NSMutableArray alloc] init];
        
        
        /*创建tableView*/
        _tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain] autorelease];
        
        // 设置tableView的数据源
        _tableView.dataSource = self;
        
        // 设置tableView的委托
        _tableView.delegate = self;
        
        [self.view addSubview:_tableView];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addTestWithTitle:(NSString *)title Target:(id)target selector:(SEL)selector andUserInfo:(id)data{
    TestContext* context = [[[TestContext alloc] init] autorelease];
    [context setTitle:title];
    [context setTarget:target];
    [context setSelector:selector];
    [context setUserData:data];
    
    [_testList addObject:context];
}
- (NSArray*)allTestContext{
    return _testList;
}
- (NSUInteger)testCount{
    return [_testList count];
}


#pragma datasource - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil == _testList) {
        return 0;
    }
    else{
        return [_testList count];
    }
}

/*每单元格数据*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellWithIdentifier = @"TestListcontrollerCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (nil == cell) {
        //UITableViewCellStyleSubtitle /*支持显示subTitle*/
        //UITableViewCellStyleDefault /*默认*/
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellWithIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    TestContext *contest = [_testList objectAtIndex:row];
    
    /*title*/
    NSString* title = contest.title;
    TestResult* result = contest.result;
    if (nil != result) {
        
        NSString* resultString = nil;
        if (nil != result.resultInfo) {
            resultString = result.resultInfo;
        }
        else{
            resultString = (YES == result.isSuccess)? @"success" :@"failure";
        }
        
        title = [title stringByAppendingFormat:@": %@", resultString];
    }
    
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellSelectionStyleNone;
    return cell;
}

/*每行高度*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}



@end





//////////////////////////////////////////////////////////////////////////////////////////



@implementation TestContext

- (id)init{
    self = [super init];
    if (self) {
        _target = nil;
        _selector = NULL;
        _userData = nil;
        _title = nil;
        _result = nil;
        _timeInterval = (NSTimeInterval)-1.0f;
    }
    return self;
}

-(void)dealloc{
    
    [_userData release], _userData = nil;
    [_title release], _title = nil;
    [_result release], _result = nil;
    
    [super dealloc];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////


@implementation TestResult

@synthesize isSuccess = _isSuccess;
@synthesize resultInfo = _resultInfo;

+ (id)state:(BOOL)isSuccss{
    
    return [[self class] state:isSuccss andInfo:nil];
}
+ (id)info:(NSString*)info{
    
    return [[self class] state:YES andInfo:info];
}
+ (id)state:(BOOL)isSuccss andInfo:(NSString *)info{
    
    TestResult *result = [[[[self class] alloc] init] autorelease];
    
    [result setIsSuccess:isSuccss];
    [result setResultInfo:info];
    
    return result;
}

- (id)init{
    self = [super init];
    if (self) {
        [self setIsSuccess:NO];
        [self setResultInfo:nil];
    }
    
    return self;
}

@end


