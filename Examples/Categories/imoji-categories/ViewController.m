//
//  ViewController.m
//  imoji-categories
//
//  Created by Nima on 9/18/15.
//  Copyright © 2015 Imoji. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <ImojiSDK/ImojiSDK.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMCollectionViewController.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import "ViewController.h"
#import <ImojiSDKUI/IMToolbar.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>

@interface ViewController () <IMCollectionViewControllerDelegate>

@property(nonatomic, strong) UIButton *reactionsButton;
@property(nonatomic, strong) UIButton *trendingButton;
@property(nonatomic, strong) UIButton *artistButton;
@property(nonatomic, strong) IMImojiSession *imojiSession;

@end

@implementation ViewController


- (void)loadView {
    [super loadView];

    _imojiSession = [IMImojiSession imojiSession];

    UILabel *title = [UILabel new];
    self.reactionsButton = [UIButton new];
    self.trendingButton = [UIButton new];
    self.artistButton = [UIButton new];

    self.view.backgroundColor = [UIColor colorWithRed:249.0f / 255.0f
                                                green:249.0f / 255.0f
                                                 blue:249.0f / 255.0f
                                                alpha:1.0f];

    self.reactionsButton.backgroundColor =
            self.trendingButton.backgroundColor =
                    self.artistButton.backgroundColor =
                            [UIColor colorWithRed:44.0f / 255.0f
                                            green:168.0f / 255.0f
                                             blue:224.0f / 255.0f
                                            alpha:1.0f];

    self.reactionsButton.layer.cornerRadius = self.trendingButton.layer.cornerRadius = self.artistButton.layer.cornerRadius = 5.0f;

    title.attributedText = [IMAttributeStringUtil attributedString:@"Imoji Categories"
                                                          withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                             color:[UIColor colorWithRed:120.0f / 255.0f
                                                                                   green:120.0f / 255.0f
                                                                                    blue:120.0f / 255.0f
                                                                                   alpha:1.0f]
                                                      andAlignment:NSTextAlignmentLeft
    ];

    [self.reactionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.trendingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.artistButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.reactionsButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Reactions"
                                                                            withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                               color:[UIColor whiteColor]
                                                                        andAlignment:NSTextAlignmentLeft]
                                    forState:UIControlStateNormal
    ];

    [self.trendingButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Trending"
                                                                           withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                              color:[UIColor whiteColor]
                                                                       andAlignment:NSTextAlignmentLeft]

                                   forState:UIControlStateNormal
    ];

    [self.artistButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Artist"
                                                                           withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                              color:[UIColor whiteColor]
                                                                       andAlignment:NSTextAlignmentLeft]

                                   forState:UIControlStateNormal
    ];

    [self.reactionsButton addTarget:self action:@selector(displayReactions) forControlEvents:UIControlEventTouchUpInside];
    [self.trendingButton addTarget:self action:@selector(displayTrending) forControlEvents:UIControlEventTouchUpInside];
    [self.artistButton addTarget:self action:@selector(displayArtist) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:title];
    [self.view addSubview:self.reactionsButton];
    [self.view addSubview:self.trendingButton];
    [self.view addSubview:self.artistButton];

    [self.reactionsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.trendingButton);
        make.bottom.equalTo(self.trendingButton.mas_top).offset(-20.0f);
    }];
    [self.trendingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(.65f);
        make.height.equalTo(self.view.mas_width).multipliedBy(.65f / 4.0f);
    }];
    [self.artistButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.trendingButton);
        make.top.equalTo(self.trendingButton.mas_bottom).offset(20.0f);
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.reactionsButton.mas_top).offset(-10.0f);
    }];

    self.title = @"Categories";
}

- (void)displayReactions {
    [self displayCollectionViewControllerWithCategory:IMImojiSessionCategoryClassificationGeneric];
}

- (void)displayTrending {
    [self displayCollectionViewControllerWithCategory:IMImojiSessionCategoryClassificationTrending];
}

