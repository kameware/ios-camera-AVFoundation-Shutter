//
//  ViewController.m
//  CameraSampleAV
//
//  Created by mienharu on 2013/06/07.
//  Copyright (c) 2013年 mienharu All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIView *previewView;

@end

@implementation ViewController

- (void)setupAVCapture
{
    NSError *error = nil;
    
    // 入力と出力からキャプチャーセッションを作成？
    self.session = [[AVCaptureSession alloc] init];
    // カメラ取得
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // カメラ入力を作成し、セッションに追加
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    [self.session addInput:self.videoInput];
    
    // 画像への出力を作成し、セッションに追加
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.session addOutput:self.stillImageOutput];
    
    // プレビュー作成
    AVCaptureVideoPreviewLayer * captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]
                                                             initWithSession:self.session];
    captureVideoPreviewLayer.frame = self.view.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // レイヤーをViewに設定
    CALayer *previewLayer = self.previewView.layer;
    previewLayer.masksToBounds = YES;
    [previewLayer addSublayer:captureVideoPreviewLayer];
    
    // セッション開始
    [self.session startRunning];
}


- (void) takePhoto:(id) sender
{
    // ビデオ入力取得
    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (videoConnection == nil) {
        return;
    }
    
    // シャッター動作追加 ※取る前に動かしてるから非同期です。
    CATransition *shutterAnimation = [CATransition animation];
    [shutterAnimation setDelegate:self];
    // シャッター速度
    [shutterAnimation setDuration:0.2];
    shutterAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [shutterAnimation setType:@"cameraIris"];
    [shutterAnimation setValue:@"cameraIris" forKey:@"cameraIris"];
    CALayer *cameraShutter = [[CALayer alloc]init];
//    [cameraShutter setBounds:CGRectMake(0.0, 0.0, 320.0, 425.0)];
    [self.view.layer addSublayer:cameraShutter];
    [self.view.layer addAnimation:shutterAnimation forKey:@"cameraIris"];
    [self.stillImageOutput
     captureStillImageAsynchronouslyFromConnection:videoConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         
         if (imageDataSampleBuffer == NULL) {
             return;
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         // カメラロールに画像を保存
         UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
     }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // 撮影ボタン
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"撮影" style:UIBarButtonItemStyleBordered target:self action:@selector(takePhoto:)];
    
    toolbar.items = @[takePhotoButton];
    [self.view addSubview:toolbar];
    
    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                toolbar.frame.size.height,
                                                                self.view.bounds.size.width,
                                                                self.view.bounds.size.height - toolbar.frame.size.height)];
    
    
    [self.view addSubview:self.previewView];
    
    [self setupAVCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
