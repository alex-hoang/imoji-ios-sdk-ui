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

#import "IMStickerSearchContainerView.h"
#import <ImojiSDK/IMImojiCategoryObject.h>
#import <ImojiSDK/IMImojiObject.h>
#import <Masonry/Masonry.h>

#if __has_include(<ImojiGraphics/ImojiGraphics.h>) && __has_include(<ImojiSDKUI/IMCreateImojiViewController.h>) && !defined(IMOJI_APP_EXTENSION)
#define IMOJI_EDITOR_ENABLED 1
#import <ImojiSDKUI/IMCreateImojiViewController.h>
#import <ImojiSDKUI/IMCameraViewController.h>

@interface IMStickerSearchContainerView () <IMSearchViewDelegate, IMCollectionViewDelegate, IMCreateImojiViewControllerDelegate,
        UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

#else
#define IMOJI_EDITOR_ENABLED 0

@interface IMStickerSearchContainerView () <IMSearchViewDelegate, IMCollectionViewDelegate>

#endif

@end

@implementation IMStickerSearchContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.session = [IMImojiSession imojiSession];
        [self setupStickerSearchContainerViewWithSession:self.session];
    }

    return self;
}


- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.session = session;
        [self setupStickerSearchContainerViewWithSession:session];
    }

    return self;
}

- (void)setupStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    self.searchView = [IMSearchView imojiSearchView];
    self.searchView.createAndRecentsEnabled = YES;
    self.searchView.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchView.delegate = self;

    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:session];
    self.imojiSuggestionView.backgroundColor = [UIColor whiteColor];
    self.imojiSuggestionView.clipsToBounds = NO;
    self.imojiSuggestionView.collectionView.backgroundColor = [UIColor clearColor];
    self.imojiSuggestionView.collectionView.infiniteScroll = YES;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(74.f, 91.f);
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;

    [self addSubview:self.searchView];
    [self addSubview:self.imojiSuggestionView];
}

#pragma mark IMSearchView Delegate

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidBeginSearchFromSearchView:)]) {
        [self.delegate userDidBeginSearchFromSearchView:searchView];
    }
}

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidChangeTextFieldFromSearchView:)]) {
        [self.delegate userDidChangeTextFieldFromSearchView:searchView];
    }

    BOOL hasText = self.searchView.searchTextField.text.length > 0;
    if (!hasText) {
        [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
    } else {
        [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.searchView.searchTextField.text];
    }
}


- (void)userDidClearTextFieldFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidClearTextFieldFromSearchView:)]) {
        [self.delegate userDidClearTextFieldFromSearchView:searchView];
    }

    [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidEndSearchFromSearchView:)]) {
        [self.delegate userDidEndSearchFromSearchView:searchView];
    }
}

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidPressReturnKeyFromSearchView:)]) {
        [self.delegate userDidPressReturnKeyFromSearchView:searchView];
    }
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapCancelButtonFromSearchView:)]) {
        [self.delegate userDidTapCancelButtonFromSearchView:searchView];
    }

    if (searchView.recentsButton.selected) {
        [self.imojiSuggestionView.collectionView loadRecents];
    } else if (![searchView.previousSearchTerm isEqualToString:searchView.searchTextField.text]) {
        if([searchView.previousSearchTerm isEqualToString:@""]) {
            [self userDidClearTextFieldFromSearchView:searchView];
        } else {
            [self.imojiSuggestionView.collectionView loadImojisFromSentence:searchView.previousSearchTerm];
        }
    }
}

- (void)userDidTapCreateButtonFromSearchView:(IMSearchView *)searchView {
#if IMOJI_EDITOR_ENABLED
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            IMCameraViewController *cameraViewController = [IMCameraViewController imojiCameraViewControllerWithSession:self.session];
            cameraViewController.delegate = self;
            cameraViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            if([rootViewController isKindOfClass:[UINavigationController class]]) {
                rootViewController = ((UINavigationController *) rootViewController).visibleViewController;
            } else if(rootViewController.presentedViewController) {
                rootViewController = rootViewController.presentedViewController;
            }
            [rootViewController presentViewController:cameraViewController animated:YES completion:nil];
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;

//                [self presentViewController:imagePicker animated:YES completion:nil];
                UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
                if([rootViewController isKindOfClass:[UINavigationController class]]) {
                    rootViewController = ((UINavigationController *) rootViewController).visibleViewController;
                } else if(rootViewController.presentedViewController) {
                    rootViewController = rootViewController.presentedViewController;
                }
                [rootViewController presentViewController:imagePicker animated:YES completion:nil];
            }
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

