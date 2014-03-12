//
//  CaptureSessionManager.h
//  PiChat_Camera
//
//  Created by Ryan Lin on 2014/3/4.
//  Copyright (c) 2014年 RyanLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureSessionManager : NSObject
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) AVCaptureDeviceInput *currentInputDevice;

- (void) switchCameraDevices;
- (instancetype)initWithSpecificCamera:(NSInteger) AVDevicePosition
                             focusMode: (NSInteger) AVFocusMode
                             flashMode: (NSInteger) AVFlashMode
                          exposureMode: (NSInteger) AVExposureMode
                      whiteBalanceMode: (NSInteger) AVWhiteBalanceMode;

- (void) takeStillImageFromCamera: (void (^)(UIImage *image, CFDictionaryRef exifAttachments))handler;
@end
