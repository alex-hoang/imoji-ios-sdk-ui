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

#import "AppDelegate.h"
#import "UISettingsViewController.h"
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/Masonry.h>
#import <ImojiSDK/IMImojiObjectRenderingOptions.h>

@interface UISettingsViewController ()
@property(nonatomic, strong) UILabel *stickerBorderLabel;
@property(nonatomic, strong) UILabel *createAndRecentsLabel;
@property(nonatomic, strong) UISwitch *stickerBorderSwitch;
@property(nonatomic, strong) UISwitch *createAndRecentsSwitch;
@end

@implementation UISettingsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"UI Settings";
    }

    return self;
}

- (void)loadView {
    [super loadView];

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_back.png", [IMResourceBundleUtil assetsBundle].bundlePath]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonTapped)];
    [self.navigationController setTitle:self.title];

    UIView *createAndRecentsContainer = [[UIView alloc] init];

    self.createAndRecentsLabel = [[UILabel alloc] init];
    self.createAndRecentsLabel.text = @"Create & Recents";
    self.createAndRecentsLabel.font = [IMAttributeStringUtil montserratLightFontWithSize:18.0f];
    self.createAndRecentsLabel.textColor = [UIColor colorWithRed:57.0f / 255.0f green:61.0f / 255.0f blue:73.0f / 255.0f alpha:1.0f];

    self.createAndRecentsSwitch = [[UISwitch alloc] init];
    self.createAndRecentsSwitch.onTintColor = [UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
    self.createAndRecentsSwitch.on = [shared boolForKey:@"createAndRecents"];
    [self.createAndRecentsSwitch addTarget:self action:@selector(createAndRecentsSwitchTapped) forControlEvents:UIControlEventTouchUpInside];

    UIView *stickerBorderContainer = [[UIView alloc] init];

    self.stickerBorderLabel = [[UILabel alloc] init];
    self.stickerBorderLabel.text = @"Sticker Borders";
    self.stickerBorderLabel.font = [IMAttributeStringUtil montserratLightFontWithSize:18.0f];
    self.stickerBorderLabel.textColor = [UIColor colorWithRed:57.0f / 255.0f green:61.0f / 255.0f blue:73.0f / 255.0f alpha:1.0f];

    self.stickerBorderSwitch = [[UISwitch alloc] init];
    self.stickerBorderSwitch.onTintColor = [UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
    self.stickerBorderSwitch.on = [shared integerForKey:@"stickerBorders"] == IMImojiObjectBorderStyleSticker;
    [self.stickerBorderSwitch addTarget:self action:@selector(stickerBorderSwitchTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:createAndRecentsContainer];
    [self.view addSubview:stickerBorderContainer];

    [createAndRecentsContainer addSubview:self.createAndRecentsLabel];
    [createAndRecentsContainer addSubview:self.createAndRecentsSwitch];

    [stickerBorderContainer addSubview:self.stickerBorderLabel];
    [stickerBorderContainer addSubview:self.stickerBorderSwitch];

    [createAndRecentsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(17.0f);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@56.0f);
    }];

    [self.createAndRecentsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(createAndRecentsContainer).offset(20.0f);
        make.centerY.equalTo(createAndRecentsContainer);
    }];

    [self.createAndRecentsSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(createAndRecentsContainer).offset(-20.0f);
        make.centerY.equalTo(createAndRecentsContainer);
    }];

    [stickerBorderContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(createAndRecentsContainer.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@56.0f);
    }];

    [self.stickerBorderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(stickerBorderContainer).offset(20.0f);
        make.centerY.equalTo(stickerBorderContainer);
    }];

    [self.stickerBorderSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(stickerBorderContainer).offset(-20.0f);
        make.centerY.equalTo(stickerBorderContainer);
    }];
}

- (void)createAndRecentsSwitchTapped {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];
    [shared setBool:![shared boolForKey:@"createAndRecents"] forKey:@"createAndRecents"];
    [shared synchronize];

}

- (void)stickerBorderSwitchTapped {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];

    [shared setInteger:([shared integerForKey:@"stickerBorders"] == IMImojiObjectBorderStyleSticker ? IMImojiObjectBorderStyleNone : IMImojiObjectBorderStyleSticker)
                forKey:@"stickerBorders"];
    [shared synchronize];
}

#pragma mark Navigation Bar Button Actions

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark View controller overrides

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

@end
