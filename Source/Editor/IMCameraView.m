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

#import <Masonry/View+MASAdditions.h>
#import <ImojiSDKUI/IMCameraView.h>

CGFloat const NavigationBarHeight = 82.0f;
CGFloat const DefaultButtonTopOffset = 30.0f;
CGFloat const CaptureButtonBottomOffset = 20.0f;
CGFloat const CameraViewBottomButtonBottomOffset = 28.0f;

@implementation IMCameraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }

    return self;
}

- (void)setup {
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiEditorAssets" ofType:@"bundle"];
    self.backgroundColor = [UIColor colorWithRed:48.0f / 255.0f green:48.0f / 255.0f blue:48.0f / 255.0f alpha:1.0f];

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

    // Add subviews
    [self addSubview:self.navigationBar];
    [self addSubview:self.photoLibraryButton];
    [self addSubview:self.flipButton];
    [self addSubview:self.captureButton];

    // Constraints
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@(NavigationBarHeight));
    }];

    [self.photoLibraryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-CameraViewBottomButtonBottomOffset);
        make.left.equalTo(self).offset(34.0f);
    }];

    [self.flipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-CameraViewBottomButtonBottomOffset);
        make.right.equalTo(self).offset(-30.0f);
    }];

    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-CaptureButtonBottomOffset);
        make.centerX.equalTo(self);
    }];
}

#pragma mark Camera button logic

- (void)captureButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapCaptureButtonFromCameraView:)]) {
        [self.delegate userDidTapCaptureButtonFromCameraView:self];
    }
}

- (void)flipButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapFlipButtonFromCameraView:)]) {
        [self.delegate userDidTapFlipButtonFromCameraView:self];
    }
}

- (void)photoLibraryButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapPhotoLibraryButtonFromCameraView:)]) {
        [self.delegate userDidTapPhotoLibraryButtonFromCameraView:self];
    }
}

- (void)cancelButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapCancelButtonFromCameraView:)]) {
        [self.delegate userDidTapCancelButtonFromCameraView:self];
    }
}

@end
