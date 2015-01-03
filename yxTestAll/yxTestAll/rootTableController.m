//
//  rootTableController.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/12/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "rootTableController.h"
#import "protypeManager.h"

@interface rootTableController ()<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) UITableView *myTableView;

@end

@implementation rootTableController




- (id)initWithProtypeInfo:(protypeInfo *)protypeInfo{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        // 初始化tableView的数据
        [self setInfo:protypeInfo];
        
        // 创建tableView
        //UITableViewStylePlain
        //UITableViewStyleGrouped
        UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain] autorelease];
        
        // 设置tableView的数据源
        tableView.dataSource = self;
        
        // 设置tableView的委托
        tableView.delegate = self;
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        tableView.separatorInset = UIEdgeInsetsZero;
        
        // 设置tableView的背景图
        tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
        
        
        _myTableView = tableView;
        [self.view addSubview:_myTableView];
        
    }
    return self;
}
- (id)initWithProtypeKey:(NSString *)key{
    protypeInfo* info = [[protypeManager sharedManager] objectForKey:key];
    return [self initWithProtypeInfo:info];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithProtypeInfo:nil];
}

- (void)reload{
    [_myTableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma data-sourde
/*行数*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil == _info) {
        return 0;
    }
    else{
        return [[_info subProtypeInfo] count];
    }
}

/*每单元格数据*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    protypeManager* manager = [protypeManager sharedManager];
    
    NSString *CellWithIdentifier = [manager currentCategory];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (nil == cell) {
        //UITableViewCellStyleSubtitle /*支持显示subTitle*/
        //UITableViewCellStyleDefault /*默认*/
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellWithIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    protypeInfo *info = [[_info subProtypeInfo] objectAtIndex:row];
    
    cell.textLabel.text = info.title;
    cell.detailTextLabel.text = info.subTitle; //用于这个属性 UITableViewCellStyleSubtitle
    cell.imageView.image = [UIImage imageNamed:@"wechat_icon.png"];
    cell.accessoryType = UITableViewCellSelectionStyleGray;
    return cell;
}

/*每行高度*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


/*缩进级别*/
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

/*选中了某行*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    protypeInfo *info = [[_info subProtypeInfo] objectAtIndex:row];
    
    UIViewController* controller = nil;
    if ([info cls] == [rootTableController class]) {
        controller = [[[rootTableController alloc] initWithProtypeInfo:info] autorelease];
    }
    else{
        controller = [[[[info cls] alloc] init] autorelease];
    }
    
    [[self navigationController] pushViewController:controller animated:YES];
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor grayColor];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"执行删除操作");
}

@end

////////////////////////////////////////////////////////////
@implementation testTableView

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
//    [[UIColor redColor] set];
//    [[UIBezierPath bezierPathWithRect:rect] fill];
}

@end