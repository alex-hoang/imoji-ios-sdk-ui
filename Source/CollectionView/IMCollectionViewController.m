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

#import <Masonry/Masonry.h>
#import <ImojiSDKUI/IMCollectionViewController.h>
#import <ImojiSDKUI/IMCategoryCollectionViewCell.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDK/IMImojiCategoryObject.h>
#import <ImojiSDK/IMImojiObject.h>

CGFloat const IMCollectionViewControllerBottomBarDefaultHeight = 60.0f;
CGFloat const IMCollectionViewControllerTopBarDefaultHeight = 44.0f;
NSUInteger const IMCollectionViewControllerDefaultSearchDelayInMillis = 500;

#if __has_include(<ImojiGraphics/ImojiGraphics.h>) && __has_include(<ImojiSDKUI/IMCreateImojiViewController.h>) && !defined(IMOJI_APP_EXTENSION)
#define IMOJI_EDITOR_ENABLED 1
#import <ImojiSDKUI/ImojiSDKUI-Swift.h>
#import <ImojiSDKUI/IMCreateImojiViewController.h>
#import <ImojiSDKUI/IMCameraViewController.h>

@interface IMCollectionViewController () <IMSearchViewDelegate, IMToolbarDelegate, IMCollectionViewControllerDelegate,
        UIViewControllerPreviewingDelegate, UIActionSheetDelegate, IMCreateImojiViewControllerDelegate,
        IMCameraViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#else
#define IMOJI_EDITOR_ENABLED 0

@interface IMCollectionViewController () <IMSearchViewDelegate, IMToolbarDelegate, IMCollectionViewControllerDelegate,
        UIViewControllerPreviewingDelegate, UIActionSheetDelegate>

#endif
@property(nonatomic, strong) NSOperation *pendingSearchOperation;

@end

@implementation IMCollectionViewController {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setupCollectionViewControllerWithSession:session];
    }

    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupCollectionViewControllerWithSession:[IMImojiSession imojiSession]];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupCollectionViewControllerWithSession:[IMImojiSession imojiSession]];
    }

    return self;
}

- (void)setupCollectionViewControllerWithSession:(IMImojiSession *)session {
    self.session = session;

    _bottomToolbar = [IMToolbar new];
    _topToolbar = [IMToolbar new];
    _collectionView = [self createCollectionViewWithSession:session];
    _searchOnTextChanges = YES;
    _autoSearchDelayTimeInMillis = IMCollectionViewControllerDefaultSearchDelayInMillis;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDisplayedForSearchField:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideForSearchField:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    _searchView = [self.topToolbar addSearchViewItem].customView;
    _searchView.delegate = self;
    _backButton = self.searchView.backButton;

    _bottomToolbar.delegate = _topToolbar.delegate = self;

    self.collectionViewControllerDelegate = self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    self.view = [UIView new];

    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.topToolbar];
    [self.view addSubview:self.bottomToolbar];

    [self updateViewConstraints];

    [self setupControllerComponentsLookAndFeel];
}

- (void)setupControllerComponentsLookAndFeel {
    self.collectionView.backgroundColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];

    self.searchView.backgroundColor = [UIColor clearColor];
    self.searchView.backButtonType = IMSearchViewBackButtonTypeDismiss;
    self.searchView.searchTextField.returnKeyType = UIReturnKeySearch;

    self.topToolbar.barTintColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
    self.bottomToolbar.barTintColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];

    if ([self.collectionViewControllerDelegate respondsToSelector:@selector(backgroundColorForCollectionViewController:)]) {
        self.view.backgroundColor = [self.collectionViewControllerDelegate backgroundColorForCollectionViewController:self];
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.topToolbar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(IMCollectionViewControllerTopBarDefaultHeight));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];

    [self.bottomToolbar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(IMCollectionViewControllerBottomBarDefaultHeight));
        make.left.right.and.bottom.equalTo(self.view);
    }];

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.and.top.and.right.and.left.equalTo(self.topToolbar);
    }];

    self.bottomToolbar.hidden = !self.bottomToolbar.items || self.bottomToolbar.items.count == 0;

    // hide the top toolbar if both of the default components are hidden
    self.topToolbar.hidden = !self.topToolbar.items || self.topToolbar.items.count == 0 ||
            (self.backButton.hidden && self.searchView.searchTextField.hidden && self.topToolbar.items.count == 2);

    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset = UIEdgeInsetsMake(
            (!self.topToolbar.hidden ? IMCollectionViewControllerTopBarDefaultHeight : 0),
            0,
            (!self.bottomToolbar.hidden ? IMCollectionViewControllerBottomBarDefaultHeight : 0),
            0
    );
}

