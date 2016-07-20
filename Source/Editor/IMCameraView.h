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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

extern CGFloat const NavigationBarHeight;
extern CGFloat const DefaultButtonTopOffset;
extern CGFloat const CaptureButtonBottomOffset;
extern CGFloat const CameraViewBottomButtonBottomOffset;

@protocol IMCameraViewDelegate;

@interface IMCameraView : UIView

// Top toolbar
@property(nonatomic, strong, readonly, nullable) UIToolbar *navigationBar;
@property(nonatomic, strong, readonly, nullable) UIBarButtonItem *cancelButton;

// Bottom buttons
@property(nonatomic, strong, readonly, nullable) UIButton *captureButton;
@property(nonatomic, strong, readonly, nullable) UIButton *flipButton;
@property(nonatomic, strong, readonly, nullable) UIButton *photoLibraryButton;

@property(nonatomic, weak, nullable) id<IMCameraViewDelegate> delegate;

@end

@protocol IMCameraViewDelegate <NSObject>

@optional

- (void)userDidTapCancelButtonFromCameraView:(nonnull IMCameraView *)cameraView;

- (void)userDidTapCaptureButtonFromCameraView:(nonnull IMCameraView *)cameraView;

- (void)userDidTapFlipButtonFromCameraView:(nonnull IMCameraView *)cameraView;

- (void)userDidTapPhotoLibraryButtonFromCameraView:(nonnull IMCameraView *)cameraView;

@end
