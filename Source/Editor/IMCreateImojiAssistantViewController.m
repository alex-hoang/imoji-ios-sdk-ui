//
//  ImojiSDKUI
//
//  Created by Nima Khoshini
//  Copyright (C) 2015 Imoji
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

#import "IMCreateImojiAssistantViewController.h"
#import <Masonry/View+MASAdditions.h>
#import "IMResourceBundleUtil.h"
#import "IMAttributeStringUtil.h"
#import "IMCreateImojiUITheme.h"


@interface IMCreateImojiAssistantViewController ()

@property(nonatomic, strong, nonnull, readonly) UIView *tipsView;
@property(nonatomic, strong, nonnull, readonly) UIButton *proceedButton;
@property(nonatomic, strong, nonnull, readonly) UIButton *doneButton;
@property(nonatomic, strong, nonnull, readonly) UILabel *tipTitle;
@property(nonatomic, strong, nonnull, readonly) UILabel *tipDescription;
@property(nonatomic, strong, nonnull, readonly) UIImageView *tipImage;
@property(nonatomic, strong, nonnull, readonly) UIPageControl *pageControl;

@end

@implementation IMCreateImojiAssistantViewController {

}

- (instancetype)initWithSession:(nonnull IMImojiSession *)session {
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        _session = session;
    }

    return self;
}

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor clearColor];

    _tipsView = [UIView new];
    _proceedButton = [UIButton new];
    _doneButton = [UIButton new];
    _tipTitle = [UILabel new];
    _tipDescription = [UILabel new];
    _tipImage = [UIImageView new];
    _pageControl = [UIPageControl new];

    UIView *topImageBorder = [UIView new], *bottomImageBorder = [UIView new];

    [self.view addSubview:self.tipsView];
    [self.view addSubview:self.proceedButton];
    [self.view addSubview:self.doneButton];
    [self.view addSubview:self.pageControl];

    [self.tipsView addSubview:self.tipTitle];
    [self.tipsView addSubview:self.tipDescription];
    [self.tipsView addSubview:self.tipImage];
    [self.tipsView addSubview:topImageBorder];
    [self.tipsView addSubview:bottomImageBorder];

    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).multipliedBy(.961f);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(.72f);
        make.height.equalTo(self.view).multipliedBy(.615f);
    }];

    [self.proceedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).multipliedBy(.969f);
        make.width.height.equalTo(@60.0f);
    }];

    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.proceedButton);
    }];

    [self.tipTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.top.left.equalTo(self.tipsView);
        make.height.equalTo(self.tipsView).multipliedBy(.152f);
    }];

    [self.tipDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.equalTo(self.tipsView);
        make.width.equalTo(self.tipsView).multipliedBy(.75f);
        make.height.equalTo(self.tipsView).multipliedBy(.189f);
    }];

    [self.tipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.left.equalTo(self.tipsView);
        make.top.equalTo(self.tipTitle.mas_bottom);
        make.bottom.equalTo(self.tipDescription.mas_top);
    }];

    [topImageBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.tipImage);
        make.bottom.equalTo(self.tipImage.mas_top);
        make.height.equalTo(@.5f);
    }];
    [bottomImageBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.tipImage);
        make.top.equalTo(self.tipImage.mas_bottom);
        make.height.equalTo(@.5f);
    }];

    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipImage);
        make.top.equalTo(self.tipsView.mas_bottom).multipliedBy(1.005f);
    }];

    self.tipsView.backgroundColor = [UIColor colorWithWhite:248.f / 255.f alpha:1.0f];
    self.tipsView.layer.cornerRadius = 10.0f;

    self.tipImage.contentMode = UIViewContentModeScaleAspectFill;
    self.tipImage.clipsToBounds = YES;

    self.tipsView.layer.borderColor = [UIColor colorWithWhite:33.f / 255.f alpha:.08f].CGColor;
    self.tipsView.layer.borderWidth = 1.0f;
    self.tipsView.layer.shadowOpacity = .22f;
    self.tipsView.layer.shadowRadius = 3.f;
    self.tipsView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.tipsView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tipsView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.tipsView.layer.shouldRasterize = YES;

    [self.proceedButton setImage:[IMResourceBundleUtil rightArrowButtonImage:52.f
                                                                 circleColor:[UIColor clearColor]
                                                                 borderColor:[UIColor colorWithWhite:22.f / 255.f alpha:.4f]
                                                                 strokeWidth:4.0f
                                                                   iconImage:[IMCreateImojiUITheme instance].tagScreenHelpNextButtonImage]
                        forState:UIControlStateNormal];

    [self.proceedButton addTarget:self
                           action:@selector(proceedButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];

    [self.doneButton setImage:[IMResourceBundleUtil rightArrowButtonImage:52.f
                                                              circleColor:[UIColor clearColor]
                                                              borderColor:[UIColor colorWithWhite:22.f / 255.f alpha:.4f]
                                                              strokeWidth:4.0f
                                                                iconImage:[IMCreateImojiUITheme instance].tagScreenHelpDoneButtonImage]
                     forState:UIControlStateNormal];

    [self.doneButton addTarget:self
                           action:@selector(doneButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    self.doneButton.hidden = YES;

    self.tipDescription.font = self.tipTitle.font = [IMAttributeStringUtil defaultFontWithSize:15.f];
    self.tipDescription.textColor = self.tipTitle.textColor = [UIColor colorWithWhite:22.f / 255.f alpha:.4f];
    self.tipDescription.lineBreakMode = self.tipTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.tipDescription.textAlignment = self.tipTitle.textAlignment = NSTextAlignmentCenter;
    self.tipDescription.numberOfLines = 2;

    topImageBorder.backgroundColor = bottomImageBorder.backgroundColor =
            [UIColor colorWithWhite:22.f / 255.f alpha:.12f];

    self.pageControl.numberOfPages = 3;
    [self.pageControl addTarget:self
                         action:@selector(loadContentForCurrentPage)
               forControlEvents:UIControlEventValueChanged];
    [self loadContentForCurrentPage];
}

#pragma mark Page Control

- (void)proceedButtonTapped:(id)sender {
    self.pageControl.currentPage = self.pageControl.currentPage + 1;
    [self loadContentForCurrentPage];
}

- (void)doneButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadContentForCurrentPage {
    switch (self.pageControl.currentPage) {
        case 1:
            self.tipTitle.text = [IMResourceBundleUtil localizedStringForKey:@"tagScreenHelpStep2Title"];
            self.tipDescription.text = [IMResourceBundleUtil localizedStringForKey:@"tagScreenHelpStep2Description"];
            self.tipImage.image = [IMCreateImojiUITheme instance].tagScreenHelpImageStep2;
            self.proceedButton.hidden = NO;
            self.doneButton.hidden = YES;

            break;
        case 2:
            self.tipTitle.text = [IMResourceBundleUtil localizedStringForKey:@"tagScreenHelpStep3Title"];
            self.tipDescription.text = [IMResourceBundleUtil localizedStringForKey:@"tagScreenHelpStep3Description"];
            self.tipImage.image = [IMCreateImojiUITheme instance].tagScreenHelpImageStep3;
            self.proceedButton.hidden = YES;
            self.doneButton.hidden = NO;
            break;

        case 0:
        default:
            self.tipTitle.text = [IMResourceBundleUtil localizedStringForKey:@"tagScreenHelpStep1Title"];
            self.tipDescription.text = [IMResourceBundleUtil localizedStringForKey:@"tagScreenHelpStep1Description"];
            self.tipImage.image = [IMCreateImojiUITheme instance].tagScreenHelpImageStep1;
            self.proceedButton.hidden = NO;
            self.doneButton.hidden = YES;
            break;
    }
}

#pragma mark UIViewController Overrides

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.tipDescription.frame.size.height > 0) {
        self.tipDescription.font = self.tipTitle.font =
                [IMAttributeStringUtil defaultFontWithSize:self.tipDescription.frame.size.height * .2f];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark Initialization

+ (instancetype)createAssistantViewControllerWithSession:(nonnull IMImojiSession *)session {
    return [[IMCreateImojiAssistantViewController alloc] initWithSession:session];
}

@end
