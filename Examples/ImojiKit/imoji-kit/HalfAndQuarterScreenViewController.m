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
#import "HalfAndQuarterScreenViewController.h"
#import "MessageThreadView.h"
#import <ImojiSDK/IMImojiCategoryObject.h>
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMHalfAndQuarterScreenView.h>
#import <ImojiSDKUI/IMHalfScreenView.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/Masonry.h>

@interface HalfAndQuarterScreenViewController () <IMCollectionViewDelegate, IMSearchViewDelegate, IMStickerSearchContainerViewDelegate>

@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) IMHalfAndQuarterScreenView *halfAndQuarterScreenView;
@property(nonatomic, strong) UIView *searchViewTopBorder;

@property(nonatomic) BOOL imojiSearchViewActionTapped;
@property(nonatomic) BOOL halfScreenSuggestionViewDisplayed;
@property(nonatomic) BOOL quarterScreenSuggestionViewDisplayed;

@end

@implementation HalfAndQuarterScreenViewController {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Half And Quarter Screen";
    }

    return self;
}

- (void)loadView {
    [super loadView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputFieldWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputFieldWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    // this essentially sets the status bar color since the view takes up the full screen
    // and the subviews are positioned below the status bar
    self.view.backgroundColor = [UIColor colorWithRed:248.0f / 255.0f green:248.0f / 255.0f blue:248.0f / 255.0f alpha:1.0f];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_back.png", [IMResourceBundleUtil assetsBundle].bundlePath]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonTapped)];
    [self.navigationController setTitle:self.title];

    // Message Thread View Setup
    self.messageThreadView = [[MessageThreadView alloc] init];
    self.messageThreadView.backgroundColor = [UIColor whiteColor];
    [self.messageThreadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageThreadViewTapped)]];

    // Sticker search container view setup
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];
    self.halfAndQuarterScreenView = [IMHalfAndQuarterScreenView imojiStickerSearchContainerViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.halfAndQuarterScreenView.delegate = self;
    self.halfAndQuarterScreenView.searchView.createAndRecentsEnabled = [shared boolForKey:@"createAndRecents"];
    self.halfAndQuarterScreenView.imojiSuggestionView.collectionView.renderingOptions.borderStyle = (IMImojiObjectBorderStyle) [shared integerForKey:@"stickerBorders"];

    // Subviews
    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.halfAndQuarterScreenView];

    [self.messageThreadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.view);
    }];

    [self.halfAndQuarterScreenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    self.searchViewTopBorder = [[UIView alloc] init];
    self.searchViewTopBorder.backgroundColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f];
    self.searchViewTopBorder.hidden = YES;
    [self.halfAndQuarterScreenView.searchView addSubview:self.searchViewTopBorder];

    [self.searchViewTopBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.halfAndQuarterScreenView.searchView).offset(-1.0f);
        make.left.right.equalTo(self.halfAndQuarterScreenView.searchView);
        make.height.equalTo(@1.0f);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark IMSearchView Delegate

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewActionTapped = YES;
    [self showHalfScreenSuggestionViewAnimated];
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewActionTapped = YES;
    [self showHalfScreenSuggestionViewAnimated];
}

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    [self showHalfScreenSuggestionViewAnimated];
}

#pragma mark IMSuggestionView

