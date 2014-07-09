//
//  rootViewController.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/12/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "rootViewController.h"
#import "rootNavigationSettingController.h"
#import "rootTableController.h"
#import "protypeManager.h"

@interface rootViewController (){
    rootTableController *_tableController;
    NSMutableArray* _categoryProtypeInfo;
}

-(void)_navigationBarLeftButtonPressed:(id)sender;
-(void)_navigationBarRightButtonPressed:(id)sender;
-(void)_navigationBarSegementChanged:(id)sender;
@end

@implementation rootViewController

- (void)dealloc
{
    [_categoryProtypeInfo release], _categoryProtypeInfo = nil;
    
    [_tableController release], _tableController = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _categoryProtypeInfo = [[NSMutableArray alloc] init];
        
        /*设置默认使用base分类*/
        [[protypeManager sharedManager] setCurrentCategory:protypeCategory_base];
        
    }
    return self;
}
-(void)loadView{
//    self.view =  [[[rootView alloc] initWithFrame:[self.parentViewController.view bounds]] autorelease];
    self.view =[[rootView alloc] init];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*设置navigationbar上显示的标题*/
    self.title = @"all items";
    
    /*设置navigationbar的半透明*/
    [self.navigationController.navigationBar setTranslucent:NO];
    
    /*设置navigationbar的颜色*/
    [self.navigationController.navigationBar setBarTintColor:[UIColor purpleColor]];
    
    /*显示toolBar*/
    [self.navigationController setToolbarHidden:NO animated:YES];
    UIBarButtonItem *one = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil] autorelease];
    UIBarButtonItem *two = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:nil action:nil] autorelease];
    UIBarButtonItem *three = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil] autorelease];
    UIBarButtonItem *four = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:nil action:nil] autorelease];
    UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]; //flexiblespace 让按钮平均分配
    [self setToolbarItems:[NSArray arrayWithObjects:flexItem, one, flexItem, two, flexItem, three, flexItem, four, flexItem, nil]];
    
    
    /*设置navigationbar左边按钮*/
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(_navigationBarLeftButtonPressed:)] autorelease];
    
    /*设置navigationbar右边按钮*/
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_navigationBarRightButtonPressed:)] autorelease];
    
    /*设置navigationbar上左右按钮字体颜色*/
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    /*设置backButton*/
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil] autorelease];
    self.navigationItem.backBarButtonItem = backButton;
    
    
    
    /*自定义titleView*/
    NSArray* allCategorys = [[protypeManager sharedManager] allCategory];
    NSString* currentCategory = [[protypeManager sharedManager] currentCategory];
    
    
    NSUInteger selectedIndex = 0;
    NSUInteger currentIndex = 0;
    NSMutableArray* segementTitleArray = [NSMutableArray array];
    for (protypeInfo *info in allCategorys) {
        
        if ([info.key isEqualToString:currentCategory]) {
            selectedIndex = currentIndex;
        }
        
        [segementTitleArray addObject:info.title];
        [_categoryProtypeInfo addObject:info];
        
        currentIndex++;
    }
    
    //NSArray *array = [NSArray arrayWithObjects:@"基本控件",@"其他", nil];
    UISegmentedControl *segmentedController = [[[UISegmentedControl alloc] initWithItems:segementTitleArray] autorelease];
    /*默认选择segement 0*/
    [segmentedController setSelectedSegmentIndex:currentIndex];
    [segmentedController addTarget:self action:@selector(_navigationBarSegementChanged:) forControlEvents:UIControlEventValueChanged];
    
    /*设置titleView 为segement*/
    self.navigationItem.titleView = segmentedController;
    
    
    
    
    /*显示子viewController*/
    //addChildViewController回调用[child willMoveToParentViewController:self] ，但是不会调用didMoveToParentViewController，所以需要显示调用
    _tableController = [[[rootTableController alloc] initWithProtypeInfo:[[protypeManager sharedManager] rootProtypeInfo]] autorelease];
    [self addChildViewController:_tableController];
    [self.view addSubview:_tableController.view];
    [_tableController.view setFrame:self.view.bounds];
    [_tableController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma delegate_uinavigationController
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    /*因为最顶层的table不在navigationController 里，而是由rootView 添加的childController, 所以这里要判断2个类*/
    if ([viewController isKindOfClass:[rootTableController class]]  ||  [viewController isKindOfClass:[rootViewController class]]) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    else{
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    
//}

#pragma private_navigationBar
-(void)_navigationBarLeftButtonPressed:(id)sender{
    NSLog(@"navigation_bar_rightButton_pressed");
    

}
-(void)_navigationBarRightButtonPressed:(id)sender{
    NSLog(@"navigation_bar_leftButton_pressed");
    
    rootNavigationSettingController *settingController = [rootNavigationSettingController settingController];
    [self.navigationController pushViewController:settingController animated:YES];
}

-(void)_navigationBarSegementChanged:(id)sender{
    
    NSUInteger selectedIndex = [sender selectedSegmentIndex];
    //NSString *title = [sender titleForSegmentAtIndex:selectedIndex];
    protypeInfo *rootProtypeInfo = [_categoryProtypeInfo objectAtIndex:selectedIndex];
    
    [[protypeManager sharedManager] setCurrentCategory:[rootProtypeInfo key]];
    [_tableController setInfo:[[protypeManager sharedManager] rootProtypeInfo]];
    [_tableController reload];
    
//    switch ([sender selectedSegmentIndex]) {
//        case 0:
//        {
//        }
//            break;
//        case 1:
//        {
//            /*提示alert*/
//            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"comming soon ..." delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alter show];
//            
//            /*重新选择第一个segement*/
//            [sender setSelectedSegmentIndex:0];
//        }
//            break;
//            
//        default:
//            break;
//    }
}
@end

////////////////////////////////////////////////////////////
@implementation rootView

-(void)drawRect:(CGRect)rect{
    [[UIColor grayColor] set];
    [[UIBezierPath bezierPathWithRect:rect] fill];
}

@end