//
//  ImojiSDKUI
//
//  Created by Alex Hoang
//  Copyright (C) 2016 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <ImojiSDKUI/IMCameraViewController.h>
#import <ImojiSDKUI/IMDrawingUtils.h>
#import <Masonry/View+MASAdditions.h>

@interface IMCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMCameraViewDelegate>

// AVFoundation variables
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureDevice *backCameraDevice;
@property(nonatomic, strong) AVCaptureDevice *frontCameraDevice;
@property(nonatomic, strong) AVCaptureStillImageOutput *stillCameraOutput;
@property(nonatomic, strong) CMMotionManager *captureMotionManager;
@property(nonatomic, strong) dispatch_queue_t captureSessionQueue;
@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation IMCameraViewController {

}

#pragma mark Object lifecycle

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        _session = session;

        // Create queue for AVCaptureSession
        self.captureSessionQueue = dispatch_queue_create("com.sopressata.imoji_camera.capture_session", DISPATCH_QUEUE_SERIAL);

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkAuthorizationStatus)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }

    return self;
}

- (void)loadView {
    [super loadView];

    // Setup AVCaptureSession
    self.captureSession = [[AVCaptureSession alloc] init];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }

    // Get available devices and save reference to front and back cameras
    NSArray *availableCameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in availableCameraDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.backCameraDevice = device;
        } else if (device.position == AVCaptureDevicePositionFront) {
            self.frontCameraDevice = device;
        }
    }

    [self.captureSession beginConfiguration];

    NSError *error;
    AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontCameraDevice error:&error];
    if (error) {
        NSLog(@"error while performing camera configuration: %@", error);
    } else {
        [cameraInput.device lockForConfiguration:&error];

        if (error) {
            NSLog(@"error while performing camera configuration: %@", error);
        } else {
            if ([cameraInput.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                cameraInput.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }

            if ([cameraInput.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                cameraInput.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }

            [cameraInput.device unlockForConfiguration];
        }

        if ([self.captureSession canAddInput:cameraInput]) {
            [self.captureSession addInput:cameraInput];
        }

        [self.captureSession commitConfiguration];
    }

    // Add the still image capture to AVCaptureSession
    self.stillCameraOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self.captureSession canAddOutput:self.stillCameraOutput]) {
        [self.captureSession addOutput:self.stillCameraOutput];
    }

    [self setupCameraView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setupCameraView {
    _cameraView = [[IMCameraView alloc] initWithFrame:CGRectZero];
    self.cameraView.delegate = self;

    [self determineCancelCameraButtonVisibility];

    [self.view addSubview:self.cameraView];

    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Start tracking accelerometer data
    self.captureMotionManager = [[CMMotionManager alloc] init];
    self.captureMotionManager.accelerometerUpdateInterval = 0.2f;
    [self.captureMotionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        if (accelerometerData) {
            // Set the image orientation based on device orientation
            // This will work even if the orientation is locked on the device
            _currentOrientation = fabs(accelerometerData.acceleration.y) < fabs(accelerometerData.acceleration.x)
                    ? accelerometerData.acceleration.x > 0 ? UIImageOrientationRight : UIImageOrientationLeft
                    : accelerometerData.acceleration.y > 0 ? UIImageOrientationDown : UIImageOrientationUp;
        }
    }];

    // Reset preview
    self.previewView = [[UIView alloc] initWithFrame:CGRectZero];
    self.previewView.backgroundColor = self.view.backgroundColor;
    self.previewView.frame = self.view.frame;

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = self.previewView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.previewLayer];

    // Add preview
    [self.cameraView insertSubview:self.previewView belowSubview:self.cameraView.navigationBar];

    // Start AVCaptureSession
    if ([self checkAuthorizationStatus] == AVAuthorizationStatusAuthorized) {
        [self startRunningCaptureSession];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Stop tracking accelerometer
    [self.captureMotionManager stopAccelerometerUpdates];

    // Remove preview from the view
    [self.previewLayer removeFromSuperlayer];
    [self.previewView removeFromSuperview];

    // Stop running AVCaptureSession
    if ([self checkAuthorizationStatus] == AVAuthorizationStatusAuthorized) {
        [self stopRunningCaptureSession];
    }
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (AVAuthorizationStatus)checkAuthorizationStatus {
    __block AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            // permission dialog not yet presented, request authorization
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    authorizationStatus = AVAuthorizationStatusAuthorized;

                    [self startRunningCaptureSession];
                } else {
                    // user denied, nothing much to do
                    authorizationStatus = AVAuthorizationStatusDenied;
                }
            }];

            break;
        }
        case AVAuthorizationStatusAuthorized:
            break;
        case AVAuthorizationStatusDenied: {
            // the user explicitly denied camera usage
#if !IMOJI_APP_EXTENSION
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera" message:@"Taking photos requires access to your camera." preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Go to settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }]];

            [self presentViewController:alert animated:YES completion:nil];
#endif
            break;
        }
        case AVAuthorizationStatusRestricted: {
            // user is not allowed to access the camera devices
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera" message:@"Your camera is restricted. Please contact the device owner so they can give you access." preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];

            [self presentViewController:alert animated:YES completion:nil];

            break;
        }
    }

    return authorizationStatus;
}