- (void)showQuarterScreenSuggestionViewAnimated:(BOOL)animated {
    if (self.quarterScreenSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    self.quarterScreenSuggestionViewDisplayed = YES;
    self.halfScreenSuggestionViewDisplayed = NO;
    self.searchViewTopBorder.hidden = YES;
    self.halfAndQuarterScreenView.searchView.backButtonType = IMSearchViewBackButtonTypeDisabled;

    [self.halfAndQuarterScreenView setupViewAsQuarterScreen];

    [self.halfAndQuarterScreenView.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];

    if (animated) {
        [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)showHalfScreenSuggestionViewAnimated {
    if (self.halfScreenSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    self.searchViewTopBorder.hidden = NO;
    self.halfAndQuarterScreenView.searchView.backButtonType = IMSearchViewBackButtonTypeBack;

    [self.halfAndQuarterScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.height.equalTo(@(IMHalfScreenViewDefaultHeight));
    }];

    [self.halfAndQuarterScreenView setupViewAsHalfScreen];

    [self.halfAndQuarterScreenView.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];

    [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
        [self.halfAndQuarterScreenView.searchView.searchTextField resignFirstResponder];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                2.0f * IMSuggestionViewDefaultHeight + self.halfAndQuarterScreenView.searchView.frame.size.height,
                0
        );
        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

        self.halfScreenSuggestionViewDisplayed = YES;
        self.quarterScreenSuggestionViewDisplayed = NO;
    }];
}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    if (!self.quarterScreenSuggestionViewDisplayed && !self.halfScreenSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    self.halfAndQuarterScreenView.searchView.backButtonType = IMSearchViewBackButtonTypeDisabled;

    [self.halfAndQuarterScreenView resetView];

    if (animated) {
        [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.halfScreenSuggestionViewDisplayed) {
                self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                        self.messageThreadView.scrollIndicatorInsets.bottom - 2.0f * self.halfAndQuarterScreenView.imojiSuggestionView.frame.size.height,
                        0
                );
                self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

                if (self.messageThreadView.empty) {
                    [self.messageThreadView.collectionViewLayout invalidateLayout];
                } else {
                    [self.messageThreadView scrollToBottom];
                }

                self.searchViewTopBorder.hidden = YES;
                self.quarterScreenSuggestionViewDisplayed = NO;
                self.halfScreenSuggestionViewDisplayed = NO;
            }
        }];
    } else {
        self.searchViewTopBorder.hidden = YES;
        self.quarterScreenSuggestionViewDisplayed = NO;
        self.halfScreenSuggestionViewDisplayed = NO;
    }

    [self.halfAndQuarterScreenView.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [((AppDelegate *)[UIApplication sharedApplication].delegate).session markImojiUsageWithIdentifier:imoji.identifier originIdentifier:@"imoji kit half+quarter: imoji selected"];
    });

    [self.messageThreadView sendMessageWithImoji:imoji];
}

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category contributingImoji:(nullable IMImojiImageReference *)imojiImage fromCollectionView:(nonnull IMCollectionView *)collectionView {
    self.imojiSearchViewActionTapped = YES;

    [self showHalfScreenSuggestionViewAnimated];
}

#pragma mark Keyboard Handling

- (void)messageThreadViewTapped {
    [self hideSuggestionsAnimated:self.halfScreenSuggestionViewDisplayed];
    [self.halfAndQuarterScreenView.searchView.searchTextField resignFirstResponder];
}

- (void)inputFieldWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    self.imojiSearchViewActionTapped = NO;

    [self.halfAndQuarterScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight + IMSuggestionViewDefaultHeight));
        make.bottom.equalTo(self.view).offset(-endRect.size.height);
    }];

    if (!self.quarterScreenSuggestionViewDisplayed) {
        if (self.halfAndQuarterScreenView.searchView.searchTextField.text.length > 0) {
            [self showQuarterScreenSuggestionViewAnimated:YES];
        } else {
            [self.halfAndQuarterScreenView.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
            [self showQuarterScreenSuggestionViewAnimated:NO];
        }
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                endRect.size.height + self.halfAndQuarterScreenView.searchView.frame.size.height +
                        (self.quarterScreenSuggestionViewDisplayed ? self.halfAndQuarterScreenView.imojiSuggestionView.frame.size.height : 0),
                0
        );
        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

        if (self.messageThreadView.empty) {
            [self.messageThreadView.collectionViewLayout invalidateLayout];
        } else {
            [self.messageThreadView scrollToBottom];
        }
    }];
}

- (void)inputFieldWillHide:(NSNotification *)notification {
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    if(!self.imojiSearchViewActionTapped) {
        [self.halfAndQuarterScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
            make.bottom.equalTo(self.view);
        }];
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                self.halfScreenSuggestionViewDisplayed ? 0.0f : self.halfAndQuarterScreenView.searchView.frame.size.height,
                0
        );

        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

        if (self.messageThreadView.empty) {
            [self.messageThreadView.collectionViewLayout invalidateLayout];
        } else {
            [self.messageThreadView scrollToBottom];
        }

        self.imojiSearchViewActionTapped = NO;
    }];
}

#pragma mark Navigation Bar Button Actions

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark View controller overrides

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.messageThreadView.collectionViewLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.messageThreadView.collectionViewLayout invalidateLayout];
}

@end
