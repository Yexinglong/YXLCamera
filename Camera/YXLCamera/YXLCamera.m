//
//  YXLCamera.m
//  Camera
//
//  Created by 叶星龙 on 15/11/1.
//  Copyright © 2015年 叶星龙. All rights reserved.
//

#import "YXLCamera.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Masonry.h"

#define buttonTakeWH  80


typedef void (^propertyChangeBlock)(AVCaptureDevice *captureDevice);;
@interface YXLCamera ()
{
    ALAssetsLibrary *assetsLibrary;
    /**
     *  负责输入和输出设置之间的数据传递
     */
    AVCaptureSession *cameraCaptureSession;
    /**
     *  负责从AVCaptureDevice获得输入数据
     */
    AVCaptureDeviceInput *cameraCaptureDeviceInput;
    /**
     *  照片输出流
     */
    AVCaptureStillImageOutput *cameraCaptureStillImageOutput;
    /**
     *  相机拍摄预览图层
     */
    AVCaptureVideoPreviewLayer *cameraCaptureVideoPreviewLayer;
    /**
     *  拍照按钮
     */
    UIButton *buttonTake;
    /**
     *  闪光灯按钮
     */
    UIButton *buttonFlash;
    /**
     *  自动闪光灯按钮
     */
    UIButton *buttonFlashAuto;
    /**
     *  打开闪光灯按钮
     */
    UIButton *buttonFlashOn;
    /**
     *  关闭闪光灯按钮
     */
    UIButton *buttonFlashOff;
    /**
     *  切换摄像头按钮
     */
    UIButton *buttonToggle;
    /**
     *  取消按钮
     */
    UIButton *buttonCancel;
    /**
     *  重拍按钮
     */
    UIButton *buttonRetake;
    /**
     *  使用照片按钮
     */
    UIButton *buttonUsePhoto;
    /**
     *  聚焦光标
     */
    UIImageView *imageFocusCursor;
    /**
     *  顶部栏
     */
    UIView *viewTopBar;
    /**
     *  预览
     */
    UIView *viewPre;
    /**
     *  相机显示层
     */
    UIView *viewPickerCamera;
    /**
     *  预览页图片显示
     */
    UIImageView *imagePre;
    /**
     *  相册
     */
    UIButton *buttonAlbum;
    /**
     *  相册图片
     */
    NSMutableArray *assetGroupList;
}
@end

