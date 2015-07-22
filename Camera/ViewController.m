//
//  ViewController.m
//  Camera
//
//  Created by 叶星龙 on 15/7/20.
//  Copyright (c) 2015年 叶星龙. All rights reserved.
//

#import "ViewController.h"
#import "MiYiCamera.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn =[[UIButton alloc]initWithFrame:(CGRect){100,100,100,100}];
    btn.backgroundColor=[UIColor redColor];
    [btn addTarget:self  action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)click
{
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusDenied){
        
        
        
        
        
        NSLog(@"Denied");   //不允许的话
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在设备的 设置-隐私-相机中允许访问相机。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                NSLog(@"Granted access to %@", mediaType);
            }
            else {
                NSLog(@"Not granted access to %@", mediaType);
            }
            
        }];
        
    }else if(authStatus == AVAuthorizationStatusRestricted)
    {
        NSLog(@"Denied");   //不允许的话
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在设备的 设置-隐私-相机中允许访问相机。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
        
    }
    else if(authStatus == AVAuthorizationStatusAuthorized){//允许访问
        
        MiYiCamera * picker =[[MiYiCamera alloc]init];
        picker.view.backgroundColor=[UIColor blackColor];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