#pragma mark Notifications

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)keyboardDisplayedForSearchField:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    // adjust the content size for the keyboard using the displaced height
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset = UIEdgeInsetsMake(
            self.collectionView.contentInset.top,
            self.collectionView.contentInset.left,
            endRect.size.height,
            self.collectionView.contentInset.right
    );

    [self.collectionView.collectionViewLayout invalidateLayout];
//    [self.collectionView layoutIfNeeded];
}

- (void)keyboardWillHideForSearchField:(NSNotification *)notification {
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset = UIEdgeInsetsMake(
            self.collectionView.contentInset.top,
            self.collectionView.contentInset.left,
            self.bottomToolbar.hidden ? 0 : self.bottomToolbar.frame.size.height,
            self.collectionView.contentInset.right
    );

    [self.collectionView.collectionViewLayout invalidateLayout];
//    [self.collectionView layoutIfNeeded];
}

#pragma mark Overrides

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)setSearchOnTextChanges:(BOOL)searchOnTextChanges {
    _searchOnTextChanges = searchOnTextChanges;
}

- (void)setCollectionViewControllerDelegate:(id)collectionViewControllerDelegate {
    _collectionViewControllerDelegate = collectionViewControllerDelegate;
    _collectionView.collectionViewDelegate = collectionViewControllerDelegate;
}

#pragma mark CollectionViewDelegate

- (void)userDidSelectSplash:(IMCollectionViewSplashCellType)splashType fromCollectionView:(IMCollectionView *)collectionView {
    switch (splashType) {
        case IMCollectionViewSplashCellRecents:
        case IMCollectionViewSplashCellCollection:
            break;

        case IMCollectionViewSplashCellNoResults:
//            [self.searchField becomeFirstResponder];
            [self.searchView.searchTextField becomeFirstResponder];
            break;

        default:
            break;
    }
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView {
    self.searchView.searchTextField.text = category.title;
    self.searchView.searchTextField.rightView.hidden = NO;
    self.searchView.createButton.hidden = YES;
    self.searchView.recentsButton.hidden = YES;
    [self.searchView.searchTextField resignFirstResponder];

    [collectionView loadImojisFromCategory:category];
}

- (void)imojiCollectionViewDidScroll:(IMCollectionView *)collectionView {
    [self.searchView.searchTextField resignFirstResponder];
}

#pragma mark IMSearchView delegates

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView {
    if(!searchView.recentsButton.selected) {
        [searchView.searchViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(searchView).offset(IMSearchViewContainerDefaultLeftOffset);
        }];

        if (![searchView.searchIconImageView isDescendantOfView:searchView.searchViewContainer]) {
            [searchView.searchViewContainer addSubview:searchView.searchIconImageView];
        }
    }

    [searchView.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView.backButton.mas_right).offset(IMSearchViewBackButtonSearchIconOffset);
        make.centerY.equalTo(searchView.searchViewContainer);
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    if (searchView.recentsButton.selected) {
        [self.collectionView loadRecents];
    } else if (![searchView.previousSearchTerm isEqualToString:searchView.searchTextField.text]) {
        if([searchView.previousSearchTerm isEqualToString:@""]) {
            [self userDidClearTextFieldFromSearchView:searchView];
        } else {
            searchView.searchTextField.text = searchView.previousSearchTerm;
            [self performSearch];
        }
    }
}

