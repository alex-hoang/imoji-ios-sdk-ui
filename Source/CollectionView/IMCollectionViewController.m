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
#import "IMCollectionViewController.h"
#import "IMCollectionView.h"
#import "IMAttributeStringUtil.h"
#import "IMResourceBundleUtil.h"
#import "IMToolbar.h"

CGFloat const IMCollectionViewControllerBottomBarDefaultHeight = 60.0f;
UIEdgeInsets const IMCollectionViewControllerSearchFieldInsets = {0, 5, 0, 10};

@interface IMCollectionViewController () <UISearchBarDelegate>

@property(nonatomic, strong) UIBarButtonItem *backButton;
@property(nonatomic) UIEdgeInsets preKeyboardDisplayedCollectionViewInsets;
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
    self.session = [IMImojiSession imojiSession];

    _bottomToolbar = [IMToolbar new];
    _topToolbar = [IMToolbar new];
    _collectionView = [IMCollectionView imojiCollectionViewWithSession:self.session];
    _searchOnTextChanges = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDisplayedForSearchField:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHiddenForSearchField:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    _backButton = [self.topToolbar addToolbarButtonWithType:IMToolbarButtonBack];
    UIBarButtonItem *barButtonItem = [self.topToolbar addSearchBarItem];
    _searchField = (UISearchBar *) barButtonItem.customView;
    _searchField.delegate = self;
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
    self.view.backgroundColor = [UIColor colorWithWhite:105 / 255.0f alpha:1.0f];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:248 / 255.0f alpha:1.0f];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;

    self.searchField.returnKeyType = self.searchOnTextChanges ? UIReturnKeyDone : UIReturnKeySearch;
    self.searchField.placeholder = [IMResourceBundleUtil localizedStringForKey:@"collectionViewControllerSearchStickers"];
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
        make.height.equalTo(@(IMCollectionViewControllerBottomBarDefaultHeight));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];

    [self.bottomToolbar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(IMCollectionViewControllerBottomBarDefaultHeight));
        make.left.right.and.bottom.equalTo(self.view);
    }];

    [self.searchField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.and.top.equalTo(self.backButton.customView);
        make.right.equalTo(self.view).offset(-IMCollectionViewControllerSearchFieldInsets.right);
        make.left.equalTo(self.backButton.customView.mas_right).offset(IMCollectionViewControllerSearchFieldInsets.left);
    }];

    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset = UIEdgeInsetsMake(
            (!self.topToolbar.hidden ? IMCollectionViewControllerBottomBarDefaultHeight : 0),
            0,
            (!self.bottomToolbar.hidden ? IMCollectionViewControllerBottomBarDefaultHeight : 0),
            0
    );
}

#pragma mark Notifications

- (void)deviceOrientationDidChange {
    [self updateViewConstraints];
}

- (void)keyboardDisplayedForSearchField:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect startRect = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat occupiedHeight = startRect.origin.y - endRect.origin.y;

    // adjust the content size for the keyboard using the displaced height
    if (occupiedHeight != 0) {
        self.preKeyboardDisplayedCollectionViewInsets = self.collectionView.contentInset;
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset = UIEdgeInsetsMake(
                self.collectionView.contentInset.top,
                self.collectionView.contentInset.left,
                occupiedHeight,
                self.collectionView.contentInset.right
        );
    }
}

- (void)keyboardHiddenForSearchField:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect startRect = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat occupiedHeight = endRect.origin.y - startRect.origin.y;

    // restore the content size of the collection view
    if (occupiedHeight != 0) {
        self.collectionView.scrollIndicatorInsets = self.preKeyboardDisplayedCollectionViewInsets;
    }
}

#pragma mark Overrides

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setSearchOnTextChanges:(BOOL)searchOnTextChanges {
    _searchOnTextChanges = searchOnTextChanges;
    self.searchField.returnKeyType = searchOnTextChanges ? UIReturnKeyDone : UIReturnKeySearch;
}

#pragma mark Search field delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.searchOnTextChanges) {
        [self performSearch];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!self.searchOnTextChanges) {
        [self performSearch];
    }

    [self.searchField resignFirstResponder];
}

- (void)performSearch {
    if (self.searchField.text.length > 0) {
        if (self.sentenceParseEnabled) {
            [self.collectionView loadImojisFromSentence:self.searchField.text];
        } else {
            [self.collectionView loadImojisFromSearch:self.searchField.text];
        }
    } else {
        [self.collectionView loadFeaturedImojis];
    }
}

#pragma mark Initializers

+ (instancetype)collectionViewControllerWithSession:(IMImojiSession *)session {
    IMCollectionViewController *controller = [[IMCollectionViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = session;
    return controller;
}

@end
