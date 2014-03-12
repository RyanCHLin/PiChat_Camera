//
//  CaptureSessionManager.m
//  PiChat_Camera
//
//  Created by Ryan Lin on 2014/3/4.
//  Copyright (c) 2014年 RyanLin. All rights reserved.
//

#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>


@interface CaptureSessionManager()
@end


@implementation CaptureSessionManager

- (AVCaptureSession *) captureSession
{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        }
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    if (self.captureSession && !_videoPreviewLayer)
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    return _videoPreviewLayer;
}

- (AVCaptureStillImageOutput *)stillImageOutput
{
    if (self.captureSession && !_stillImageOutput) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
        [self.captureSession addOutput:_stillImageOutput];
    }
    return _stillImageOutput;
}

- (void) takeStillImageFromCamera: (void (^)(UIImage *image, CFDictionaryRef exifAttachments))handler
{
    __block NSData *imageData;
    __block UIImage *image;
    __block CFDictionaryRef exifAttachments;
    
    if (self.captureSession && self.stillImageOutput){
        
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { break; }
        }
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
         ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
             if (imageSampleBuffer) {
                 exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                 imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 image = [[UIImage alloc] initWithData:imageData];
                 handler(image,exifAttachments);
                 
             }
 
         }];

    }
    
}

#pragma mark - Add or Change Camera

- (void) addCaptureDevice: (NSInteger) AVDevicePosition
{
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error = nil;
    for (AVCaptureDevice *device in devices)
    {
        NSLog(@"Device name: %@", [device localizedName]);
        if ([device hasMediaType:AVMediaTypeVideo]){
            if ((AVDevicePosition == AVCaptureDevicePositionUnspecified ||
                AVDevicePosition == AVCaptureDevicePositionBack) &&
                [device position] == AVCaptureDevicePositionBack){
                    NSLog(@"Device position : back");
                    self.currentInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                    if (!error){
                        
                        [self.captureSession addInput:self.currentInputDevice];
                        break;
                    }
            }
            else if (AVDevicePosition == AVCaptureDevicePositionFront &&
                [device position] == AVCaptureDevicePositionFront){
                    NSLog(@"Device position : front");
                    self.currentInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                    if (!error){
                        [self.captureSession addInput:self.currentInputDevice];
                        break;
                    }
            }
        }
    }
}

- (void) switchCameraDevices
{
    if (self.captureSession && self.currentInputDevice) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.currentInputDevice];
        NSLog(@"Remove CurrentDevice");
        if ([self.currentInputDevice device].position == AVCaptureDevicePositionFront) {
            [self addCaptureDevice:AVCaptureDevicePositionBack];
        }
        else if ([self.currentInputDevice device].position == AVCaptureDevicePositionBack) {
            [self addCaptureDevice:AVCaptureDevicePositionFront];
        }
        [self.captureSession commitConfiguration];
    }
}

#pragma mark - Camera Settings

- (void) setFocusMode: (NSInteger)AVFocusMode
{
    if (self.captureSession && self.currentInputDevice){
        AVCaptureDevice *device = [self.currentInputDevice device];
        switch (AVFocusMode) {
            case AVCaptureFocusModeLocked:
                if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.focusMode = AVCaptureFocusModeLocked;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureFocusModeAutoFocus:
                if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.focusMode = AVCaptureFocusModeAutoFocus;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureFocusModeContinuousAutoFocus:
                if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                        [device unlockForConfiguration];
                    }
                }
                break;
        }
    }
}

- (void) setFlashMode:(NSInteger) AVFlashMode
{
    if (self.captureSession && self.currentInputDevice){
        AVCaptureDevice *device = [self.currentInputDevice device];
        switch (AVFlashMode) {
            case AVCaptureFlashModeOff:
                if ([device isFlashModeSupported:AVCaptureFlashModeOff]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.flashMode = AVCaptureFlashModeOff;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureFlashModeOn:
                if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.flashMode = AVCaptureFlashModeOn;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureFlashModeAuto:
                if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.flashMode = AVCaptureFlashModeAuto;
                        [device unlockForConfiguration];
                    }
                }
                break;
        }
    }
}

- (void) setExposureMode:(NSInteger) AVExposureMode
{
    if (self.captureSession && self.currentInputDevice){
        AVCaptureDevice *device = [self.currentInputDevice device];
        switch (AVExposureMode) {
            case AVCaptureExposureModeAutoExpose:
                if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.exposureMode = AVCaptureExposureModeAutoExpose;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureExposureModeContinuousAutoExposure:
                if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureExposureModeLocked:
                if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.exposureMode = AVCaptureExposureModeLocked;
                        [device unlockForConfiguration];
                    }
                }
                break;
        }
    }
}

- (void) setWhiteBalanceMode:(NSInteger) AVWhiteBalanceMode
{
    if (self.captureSession && self.currentInputDevice){
        AVCaptureDevice *device = [self.currentInputDevice device];
        switch (AVWhiteBalanceMode) {
            case AVCaptureWhiteBalanceModeAutoWhiteBalance:
                if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance:
                if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
                        [device unlockForConfiguration];
                    }
                }
                break;
            case AVCaptureWhiteBalanceModeLocked:
                if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
                        [device unlockForConfiguration];
                    }
                }
                break;
        }
    }
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self.captureSession)
    {
        [self addCaptureDevice:AVCaptureDevicePositionBack];
        [self setFocusMode:AVCaptureFocusModeAutoFocus];
        [self setFlashMode:AVCaptureFlashModeOff];
        [self setExposureMode:AVCaptureExposureModeLocked];
        [self setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    }
    return self;
}

- (instancetype)initWithSpecificCamera:(NSInteger) AVDevicePosition
                             focusMode: (NSInteger) AVFocusMode
                             flashMode: (NSInteger) AVFlashMode
                          exposureMode: (NSInteger) AVExposureMode
                      whiteBalanceMode: (NSInteger) AVWhiteBalanceMode
{
    self = [super init];
    if (self.captureSession)
    {
        [self addCaptureDevice:AVDevicePosition];
        [self setFocusMode:AVFocusMode];
        [self setFlashMode:AVFlashMode];
        [self setExposureMode:AVExposureMode];
        [self setWhiteBalanceMode:AVWhiteBalanceMode];
    }
    
    return self;
    
}


@end