- (void)displayArtist {
    [self displayCollectionViewControllerWithCategory:IMImojiSessionCategoryClassificationArtist];
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView {
    [collectionView loadImojisFromCategory:category];
}

- (void)userDidSelectImoji:(IMImojiObject *__nonnull)imoji fromCollectionView:(IMCollectionView *__nonnull)collectionView {
    IMImojiObjectRenderingOptions *renderingOptions =
            [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution];
    renderingOptions.aspectRatio = [NSValue valueWithCGSize:CGSizeMake(16.0f, 9.0f)];

    [self.imojiSession renderImoji:imoji
                           options:renderingOptions
                          callback:^(UIImage *image, NSError *error) {
                              NSArray *sharingItems = @[image];
                              UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems
                                                                                                               applicationActivities:nil];
                              activityController.excludedActivityTypes = @[
                                      UIActivityTypePrint,
                                      UIActivityTypeCopyToPasteboard,
                                      UIActivityTypeAssignToContact,
                                      UIActivityTypeSaveToCameraRoll,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypePostToFlickr,
                                      UIActivityTypePostToVimeo
                              ];

                              [self.presentedViewController presentViewController:activityController animated:YES completion:nil];
                          }];
}

- (void)userDidSelectSplash:(IMCollectionViewSplashCellType)splashType fromCollectionView:(IMCollectionView *)collectionView {
    if (splashType == IMCollectionViewSplashCellNoResults) {
        [((IMCollectionViewController *) self.presentedViewController).searchField becomeFirstResponder];
    }
}

- (void)userDidSelectToolbarButton:(IMToolbarButtonType)buttonType {
    switch (buttonType) {
        case IMToolbarButtonReactions:
            [((IMCollectionViewController *) self.presentedViewController).collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
            break;

        case IMToolbarButtonTrending:
            [((IMCollectionViewController *) self.presentedViewController).collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
            break;

        case IMToolbarButtonArtist:
            [((IMCollectionViewController *) self.presentedViewController).collectionView loadImojiCategories:IMImojiSessionCategoryClassificationArtist];
            break;

        case IMToolbarButtonBack:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;

        default:
            break;
    }
}

- (void)userDidSelectAttributionLink:(NSURL *)attributionLink fromCollectionView:(IMCollectionView *)collectionView {
    [[UIApplication sharedApplication] openURL:attributionLink];
}

- (void)displayCollectionViewControllerWithCategory:(IMImojiSessionCategoryClassification)categoryClassification {
    IMCollectionViewController *viewController = [IMCollectionViewController collectionViewControllerWithSession:self.imojiSession];
    viewController.collectionView.collectionViewDelegate = self;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    viewController.backButton.hidden = NO;

    [viewController.bottomToolbar addFlexibleSpace];
    [viewController.bottomToolbar addToolbarButtonWithType:IMToolbarButtonReactions];
    [viewController.bottomToolbar addToolbarButtonWithType:IMToolbarButtonTrending];
    [viewController.bottomToolbar addToolbarButtonWithType:IMToolbarButtonArtist];
    [viewController.bottomToolbar addFlexibleSpace];

    viewController.topToolbar.barTintColor =
            viewController.bottomToolbar.barTintColor =
                    [UIColor colorWithRed:55.0f / 255.0f green:123.0f / 255.0f blue:167.0f / 255.0f alpha:1.0f];

    viewController.collectionViewControllerDelegate = self;

    [self presentViewController:viewController animated:YES completion:^{
        switch (categoryClassification) {
            case IMImojiSessionCategoryClassificationTrending:
                [viewController.bottomToolbar selectButtonOfType:IMToolbarButtonTrending];
                break;
            case IMImojiSessionCategoryClassificationGeneric:
                [viewController.bottomToolbar selectButtonOfType:IMToolbarButtonReactions];
                break;
            case IMImojiSessionCategoryClassificationArtist:
                [viewController.bottomToolbar selectButtonOfType:IMToolbarButtonArtist];
                break;
            default:
                break;
        }
    }];
}

@end