#if IMOJI_EDITOR_ENABLED

- (void)userDidTapCreateButtonFromSearchView:(IMSearchView *)searchView {
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            IMCameraViewController *cameraViewController = [IMCameraViewController imojiCameraViewControllerWithSession:self.session];
            cameraViewController.delegate = self;
            cameraViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            [self presentViewController:cameraViewController animated:YES completion:nil];
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;

                [self presentViewController:imagePicker animated:YES completion:nil];
            }
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Photo Library", nil];

        [actionSheet showInView:self.view];
    }
}
#endif

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    searchView.createButton.hidden = YES;
    searchView.searchIconImageView.hidden = YES;

    [searchView.recentsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
        make.centerY.equalTo(searchView.searchViewContainer);
        make.left.equalTo(searchView.backButton.mas_right).offset(13.0f);
    }];

    [searchView.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView.recentsButton.mas_right).offset(2.0f);
        make.right.equalTo(searchView.searchViewContainer).offset(-6.0f);
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.centerY.equalTo(searchView.searchViewContainer);
    }];

    [self.collectionView loadRecents];
}

- (void)userDidClearTextFieldFromSearchView:(IMSearchView *)searchView {
    [self.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView {
    if (searchView.searchTextField.text.length == 0) {
        [self userDidClearTextFieldFromSearchView:searchView];
    } else if (self.searchOnTextChanges) {
        if (self.pendingSearchOperation && !self.pendingSearchOperation.isCancelled) {
            [self.pendingSearchOperation cancel];
        }

        __block NSOperation *pendingSearchOperation = [NSOperation new];
        self.pendingSearchOperation = pendingSearchOperation;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * self.autoSearchDelayTimeInMillis), dispatch_get_main_queue(), ^{
            if (!pendingSearchOperation.isCancelled && searchView.searchTextField.text.length != 0) {
                [self performSearch];
            }
        });
    }
}

- (void)performSearch {
    if (self.sentenceParseEnabled) {
        [self.collectionView loadImojisFromSentence:self.searchView.searchTextField.text];
    } else {
        [self.collectionView loadImojisFromSearch:self.searchView.searchTextField.text];
    }
}

- (void)userDidSelectToolbarButton:(IMToolbarButtonType)buttonType {
    if (self.collectionViewControllerDelegate && [self.collectionViewControllerDelegate respondsToSelector:@selector(userDidSelectToolbarButton:)]) {
        [self.collectionViewControllerDelegate userDidSelectToolbarButton:buttonType];
    }
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    if (![self conformsToProtocol:@protocol(IMCollectionViewControllerDelegate)] &&
            self.collectionViewControllerDelegate &&
            [self.collectionViewControllerDelegate respondsToSelector:@selector(positionForBar:)]) {
        return [self.collectionViewControllerDelegate positionForBar:bar];
    }

    return self.topToolbar == bar ?
            UIBarPositionTopAttached :
            self.bottomToolbar == bar ? UIBarPositionBottom : UIBarPositionAny;
}

#if IMOJI_EDITOR_ENABLED

#pragma mark IMCameraViewControllerDelegate

- (void)userDidCancelCameraViewController:(IMCameraViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidCaptureImage:(UIImage *)image metadata:(NSDictionary *)metadata fromCameraViewController:(IMCameraViewController *)viewController {
    IMCreateImojiViewController *createImojiViewController = [[IMCreateImojiViewController alloc] initWithSourceImage:image session: self.session];
    createImojiViewController.createDelegate = self;
    createImojiViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    createImojiViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:createImojiViewController animated: true completion: nil];
}