- (void)determineCancelCameraButtonVisibility {
    if (self.cameraView.navigationBar.items) {
        NSUInteger index = [self.cameraView.navigationBar.items indexOfObject:self.cameraView.cancelButton];
        NSMutableArray *barItems = [[NSMutableArray alloc] initWithArray:self.cameraView.navigationBar.items];

        [barItems removeObjectAtIndex:index];

        self.cameraView.navigationBar.items = barItems;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidCancelCameraViewController:)]) {
        self.cameraView.navigationBar.items = @[self.cameraView.cancelButton];
    }
}

- (void)startRunningCaptureSession {
#if TARGET_IPHONE_SIMULATOR
#else
    dispatch_async(self.captureSessionQueue, ^{
        [self.captureSession startRunning];
    });
#endif
}

- (void)stopRunningCaptureSession {
#if TARGET_IPHONE_SIMULATOR
#else
    dispatch_async(self.captureSessionQueue, ^{
        [self.captureSession stopRunning];
    });
#endif
}

#pragma mark IMCameraViewDelegate

- (void)userDidTapCaptureButtonFromCameraView:(IMCameraView *)cameraView {
    dispatch_async(self.captureSessionQueue, ^{
        AVCaptureConnection *connection = [self.stillCameraOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection) {
            [self.stillCameraOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
                if (error) {
                    NSLog(@"error while capturing still image: %@", error);
                    [self showCaptureErrorAlertTitle:@"Problems" message:@"Yikes! There was a problem taking the photo."];
                } else {
                    // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                    // we get the data already compressed as JPEG
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];

                    // the sample buffer also contains the metadata, in case we want to modify it
                    CFDictionaryRef pDictionary = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
                    NSDictionary *metadata = (__bridge NSDictionary *) pDictionary;
                    CFRelease(pDictionary);

                    UIImage *image = [UIImage imageWithData:imageData];
                    if (image) {
                        AVCaptureDeviceInput *currentCameraInput = self.captureSession.inputs.firstObject;
                        if (currentCameraInput.device.position == AVCaptureDevicePositionFront) {
                            image = [IMDrawingUtils flipImage:image];
                        }

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.delegate && [self.delegate respondsToSelector:@selector(userDidCaptureImage:metadata:fromCameraViewController:)]) {
                                [self.delegate userDidCaptureImage:image metadata:metadata fromCameraViewController:self];
                            }
                        });
                    }
                }
            }];
        }
    });
}

- (void)userDidTapFlipButtonFromCameraView:(IMCameraView *)cameraView {
    dispatch_async(self.captureSessionQueue, ^{
        [self.captureSession beginConfiguration];

        AVCaptureDeviceInput *currentCameraInput = self.captureSession.inputs.firstObject;
        if (currentCameraInput) {
            [self.captureSession removeInput:currentCameraInput];

            NSError *error;
            AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:currentCameraInput.device.position == AVCaptureDevicePositionFront ? self.backCameraDevice : self.frontCameraDevice
                                                                                      error:&error];

            if (error) {
                NSLog(@"error while locking camera for configuration in flipButtonTapped(): %@", error);
            } else {
                [cameraInput.device lockForConfiguration:&error];

                if (error) {
                    NSLog(@"error while locking camera for configuration in flipButtonTapped(): %@", error);
                } else {
                    if ([cameraInput.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                        cameraInput.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                    }

                    if ([cameraInput.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                        cameraInput.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                    }

                    [cameraInput.device unlockForConfiguration];
                }

                if ([self.captureSession canAddInput:cameraInput]) {
                    [self.captureSession addInput:cameraInput];
                }
            }
        }

        [self.captureSession commitConfiguration];
    });
}

- (void)userDidTapPhotoLibraryButtonFromCameraView:(IMCameraView *)cameraView {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        picker.navigationBar.tintColor = [UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];

        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self showCaptureErrorAlertTitle:@"Photo Library Unavailable" message:@"Yikes! There's a problem accessing your photo library."];
    }
}

- (void)userDidTapCancelButtonFromCameraView:(IMCameraView *)cameraView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidCancelCameraViewController:)]) {
        [self.delegate userDidCancelCameraViewController:self];
    }
}

- (void)showCaptureErrorAlertTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidPickMediaWithInfo:fromImagePickerController:)]) {
        [self.delegate userDidPickMediaWithInfo:info fromImagePickerController:picker];
    }
}

+ (instancetype)imojiCameraViewControllerWithSession:(IMImojiSession *)session {
    return [[IMCameraViewController alloc] initWithSession:session];
}

@end