@implementation YXLCamera

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    assetGroupList=[NSMutableArray array];
    
    viewPickerCamera =[UIView new];
    [self.view addSubview:viewPickerCamera];
    [viewPickerCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    viewTopBar =[self getViewTopBar];
    [self.view addSubview:viewTopBar];
    [viewTopBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.width.equalTo(@(kWindowWidth));
        make.height.equalTo(@44);
    }];

    buttonTake =[self getButtonTake];
    [self.view addSubview:buttonTake];
    [buttonTake mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-20));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(buttonTakeWH, buttonTakeWH));
    }];
    
    buttonFlash =[self getButtonFlash];
    [self.view addSubview:buttonFlash];
    [buttonFlash mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@5);
        make.right.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    buttonFlashAuto =[self getButtonFlashAuto];
    buttonFlashAuto.alpha=0;
    [self.view addSubview:buttonFlashAuto];
    [buttonFlashAuto mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(buttonFlash);
        make.right.equalTo(buttonFlash.mas_left);
        make.size.mas_equalTo(buttonFlash);
    }];
    
    buttonFlashOn =[self getButtonFlashOn];
    buttonFlashOn.alpha=0;
    [self.view addSubview:buttonFlashOn];
    [buttonFlashOn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(buttonFlash);
        make.right.equalTo(buttonFlashAuto.mas_left);
        make.size.mas_equalTo(buttonFlash);
    }];
    
    buttonFlashOff =[self getButtonFlashOff];
    buttonFlashOff.alpha=0;
    [self.view addSubview:buttonFlashOff];
    [buttonFlashOff mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(buttonFlash);
        make.right.equalTo(buttonFlashOn.mas_left);
        make.size.mas_equalTo(buttonFlash);
    }];
    
    imageFocusCursor =[UIImageView new];
    imageFocusCursor.image=[UIImage imageNamed:@"Camera_Focus_Red"];
    imageFocusCursor.alpha=0;
    [self.view addSubview:imageFocusCursor];
    [imageFocusCursor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@(0));
        make.centerY.equalTo(@(0));
        make.size.mas_equalTo(buttonTake);
    }];
    
    buttonToggle =[self getButtonToggle];
    [self.view addSubview:buttonToggle];
    [buttonToggle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(buttonFlash);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(buttonFlash);
    }];
    
    buttonCancel =[self getButtonCancel];
    [self.view addSubview:buttonCancel];
    [buttonCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(buttonFlash);
        make.left.equalTo(@0);
        make.size.mas_equalTo(buttonFlash);
    }];
    
    buttonAlbum =[self getButtonAlbum];
    [self.view addSubview:buttonAlbum];
    [buttonAlbum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@5);
        make.centerY.equalTo(buttonTake);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    viewPre =[UIView new];
    viewPre.backgroundColor=[UIColor blackColor];
    viewPre.hidden=YES;
    [self.view addSubview:viewPre];
    [viewPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    imagePre =[UIImageView new];
    imagePre.contentMode=UIViewContentModeScaleAspectFit;
    [viewPre addSubview:imagePre];
    [imagePre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(viewPre);
    }];
    
    buttonRetake =[self getButtonRetake];
    buttonRetake.hidden=YES;
    [self.view addSubview:buttonRetake];
    [buttonRetake mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-20));
        make.left.equalTo(@5);
        make.width.greaterThanOrEqualTo(@20);
        make.height.equalTo(@18);
    }];
    
    buttonUsePhoto =[self getButtonUsePhoto];
    buttonUsePhoto.hidden=YES;
    [self.view addSubview:buttonUsePhoto];
    [buttonUsePhoto mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-20));
        make.right.equalTo(@(-5));
        make.width.greaterThanOrEqualTo(@20);
        make.height.equalTo(@18);
    }];
    
    cameraCaptureSession =[[AVCaptureSession alloc]init];
    //设置分辨率
    if ([cameraCaptureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        cameraCaptureSession.sessionPreset=AVCaptureSessionPresetHigh;
    }
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    //取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }
    
    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    cameraCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }

    //初始化设备输出对象，用于获得输出数据
    cameraCaptureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [cameraCaptureStillImageOutput setOutputSettings:outputSettings];//输出设置
    //将设备输入添加到会话中
    if ([cameraCaptureSession canAddInput:cameraCaptureDeviceInput]) {
        [cameraCaptureSession addInput:cameraCaptureDeviceInput];
    }
    
    //将设备输出添加到会话中
    if ([cameraCaptureSession canAddOutput:cameraCaptureStillImageOutput]) {
        [cameraCaptureSession addOutput:cameraCaptureStillImageOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    cameraCaptureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:cameraCaptureSession];
    CALayer *layer=viewPickerCamera.layer;
    layer.masksToBounds=YES;
    cameraCaptureVideoPreviewLayer.frame=(CGRect){0,0,kWindowWidth,kWindowHeight};
    cameraCaptureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    [layer insertSublayer:cameraCaptureVideoPreviewLayer below:imageFocusCursor.layer];
    
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    [self loadGroupsData];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(someMethod)
//                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
//    __weak YXLCamera *weakself = self;
//    [[NSNotificationCenter defaultCenter] addObserverForName:ALAssetsLibraryChangedNotification
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *note) {
//                                                      NSDictionary *userInfo = note.userInfo;
//                                                      if (!userInfo || [[userInfo allKeys] count] > 0) {
//                                                          [weakself loadGroupsData];
//                                                      }
//                                                  }];

    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [cameraCaptureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [cameraCaptureSession stopRunning];
}
-(void)someMethod
{
    [self loadGroupsData];
}
- (void)loadGroupsData {
    [assetGroupList removeAllObjects];
    YXLCamera *__weak weakSelf = self;
    ALAssetsLibraryGroupsEnumerationResultsBlock groupResultBlock =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if (group.numberOfAssets > 0) {
                [assetGroupList addObject:group];
            }
        } else {
            [weakSelf resetAlbumBtnImage];
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
    };
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:groupResultBlock
                               failureBlock:failureBlock];
}
- (void)resetAlbumBtnImage {
    ALAssetsGroup *group =nil;
    for (id ass in assetGroupList) {
        if([[ass valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos){
            group =ass;
        }
    }
    CGImageRef imageRef = [group posterImage];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    if (image) {
        [buttonAlbum setImage:image forState:UIControlStateNormal];
    }
}
#pragma -mark 点击
-(void)clickButtonTake{
    AVCaptureConnection *captureConnection=[cameraCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [cameraCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请在设备的 设置-隐私-相机中允许访问照片。"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if (imageDataSampleBuffer) {
            viewPre.hidden=NO;
            buttonRetake.hidden=NO;
            buttonUsePhoto.hidden=NO;
            buttonAlbum.hidden=YES;
            [self clickButtonFlash];
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            imagePre.image=image;
            NSLog(@"%ld",(unsigned long)imageData.length);
        }
        
    }];

}
-(void)clickButtonFlash{
    CGFloat alphaF =0;
    if (buttonFlashAuto.alpha ==1) {
        alphaF =0;
    }else{
        alphaF =1;
    }
    [UIView animateWithDuration:0.5 animations:^{
        buttonFlashAuto.alpha=alphaF;
        buttonFlashOff.alpha=alphaF;
        buttonFlashOn.alpha=alphaF;
    }];
}
-(void)clickButtonFlashAuto{
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
    [buttonFlash setImage:buttonFlashAuto.imageView.image forState:UIControlStateNormal];
    [self clickButtonFlash];
}
-(void)clickButtonFlashOn{
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];
    [buttonFlash setImage:buttonFlashOn.imageView.image forState:UIControlStateNormal];
    [self clickButtonFlash];
}
-(void)clickButtonFlashOff{
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];
    [buttonFlash setImage:buttonFlashOff.imageView.image forState:UIControlStateNormal];
    [self clickButtonFlash];
    
}
-(void)clickButtonToggle{
    [self clickButtonFlash];
    AVCaptureDevice *currentDevice=[cameraCaptureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [cameraCaptureSession beginConfiguration];
    //移除原有输入对象
    [cameraCaptureSession removeInput:cameraCaptureDeviceInput];
    //添加新的输入对象
    if ([cameraCaptureSession canAddInput:toChangeDeviceInput]) {
        [cameraCaptureSession addInput:toChangeDeviceInput];
        cameraCaptureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [cameraCaptureSession commitConfiguration];
    [self setFlashModeButtonStatus];
}
-(void)clickButtonCancel{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)clickButtonAlbum{
    NSLog(@"这个相册的东西点击需要做什么,自己看需求");
}
-(void)clickButtonRetake{
    buttonAlbum.hidden=NO;
    imagePre.image=nil;
    viewPre.hidden=YES;
    buttonRetake.hidden=YES;
    buttonUsePhoto.hidden=YES;
}
-(void)clickButtonUsePhoto{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(cameraImage:)]) {
            [self.delegate cameraImage:imagePre.image];
        }
    }];
}
#pragma -mark 初始化控件
-(UIView *)getViewTopBar{
    UIView *view =[UIView new];
    view.backgroundColor=UIColorRGBA(0,0,0,0.3);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = (CGRect){0,0,kWindowWidth,44};
    gradient.colors = [NSArray arrayWithObjects:
                       (id)UIColorRGBA(0, 0, 0, 0.6).CGColor,
                       (id)UIColorRGBA(0 , 0, 0, 0.4).CGColor,
                       (id)UIColorRGBA(0 , 0, 0, 0.2).CGColor,
                       (id)UIColorRGBA(0 , 0, 0, 0).CGColor,nil];
    [view.layer insertSublayer:gradient atIndex:0];
    return view;
}
-(UIButton *)getButtonTake{
    UIButton *btn =[UIButton new];
    [btn setImage:[UIImage imageNamed:@"Camera_Filming"] forState:UIControlStateNormal];
    btn.backgroundColor =[UIColor whiteColor];
    btn.layer.masksToBounds=YES;
    btn.layer.cornerRadius=5;
    [btn addTarget:self action:@selector(clickButtonTake) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonFlash{
    UIButton *btn =[UIButton new];
    [btn setImage:[UIImage imageNamed:@"Camera_Flash_Auto"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonFlash) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonFlashAuto{
    UIButton *btn =[UIButton new];
    [btn setImage:[UIImage imageNamed:@"Camera_Flash_Auto"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonFlashAuto) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonFlashOn{
    UIButton *btn =[UIButton new];
    [btn setImage:[UIImage imageNamed:@"Camera_Flash_On"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonFlashOn) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonFlashOff{
    UIButton *btn =[UIButton new];
    [btn setImage:[UIImage imageNamed:@"Camera_Flash_Off"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonFlashOff) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonToggle{
    UIButton *btn =[UIButton new];
    [btn setImage:[UIImage imageNamed:@"Camera_Flip_Camera"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonToggle) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonCancel{
    UIButton *btn =[UIButton new];
    [btn setImage:[UIImage imageNamed:@"Camera_Cancel"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonCancel) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonAlbum{
    UIButton *btn =[UIButton new];
    [btn addTarget:self action:@selector(clickButtonAlbum) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonRetake{
    UIButton *btn =[UIButton new];
    [btn setTitle:@"重拍" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonRetake) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UIButton *)getButtonUsePhoto{
    UIButton *btn =[UIButton new];
    [btn setTitle:@"使用" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonUsePhoto) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma -mark 
#pragma mark - AVCaptureDevice

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}
/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(propertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [cameraCaptureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}
/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [viewPickerCamera addGestureRecognizer:tapGesture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    [UIView animateWithDuration:0.5 animations:^{
        buttonFlashAuto.alpha=0;
        buttonFlashOn.alpha=0;
        buttonFlashOff.alpha=0;
    }];
    CGPoint point= [tapGesture locationInView:viewPickerCamera];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [cameraCaptureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    imageFocusCursor.transform=CGAffineTransformIdentity;
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}
/**
 *  设置闪光灯按钮状态
 */
-(void)setFlashModeButtonStatus{
    AVCaptureDevice *captureDevice=[cameraCaptureDeviceInput device];
    AVCaptureFlashMode flashMode=captureDevice.flashMode;
    if([captureDevice isFlashAvailable]){
        buttonFlashAuto.hidden=NO;
        buttonFlashOn.hidden=NO;
        buttonFlashOff.hidden=NO;
        buttonFlashAuto.enabled=YES;
        buttonFlashOn.enabled=YES;
        buttonFlashOff.enabled=YES;
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                buttonFlashAuto.enabled=NO;
                break;
            case AVCaptureFlashModeOn:
                buttonFlashOn.enabled=NO;
                break;
            case AVCaptureFlashModeOff:
                buttonFlashOff.enabled=NO;
                break;
            default:
                break;
        }
    }else{
        buttonFlashAuto.hidden=YES;
        buttonFlashOn.hidden=YES;
        buttonFlashOff.hidden=YES;
    }
}
/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    imageFocusCursor.transform=CGAffineTransformIdentity;
    imageFocusCursor.center=point;
    imageFocusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    imageFocusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        imageFocusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        imageFocusCursor.alpha=0;
        
    }];
}
#pragma mark - 通知
/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    [[NSNotificationCenter   defaultCenter] removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}
/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    NSLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    NSLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}
/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    NSLog(@"会话发生错误.");
}

-(void)dealloc{
    [self removeNotification];
}

@end
