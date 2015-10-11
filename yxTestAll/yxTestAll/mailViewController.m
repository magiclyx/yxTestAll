//
//  mailViewController.m
//  yxTestAll
//
//  Created by LiuYuxi on 15/8/13.
//  Copyright (c) 2015年 Yuxi Liu. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "mailViewController.h"

@interface mailViewController ()<MFMailComposeViewControllerDelegate>
{
    UIButton* _button;
}

- (void)_pressedTakePicture:(id)sender;


@end

@implementation mailViewController


- (instancetype)init{
    self = [super init];
    if (self)
    {
        _button = [[UIButton alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_button release], _button = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _button.frame = CGRectMake(60, 330, 200, 50);
    [_button setTitle:@"拍照" forState:UIControlStateNormal];
    [_button setBackgroundColor:[UIColor grayColor]];
    [_button addTarget:self action:@selector(_pressedTakePicture:) forControlEvents:UIControlEventTouchDown];

    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_pressedTakePicture:(id)sender
{
    NSLog(@"abcd");
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mc = [[[MFMailComposeViewController alloc] init] autorelease];
        mc.mailComposeDelegate = self;
        
        //设置主题
        [mc setSubject:@"title"];
        
        //添加收件人
        NSArray *toRecipients = [NSArray arrayWithObject: @"liu.yuxi.canaan@icloud.com"];
        [mc setToRecipients: toRecipients];
        
        //添加抄送
        NSArray *ccRecipients = [NSArray arrayWithObject:@"liu.yuxi.canaan@icloud.com"];
        [mc setCcRecipients:ccRecipients];
        
        //添加密送
        NSArray *bccRecipients = [NSArray arrayWithObject:@"liu.yuxi.canaan@icloud.com"];
        [mc setBccRecipients:bccRecipients];
        
        /*
        // 添加一张图片
        UIImage *addPic = [UIImage imageNamed: @"Icon@2x.png"];
        NSData *imageData = UIImagePNGRepresentation(addPic);            // png
        //关于mimeType：http://www.iana.org/assignments/media-types/index.html
        [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"Icon.png"];
        
        //添加一个pdf附件
        NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
        NSData *pdf = [NSData dataWithContentsOfFile:file];
        [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
        //添加一个视频
        NSString *path=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),@"20121219.avi"];
        NSData *video = [NSData dataWithContentsOfFile:path];
        [mailPicker addAttachmentData:video mimeType: @"" fileName:@"20121219.avi"];
         */
        
        NSString* emailBody = @"eMail 正文";
        [mc setMessageBody:emailBody isHTML:NO];
        
        
        
        
        [self presentViewController:mc animated:YES completion:nil];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:@"不能显示邮件"
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        [alert show];

    }

}


/*!
 @method     mailComposeController:didFinishWithResult:error:
 @abstract   Delegate callback which is called upon user's completion of email composition.
 @discussion This delegate callback will be called when the user completes the email composition.  How the user chose
 to complete this task will be given as one of the parameters to the callback.  Upon this call, the client
 should remove the view associated with the controller, typically by dismissing modally.
 @param      controller   The MFMailComposeViewController instance which is returning the result.
 @param      result       MFMailComposeResult indicating how the user chose to complete the composition process.
 @param      error        NSError indicating the failure reason if failure did occur.  This will be <tt>nil</tt> if
 result did not indicate failure.
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            UIAlertView *alert = [[[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:@"success"
                                   delegate:self
                                   cancelButtonTitle:@"sure"
                                   otherButtonTitles:nil]
                                  autorelease];
            [alert show];
            NSLog(@"Mail sent");
            return;
        }
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

}

@end