- (void)userDidPickMediaWithInfo:(NSDictionary<NSString *, id> *__nonnull)info fromImagePickerController:(UIImagePickerController *)picker {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    IMCreateImojiViewController *createImojiViewController = [[IMCreateImojiViewController alloc] initWithSourceImage:image session: self.session];
    createImojiViewController.createDelegate = self;
    createImojiViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    createImojiViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [picker presentViewController:createImojiViewController animated: true completion: nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    IMCreateImojiViewController *createImojiViewController = [[IMCreateImojiViewController alloc] initWithSourceImage:image session: self.session];
    createImojiViewController.createDelegate = self;
    createImojiViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    createImojiViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [picker presentViewController:createImojiViewController animated: true completion: nil];
}

#pragma mark IMCreateImojiViewControllerDelegate

- (void)imojiUploadDidBegin:(IMImojiObject *)localImoji fromViewController:(IMCreateImojiViewController *)viewController {
    [self.session markImojiUsageWithIdentifier:localImoji.identifier originIdentifier:@"imoji created"];
}

- (void)imojiUploadDidComplete:(IMImojiObject *)localImoji
               persistentImoji:(IMImojiObject *)persistentImoji
                     withError:(NSError *)error
            fromViewController:(IMCreateImojiViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];

    [self.searchView.recentsButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)userDidCancelImageEdit:(IMCreateImojiViewController *)viewController {
    [viewController dismissViewControllerAnimated:NO completion:nil];
}

#endif

#pragma mark Previewing Delegate (3D/Force Touch)

- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];

    if ([cell isKindOfClass:[IMCategoryCollectionViewCell class]]) {
        IMImojiCategoryObject *imojiCategory = [self.collectionView contentForIndexPath:indexPath];

        UIViewController *previewController = [[UIViewController alloc] init];
        previewController.preferredContentSize = CGSizeMake(0.0, 0.0);

        CGFloat cellRelativeOriginY = [self.collectionView convertRect:cell.frame toView:self.view].origin.y;
        // Check if part of the cell is under the bottom toolbar
        if(!self.bottomToolbar.hidden && cellRelativeOriginY + cell.frame.size.height > self.bottomToolbar.frame.origin.y) {
            // Only focus the part of the cell above the bottom toolbar.
            // Subtract the cell's height with the height of the part of the cell under the toolbar.
            previewingContext.sourceRect = CGRectMake(
                    cell.frame.origin.x,
                    cell.frame.origin.y,
                    cell.frame.size.width,
                    cell.frame.size.height - (cellRelativeOriginY + cell.frame.size.height - self.bottomToolbar.frame.origin.y)
            );
        } else if(!self.topToolbar.hidden && cellRelativeOriginY < self.topToolbar.frame.origin.y + self.topToolbar.frame.size.height) {
            // The same concept as the bottom bar happens for the top toolbar
            previewingContext.sourceRect = CGRectMake(
                    cell.frame.origin.x,
                    cell.frame.origin.y + (self.topToolbar.frame.origin.y + self.topToolbar.frame.size.height - cellRelativeOriginY),
                    cell.frame.size.width,
                    cell.frame.size.height - (self.topToolbar.frame.origin.y + self.topToolbar.frame.size.height - cellRelativeOriginY)
            );
        } else {
            previewingContext.sourceRect = cell.frame;
        }

        IMCollectionView *previewCollectionView = [IMCollectionView imojiCollectionViewWithSession:self.session];
        previewController.view = previewCollectionView;
        [previewCollectionView loadImojisFromCategory:imojiCategory];

        return previewController;
    }

    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:previewingContext.sourceRect.origin];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];

    if ([cell isKindOfClass:[IMCategoryCollectionViewCell class]]) {
        IMImojiCategoryObject *imojiCategory = [self.collectionView contentForIndexPath:indexPath];

        self.searchView.searchTextField.text = imojiCategory.title;
        self.searchView.searchTextField.rightView.hidden = NO;
        [self.collectionView loadImojisFromCategory:imojiCategory];
    }
}

#pragma mark Overridable Methods

- (nonnull IMCollectionView *)createCollectionViewWithSession:(IMImojiSession *)session {
    return [IMCollectionView imojiCollectionViewWithSession:session];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    }
}

#pragma mark Initializers

+ (instancetype)collectionViewControllerWithSession:(IMImojiSession *)session {
    return [[IMCollectionViewController alloc] initWithSession:session];
}

@end
