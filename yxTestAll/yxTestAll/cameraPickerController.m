//
//  cameraPickerController.m
//  testNavigation
//
//  Created by Yuxi Liu on 6/19/14.
//  Copyright (c) 2014 Yuxi Liu. All rights reserved.
//

#import "cameraPickerController.h"

@interface cameraPickerController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImageView* _imageView;
}

- (void)_pressedTakePicture:(id)sender;

@end

@implementation cameraPickerController


-(void)dealloc{
    
    [_imageView release], _imageView = nil;
    
    [super dealloc];
}

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *bt = [[[UIButton alloc] initWithFrame:CGRectMake(60, 330, 200, 50)] autorelease];
    
    [bt setTitle:@"拍照" forState:UIControlStateNormal];
    [bt setBackgroundColor:[UIColor grayColor]];
    [bt addTarget:self action:@selector(_pressedTakePicture:) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:bt];
    
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [self.view addSubview:_imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma private
- (void)_pressedTakePicture:(id)sender{
    NSLog(@"touched");
    
    UIImagePickerController *imagePicker = [[[UIImagePickerController alloc] init] autorelease];
    
    /*判断是否支持照相机设备(这里是设备是否支持，不是用户是否给予权限)*/
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        /*设置imagePicker的源类型*/
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        /*设置代理服务器*/
        [imagePicker setDelegate:self];
        
        //模态的view
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        
    }
    else{
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不支持照相机，请尝试真机调试" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
    }
}

#pragma imagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [_imageView setImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
