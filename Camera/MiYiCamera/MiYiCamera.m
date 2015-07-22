//
//  MiYiCamera.m
//  Camera
//
//  Created by 叶星龙 on 15/7/20.
//  Copyright (c) 2015年 叶星龙. All rights reserved.
//

#import "MiYiCamera.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define takeButtonHeight  80

typedef void(^propertyChangeBlock)(AVCaptureDevice *captureDevice);


@interface MiYiCamera ()
{
    ALAssetsLibrary *assetsLibrary;
    
}

@property (weak,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
@property (weak,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (weak,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (weak, nonatomic) UIButton *takeButton;//拍照按钮
@property (weak, nonatomic) UIButton *flashAutoButton;//自动闪光灯按钮
@property (weak, nonatomic) UIButton *flashOnButton;//打开闪光灯按钮
@property (weak, nonatomic) UIButton *flashOffButton;//关闭闪光灯按钮
@property (weak, nonatomic) UIButton *toggleButton;//切换摄像头按钮
@property (weak, nonatomic) UIButton *cancelButton;//取消按钮
@property (weak, nonatomic) UIButton *onlySendTextButton;//只发布文字按钮
@property (weak, nonatomic) UIButton *retakeButton;//重拍按钮
@property (weak, nonatomic) UIButton *usePhotoButton;//使用照片按钮
@property (weak, nonatomic) UIImageView *focusCursor; //聚焦光标

@property (weak, nonatomic)  UIView *navView;//顶部View
@property (weak, nonatomic)  UIView *tabBarView;//底部View
@property (weak, nonatomic)  UIView *preView;//预览

@property (weak, nonatomic) UIView *pickerCameraView;//相机显示层
@property (weak, nonatomic) UIImageView *preImageView;//预览页图片显示

@property (strong, nonatomic) NSMutableArray *assetGroupList;
@property (weak, nonatomic) UIButton *albumBtn;

@end

@implementation MiYiCamera

-(NSMutableArray *)assetGroupList
{
    if (_assetGroupList==nil) {
        _assetGroupList=[NSMutableArray array];
    }
    return _assetGroupList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //相机显示层
    UIView *pickerCameraView =[[UIView alloc]initWithFrame:(CGRect){0,0,self.view.frame.size.width,self.view.frame.size.height}];
    _pickerCameraView = pickerCameraView;
    //顶部View
    UIView *navView =[[UIView alloc]initWithFrame:(CGRect){0,0,self.view.frame.size.width,40}];
    navView.backgroundColor=[UIColor blackColor];
    navView.alpha=0.3;
    _navView = navView;
    //底部View
    UIView *tabBarView =[[UIView alloc]initWithFrame:(CGRect){0,CGRectGetMaxY(pickerCameraView.frame),self.view.frame.size.width,self.view.frame.size.height-CGRectGetMaxY(pickerCameraView.frame)}];
    tabBarView.backgroundColor=[UIColor blackColor];
    tabBarView.alpha=0.3;
    _tabBarView = tabBarView;
    //拍照按钮
    UIButton *takeButton =[[UIButton alloc]initWithFrame:(CGRect){self.view.frame.size.width/2-(takeButtonHeight-20)/2,self.view.frame.size.height-takeButtonHeight+20,takeButtonHeight-20,takeButtonHeight-20}];
    [takeButton setImage:[UIImage imageNamed:@"icon_facial_btn_take"] forState:UIControlStateNormal];
    takeButton.backgroundColor =[UIColor whiteColor];
    takeButton.layer.masksToBounds=YES;
    takeButton.layer.cornerRadius=5;
    [takeButton addTarget:self action:@selector(takeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _takeButton = takeButton;
    //自动闪光灯按钮
    UIButton * flashAutoButton =[[UIButton alloc]initWithFrame:(CGRect){5,0,takeButtonHeight/2,takeButtonHeight/2}];
    [flashAutoButton setImage:[UIImage imageNamed:@"icon_btn_camera_flash_auto"] forState:UIControlStateNormal];
    [flashAutoButton addTarget:self action:@selector(flashAutoClick) forControlEvents:UIControlEventTouchUpInside];
    _flashAutoButton = flashAutoButton;
    //打开闪光灯按钮
    UIButton *flashOnButton =[[UIButton alloc]initWithFrame:(CGRect){{CGRectGetMaxX(flashAutoButton.frame),0},flashAutoButton.frame.size}];
    [flashOnButton setImage:[UIImage imageNamed:@"icon_btn_camera_flash_on"] forState:UIControlStateNormal];
    [flashOnButton addTarget:self action:@selector(flashOnClick) forControlEvents:UIControlEventTouchUpInside];
    _flashOnButton = flashOnButton;
    //关闭闪光灯按钮
    UIButton *flashOffButton =[[UIButton alloc]initWithFrame:(CGRect){{CGRectGetMaxX(flashOnButton.frame),0},flashAutoButton.frame.size}];
    [flashOffButton setImage:[UIImage imageNamed:@"icon_btn_camera_flash_off"] forState:UIControlStateNormal];
    [flashOffButton addTarget:self action:@selector(flashOffClick) forControlEvents:UIControlEventTouchUpInside];
    _flashOffButton = flashOffButton;
    //聚焦光标
    UIImageView *focusCursor =[[UIImageView alloc]initWithFrame:(CGRect){100,100,80,80}];
    focusCursor.image =[UIImage imageNamed:@"camera_focus_red"];
    focusCursor.alpha=0;
    _focusCursor = focusCursor;
    //切换摄像头按钮
    UIButton * toggleButton =[[UIButton alloc]initWithFrame:(CGRect){{self.view.frame.size.width-takeButtonHeight/2-takeButtonHeight/4 ,0},flashAutoButton.frame.size}];
    [toggleButton setImage:[UIImage imageNamed:@"btn_video_flip_camera"] forState:UIControlStateNormal];
    [toggleButton addTarget:self action:@selector(toggleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _toggleButton = toggleButton;
    //退出相机
    UIButton *cancelButton =[[UIButton alloc]initWithFrame:(CGRect){15,takeButton.frame.origin.y+10,80,30}];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton = cancelButton;
    //预览相机
    UIView *preView =[[UIView alloc]initWithFrame:self.view.bounds];
    preView.backgroundColor=[UIColor blackColor];
    preView.hidden=YES;
    _preView = preView;
    //预览相机图片
    UIImageView *preImageView =[[UIImageView alloc]initWithFrame:(CGRect){0,40,self.view.frame.size.width,self.view.frame.size.height-takeButtonHeight-20-40}];
    _preImageView =preImageView;
    //重拍
    UIButton *retakeButton =[[UIButton alloc]initWithFrame:(CGRect){15,takeButton.frame.origin.y+10,80,30}];
    [retakeButton setTitle:@"重拍" forState:UIControlStateNormal];
    [retakeButton addTarget:self action:@selector(retakeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    retakeButton.hidden=YES;
    _retakeButton = retakeButton;
    //使用
    UIButton *usePhotoButton =[[UIButton alloc]initWithFrame:(CGRect){self.view.frame.size.width-15-80,takeButton.frame.origin.y+10,80,30}];
    [usePhotoButton setTitle:@"使用" forState:UIControlStateNormal];
    [usePhotoButton addTarget:self action:@selector(usePhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    usePhotoButton.hidden=YES;
    _usePhotoButton = usePhotoButton;
    //取相册
    UIButton *albumBtn =[[UIButton alloc]initWithFrame:(CGRect){100,self.view.frame.size.height-200,100,100}];
    _albumBtn = albumBtn;
    
    
    
    [self.view addSubview:pickerCameraView];
    [self.view addSubview:navView];
    [self.view addSubview:tabBarView];
    [self.view addSubview:takeButton];
    [self.view addSubview:flashAutoButton];
    [self.view addSubview:flashOnButton];
    [self.view addSubview:flashOffButton];
    [self.view addSubview:focusCursor];
    [self.view addSubview:toggleButton];
    [self.view addSubview:cancelButton];
    [self.view addSubview:preView];
    [preView addSubview:preImageView];
    [self.view addSubview:retakeButton];
    [self.view addSubview:usePhotoButton];
    [self.view addSubview:albumBtn];
    
    
    
    AVCaptureSession *captureSession =[[AVCaptureSession alloc]init];
    _captureSession =captureSession;
    if ([captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {//设置分辨率
        captureSession.sessionPreset=AVCaptureSessionPresetMedium;
    }
    
    //获得输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }
    
    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    AVCaptureDeviceInput *captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    _captureDeviceInput = captureDeviceInput;
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //初始化设备输出对象，用于获得输出数据
    AVCaptureStillImageOutput *captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    _captureStillImageOutput = captureStillImageOutput;
    //将设备输入添加到会话中
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    _captureVideoPreviewLayer = captureVideoPreviewLayer;
    
    CALayer *layer=self.pickerCameraView.layer;
    layer.masksToBounds=YES;
    
    captureVideoPreviewLayer.frame=layer.bounds;
    captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    //[layer addSublayer:_captureVideoPreviewLayer];
    [layer insertSublayer:captureVideoPreviewLayer below:self.focusCursor.layer];
    
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [self loadGroupsData];
    
    __weak MiYiCamera *weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:ALAssetsLibraryChangedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSDictionary *userInfo = note.userInfo;
                                                      if (!userInfo || [[userInfo allKeys] count] > 0) {
                                                          [weakself loadGroupsData];
                                                      }
                                                  }];

    
//    AVCaptureStillImageOutput* output = (AVCaptureStillImageOutput*)[self.captureSession.outputs objectAtIndex:0];
//    AVCaptureConnection *videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
//    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
//    CGFloat zoom = maxScale / 50;
//    if (zoom < 1.0f || zoom > maxScale)
//    {
//        return;
//    }
//    videoConnection.videoScaleAndCropFactor += zoom;
//    self.pickerCameraView.transform = CGAffineTransformScale(self.pickerCameraView.transform, zoom, zoom);
    
    // add the video previewview layer to the preview view
   // 缩放预览视图代码
    // zoom the preview view using core graphics
//    [previewView setTransform:CGAffineTransformMakeScale(2.0, 2.0 )];
    
    
   
    
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}
- (void)loadGroupsData {
    [self.assetGroupList removeAllObjects];
    MiYiCamera *__weak weakSelf = self;
    
    // Callback block for assets library to return result set with groups.
    ALAssetsLibraryGroupsEnumerationResultsBlock groupResultBlock =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if (group.numberOfAssets > 0) {
                [weakSelf.assetGroupList addObject:group];
            }
        } else {
            // Reset album button image after group data loaded successfully.
            [weakSelf resetAlbumBtnImage];
        }
    };
    // Error block for asstes library.
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
    };
    
    // Fetch assets groups from system's asstes library.
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                  usingBlock:groupResultBlock
                                failureBlock:failureBlock];
}
- (void)resetAlbumBtnImage {
    ALAssetsGroup *group =nil;
    for (id ass in _assetGroupList) {
        if([[ass valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos)
        {
            group =ass;
        }
//        NSString* name = [ass valueForProperty:ALAssetsGroupPropertyName];
//        if ([name isEqualToString:@"All Photos"]) {
//            group = ass;
//        }else if ([name isEqualToString:@"Camera Roll"])
//        {
//            group = ass;
//        }
    }
    
    CGImageRef imageRef = [group posterImage];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    if (image) {
        [self.albumBtn setImage:image forState:UIControlStateNormal];
    }
}
/**
 *  拍照点击
 */
-(void)takeButtonClick
{
    AVCaptureConnection *captureConnection;
    
    //            [self dismissViewControllerAnimated:YES completion:nil];
    
    captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请在设备的 设置-隐私-相机中允许访问照片。"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if (imageDataSampleBuffer) {
            _preView.hidden=NO;
            _retakeButton.hidden=NO;
            _usePhotoButton.hidden=NO;
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            //                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            _preImageView.image=image;
            NSLog(@"%ld",imageData.length);
         
//                        ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
//                        [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            
        }
        
    }];
    
}

/**
 *  闪光灯自动点击
 */
-(void)flashAutoClick
{
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}
/**
 *  闪光灯开启点击
 */
-(void)flashOnClick
{
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];
}
/**
 *  关闭闪光灯
 */
-(void)flashOffClick
{
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];
}
/**
 *  切换摄像头
 */
-(void)toggleButtonClick
{
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
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
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    [self setFlashModeButtonStatus];
}
/**
 *  取消退出pickerCamera
 */
-(void)cancelButtonClick
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  重拍
 */
-(void)retakeButtonClick
{
    _preImageView.image=nil;
    _preView.hidden=YES;
    _retakeButton.hidden=YES;
    _usePhotoButton.hidden=YES;
}
/**
 *  使用该照片
 */
-(void)usePhotoButtonClick
{
    
}

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
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
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
    [self.pickerCameraView addGestureRecognizer:tapGesture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.pickerCameraView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}
/**
 *  设置闪光灯按钮状态
 */
-(void)setFlashModeButtonStatus{
    AVCaptureDevice *captureDevice=[self.captureDeviceInput device];
    AVCaptureFlashMode flashMode=captureDevice.flashMode;
    if([captureDevice isFlashAvailable]){
        self.flashAutoButton.hidden=NO;
        self.flashOnButton.hidden=NO;
        self.flashOffButton.hidden=NO;
        self.flashAutoButton.enabled=YES;
        self.flashOnButton.enabled=YES;
        self.flashOffButton.enabled=YES;
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                self.flashAutoButton.enabled=NO;
                break;
            case AVCaptureFlashModeOn:
                self.flashOnButton.enabled=NO;
                break;
            case AVCaptureFlashModeOff:
                self.flashOffButton.enabled=NO;
                break;
            default:
                break;
        }
    }else{
        self.flashAutoButton.hidden=YES;
        self.flashOnButton.hidden=YES;
        self.flashOffButton.hidden=YES;
    }
}
/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
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
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
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