//        [self presentViewController:alertController animated:YES completion:nil];
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if([rootViewController isKindOfClass:[UINavigationController class]])
        {
            rootViewController = ((UINavigationController *) rootViewController).visibleViewController;
        } else if(rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }

        [rootViewController presentViewController:alertController animated:YES completion:nil];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Photo Library", @"Take Photo", nil];

        [actionSheet showInView:self];
    }
#endif
}


- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapRecentsButtonFromSearchView:)]) {
        [self.delegate userDidTapRecentsButtonFromSearchView:searchView];
    }

    [self.imojiSuggestionView.collectionView loadRecents];
}

- (void)userShouldBeginSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userShouldBeginSearchFromSearchView:)]) {
        [self.delegate userShouldBeginSearchFromSearchView:searchView];
    }
}

#pragma mark IMCollectionView Delegate

- (void)userDidSelectImoji:(IMImojiObject *)imoji fromCollectionView:(IMCollectionView *)collectionView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectImoji:fromCollectionView:)]) {
        [self.delegate userDidSelectImoji:imoji fromCollectionView:collectionView];
    }
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView {
    [self userDidSelectCategory:category contributingImoji:nil fromCollectionView:collectionView];
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category contributingImoji:(IMImojiImageReference *)imojiImage fromCollectionView:(IMCollectionView *)collectionView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectCategory:contributingImoji:fromCollectionView:)]) {
        [self.delegate userDidSelectCategory:category contributingImoji:imojiImage fromCollectionView:collectionView];
    }

    self.searchView.searchTextField.text = category.title;
    self.searchView.searchTextField.rightView.hidden = NO;
    self.searchView.createButton.hidden = YES;
    self.searchView.recentsButton.hidden = YES;
    self.searchView.recentsButton.selected = NO;
    [self.searchView showBackButton];

    [collectionView loadImojisFromCategory:category contributingImoji:imojiImage];
}

- (void)userDidSelectSplash:(IMCollectionViewSplashCellType)splashType fromCollectionView:(IMCollectionView *)collectionView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectSplash:fromCollectionView:)]) {
        [self.delegate userDidSelectSplash:splashType fromCollectionView:collectionView];
    }

    [self.searchView.searchTextField becomeFirstResponder];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    IMCreateImojiViewController *createImojiViewController = [[IMCreateImojiViewController alloc] initWithSourceImage:image session:self.session];
    createImojiViewController.createDelegate = self;
    createImojiViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    createImojiViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [picker presentViewController:createImojiViewController animated:YES completion:nil];
}

#pragma mark IMCreateImojiViewControllerDelegate

- (void)imojiUploadDidBegin:(IMImojiObject *)localImoji fromViewController:(IMCreateImojiViewController *)viewController {
    [self.session markImojiUsageWithIdentifier:localImoji.identifier originIdentifier:@"imoji created"];
}

- (void)imojiUploadDidComplete:(IMImojiObject *)localImoji
               persistentImoji:(IMImojiObject *)persistentImoji
                     withError:(NSError *)error
            fromViewController:(IMCreateImojiViewController *)viewController {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [viewController dismissViewControllerAnimated:YES completion:^{
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if([rootViewController isKindOfClass:[UINavigationController class]])
        {
            rootViewController = ((UINavigationController *) rootViewController).visibleViewController;
        } else if(rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }
        
        [rootViewController dismissViewControllerAnimated:YES completion:nil];
    }];


    [self.searchView.recentsButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)userDidCancelImageEdit:(IMCreateImojiViewController *)viewController {
    [viewController dismissViewControllerAnimated:NO completion:nil];
}

#endif

+ (instancetype)imojiStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    return [[IMStickerSearchContainerView alloc] initWithSession:session];
}

@end
