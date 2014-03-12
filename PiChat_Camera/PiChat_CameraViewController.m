//
//  PiChat_CameraViewController.m
//  PiChat_Camera
//
//  Created by Ryan Lin on 2014/3/4.
//  Copyright (c) 2014年 RyanLin. All rights reserved.
//

#import "PiChat_CameraViewController.h"
#import "CaptureSessionManager.h"

@interface PiChat_CameraViewController ()
@property (strong, nonatomic) CaptureSessionManager *captureSessionManager;
@property (weak, nonatomic) IBOutlet UIButton *SwitchButton;
@property (strong, nonatomic) UIView *cameraPreviewView;

@end

@implementation PiChat_CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.captureSessionManager = [[CaptureSessionManager alloc] init];
    self.captureSessionManager = [[CaptureSessionManager alloc] initWithSpecificCamera:AVCaptureDevicePositionBack
                                                                             focusMode:AVCaptureFocusModeAutoFocus
                                                                             flashMode:AVCaptureFlashModeOff
                                                                          exposureMode:AVCaptureExposureModeAutoExpose
                                                                      whiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    
    
    AVCaptureVideoPreviewLayer *previewLayer = self.captureSessionManager.videoPreviewLayer;
    if (previewLayer) {
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        previewLayer.bounds = self.view.layer.bounds;
        previewLayer.position = CGPointMake(CGRectGetMidX(self.view.layer.bounds), CGRectGetMidY(self.view.layer.bounds));
        
        self.cameraPreviewView = [[UIView alloc]initWithFrame:self.view.layer.bounds];
        [self.cameraPreviewView.layer addSublayer:previewLayer];
        [self.view addSubview:self.cameraPreviewView];
        [self.view sendSubviewToBack:self.cameraPreviewView];
    
        [self.captureSessionManager.captureSession startRunning];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)switchCamera:(UIButton *)sender {
    if(self.captureSessionManager)
        [self.captureSessionManager switchCameraDevices];
    
}

- (IBAction)takePic:(UIButton *)sender {
    if (self.captureSessionManager) {
        __weak PiChat_CameraViewController *weakSelf = self;
        [self.captureSessionManager takeStillImageFromCamera:^(UIImage *image, CFDictionaryRef exifAttachments) {
            if (exifAttachments)  NSLog(@"影像屬性: %@", exifAttachments);
            //UIImage *image = [[UIImage alloc]initWithData:imageData];
            
            CGSize screenBounds = [UIScreen mainScreen].bounds.size;
            CGFloat cameraAspectRatio = image.size.width/image.size.height;
            CGFloat camViewWidth = screenBounds.height * cameraAspectRatio;
            image = [self resizeImage:image scaleToSize:CGSizeMake(camViewWidth, screenBounds.height)];
            CGFloat offectX = (image.size.width - screenBounds.width) / 2;
            image = [self cropImage:image withRect:CGRectMake(offectX, 0, screenBounds.width, screenBounds.height)];

            UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
            //[imageView sizeToFit];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [weakSelf.view addSubview:imageView];
            [weakSelf.cameraPreviewView removeFromSuperview];
            
        }];
        
        
        
    }
}

- (UIImage *)resizeImage:(UIImage *)image scaleToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)cropImage:(UIImage *)image withRect:(CGRect)cropRect
{
    cropRect = CGRectMake(cropRect.origin.x*image.scale, cropRect.origin.y*image.scale, cropRect.size.width*image.scale, cropRect.size.height*image.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
