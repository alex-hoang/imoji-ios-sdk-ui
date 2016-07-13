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
#import <ImojiSDKUI/IMCreateImojiUITheme.h>
#import <ImojiSDKUI/IMCameraViewController.h>
#import <ImojiSDK/IMImojiSession.h>
#import <Masonry/View+MASAdditions.h>
#import <ImojiSDKUI/ImojiSDKUI-Swift.h>

CGFloat const NavigationBarHeight = 82.0f;
CGFloat const DefaultButtonTopOffset = 30.0f;
CGFloat const CaptureButtonBottomOffset = 20.0f;
CGFloat const CameraViewBottomButtonBottomOffset = 28.0f;

@class IMDrawingUtils;

@interface IMCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
    }

    return self;
}

- (void)loadView {
    [super loadView];

    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiEditorAssets" ofType:@"bundle"];
    self.view.backgroundColor = [UIColor colorWithRed:48.0f / 255.0f green:48.0f / 255.0f blue:48.0f / 255.0f alpha:1.0f];

    // Set up toolbar buttons
    _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.captureButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/camera_button.png", bundlePath]] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(captureButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/camera_cancel.png", bundlePath]] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.imageEdgeInsets = UIEdgeInsetsMake(6.25f, 6.25f, 6.25f, 6.25f);
    cancelButton.frame = CGRectMake(0, 0, 50.0f, 50.0f);
    _cancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];

    _flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flipButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/camera_flipcam.png", bundlePath]] forState:UIControlStateNormal];
    [self.flipButton addTarget:self action:@selector(flipButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    _photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.photoLibraryButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/camera_photos.png", bundlePath]] forState:UIControlStateNormal];
    [self.photoLibraryButton addTarget:self action:@selector(photoLibraryButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    // Set up top nav bar
    _navigationBar = [[UIToolbar alloc] init];
    self.navigationBar.clipsToBounds = YES;
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor clearColor];

    [self determineCancelCameraButtonVisibility];

    // Setup AVCaptureSession
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;

    // Get available devices and save reference to front and back cameras
    NSArray *availableCameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in availableCameraDevices) {
        if(device.position == AVCaptureDevicePositionBack) {
            self.backCameraDevice = device;
        } else if(device.position == AVCaptureDevicePositionFront) {
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

        if([self.captureSession canAddInput:cameraInput]) {
            [self.captureSession addInput:cameraInput];
        }

        [self.captureSession commitConfiguration];
    }

    // Add the still image capture to AVCaptureSession
    self.stillCameraOutput = [[AVCaptureStillImageOutput alloc] init];
    if([self.captureSession canAddOutput:self.stillCameraOutput]) {
        [self.captureSession addOutput:self.stillCameraOutput];
    }

    // Add subviews
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.photoLibraryButton];
    [self.view addSubview:self.flipButton];
    [self.view addSubview:self.captureButton];

    // Constraints
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(NavigationBarHeight));
    }];

    [self.photoLibraryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-CameraViewBottomButtonBottomOffset);
        make.left.equalTo(self.view).offset(34.0f);
    }];

    [self.flipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-CameraViewBottomButtonBottomOffset);
        make.right.equalTo(self.view).offset(-30.0f);
    }];

    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-CaptureButtonBottomOffset);
        make.centerX.equalTo(self.view);
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
    [self.view insertSubview:self.previewView belowSubview:self.navigationBar];

    // Start AVCaptureSession
#if TARGET_IPHONE_SIMULATOR
#else
    if(self.checkAuthorizationStatus == AVAuthorizationStatusAuthorized) {
        dispatch_async(self.captureSessionQueue, ^{
            [self.captureSession startRunning];
        });
    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Stop tracking accelerometer
    [self.captureMotionManager stopAccelerometerUpdates];

    // Remove preview from the view
    [self.previewLayer removeFromSuperlayer];
    [self.previewView removeFromSuperview];

    // Stop running AVCaptureSession
#if TARGET_IPHONE_SIMULATOR
#else
    if(self.checkAuthorizationStatus == AVAuthorizationStatusAuthorized) {
        dispatch_async(self.captureSessionQueue, ^{
            [self.captureSession stopRunning];
        });
    }
#endif
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (AVAuthorizationStatus)checkAuthorizationStatus{
    __block AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:
            // permission dialog not yet presented, request authorization
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    authorizationStatus = AVAuthorizationStatusAuthorized;
                } else {
                    // user denied, nothing much to do
                    authorizationStatus = AVAuthorizationStatusDenied;
                }
            }];
            break;
        case AVAuthorizationStatusAuthorized:
            // go ahead
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // the user explicitly denied camera usage or is not allowed to access the camera devices
            break;
    }

    return authorizationStatus;
}

- (void)determineCancelCameraButtonVisibility {
    if(self.navigationBar.items) {
        NSUInteger index = [self.navigationBar.items indexOfObject:self.cancelButton];
        NSMutableArray *barItems = [[NSMutableArray alloc] initWithArray:self.navigationBar.items];

        [barItems removeObjectAtIndex:index];

        self.navigationBar.items = barItems;
    }

    if(self.delegate && [self.delegate respondsToSelector:@selector(userDidCancelCameraViewController:)]) {
        self.navigationBar.items = @[self.cancelButton];
    }
}

#pragma mark Camera button logic
- (void)captureButtonTapped {
    dispatch_async(self.captureSessionQueue, ^{
        AVCaptureConnection *connection = [self.stillCameraOutput connectionWithMediaType:AVMediaTypeVideo];
        [self.stillCameraOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
            if (error) {
                NSLog(@"error while capturing still image: %@", error);
                [self showCaptureErrorAlertTitle:@"Problems" message:@"Yikes! There was a problem taking the photo."];
            } else {
                // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                // we get the data already compressed as JPEG
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];

                // the sample buffer also contains the metadata, in case we want to modify it
                NSDictionary *metadata = (__bridge NSDictionary *) CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate);

                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    AVCaptureDeviceInput *currentCameraInput = self.captureSession.inputs.firstObject;
                    if (currentCameraInput.device.position == AVCaptureDevicePositionFront) {
                        image = [IMDrawingUtils flipImage:image];
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate userDidCaptureImage:image metadata:metadata fromCameraViewController:self];
                    });
                }
            }
        }];
    });
}

- (void)flipButtonTapped {
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

- (void)photoLibraryButtonTapped {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;

        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self showCaptureErrorAlertTitle:@"Photo Library Unavailable" message:@"Yikes! There's a problem accessing your photo library."];
    }
}

- (void)cancelButtonTapped {
    [self.delegate userDidCancelCameraViewController:self];
}

- (void)showCaptureErrorAlertTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    [self.delegate userDidPickMediaWithInfo:info fromImagePickerController:picker];
}

+ (instancetype)imojiCameraViewControllerWithSession:(IMImojiSession *)session {
    return [[IMCameraViewController alloc] initWithSession:session];
}

@end
