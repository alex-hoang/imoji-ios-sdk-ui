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

#import "IMHalfAndQuarterScreenView.h"
#import <ImojiSDK/IMImojiCategoryObject.h>
#import <Masonry/Masonry.h>

@interface IMHalfAndQuarterScreenView () <IMSearchViewDelegate, IMCollectionViewDelegate>
@end

@implementation IMHalfAndQuarterScreenView

- (void)setupStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    self.searchView = [IMSearchView imojiSearchView];
    self.searchView.createAndRecentsEnabled = YES;
    self.searchView.backButtonType = IMSearchViewBackButtonTypeDisabled;
    self.searchView.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchView.delegate = self;

    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:session];
    self.imojiSuggestionView.clipsToBounds = NO;
    self.imojiSuggestionView.collectionView.hidden = YES;
    self.imojiSuggestionView.collectionView.infiniteScroll = YES;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(74.f, 91.f);
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;

    UIView *suggestionTopBorder = [[UIView alloc] init];
    suggestionTopBorder.backgroundColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f];

    [self addSubview:self.imojiSuggestionView];
    [self addSubview:self.searchView];

    [self.imojiSuggestionView addSubview:suggestionTopBorder];

    [self.imojiSuggestionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.top.equalTo(self.searchView.mas_top).offset(-IMSuggestionViewBorderHeight);
    }];

    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self);
    }];

    [suggestionTopBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imojiSuggestionView).offset(-1);
        make.left.right.equalTo(self.imojiSuggestionView);
        make.height.equalTo(@1);
    }];
}

- (void)setupViewAsHalfScreen {
    self.imojiSuggestionView.collectionView.hidden = NO;

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
    }];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.searchView.mas_bottom);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight * 2.0f));
    }];
}

- (void)setupViewAsQuarterScreen {
    self.imojiSuggestionView.collectionView.hidden = NO;

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.bottom.equalTo(self.searchView.mas_top).offset(IMSuggestionViewBorderHeight);
    }];

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self);
    }];
}

- (void)resetView {
    self.imojiSuggestionView.collectionView.hidden = YES;

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.top.equalTo(self.searchView.mas_top).offset(-IMSuggestionViewBorderHeight);
    }];

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self);
    }];

    if (self.searchView.recentsButton.selected) {
        [self.searchView.searchViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchView).offset(10.0f);
        }];

        [self.searchView.recentsButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchView.searchViewContainer);
        }];
    }
}

#pragma mark IMSearchView Delegate

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidBeginSearchFromSearchView:)]) {
        [self.delegate userDidBeginSearchFromSearchView:searchView];
    }

    [searchView.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView.searchViewContainer);
        make.centerY.equalTo(searchView.searchViewContainer);
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];
}

- (void)userDidClearTextFieldFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidClearTextFieldFromSearchView:)]) {
        [self.delegate userDidClearTextFieldFromSearchView:searchView];
    }

    [searchView resetSearchView];

    if (searchView.backButtonType == IMSearchViewBackButtonTypeBack) {
        [searchView hideBackButton];
    }

    [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidEndSearchFromSearchView:)]) {
        [self.delegate userDidEndSearchFromSearchView:searchView];
    }

    if(searchView.backButtonType == IMSearchViewBackButtonTypeBack && !searchView.recentsButton.selected) {
        if (searchView.searchTextField.text.length > 0 || (searchView.searchTextField.text.length == 0 && searchView.previousSearchTerm.length > 0)) {
            [searchView showBackButton];
        }
    }
}

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidPressReturnKeyFromSearchView:)]) {
        [self.delegate userDidPressReturnKeyFromSearchView:searchView];
    }

    [searchView.searchTextField resignFirstResponder];
}

- (void)userDidTapBackButtonFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapBackButtonFromSearchView:)]) {
        [self.delegate userDidTapBackButtonFromSearchView:searchView];
    }

    [searchView resetSearchView];

    if(![searchView.searchTextField isFirstResponder]) {
        [searchView hideBackButton];
    }

    [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
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

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapRecentsButtonFromSearchView:)]) {
        [self.delegate userDidTapRecentsButtonFromSearchView:searchView];
    }

    searchView.backButton.hidden = NO;
    searchView.createButton.hidden = YES;
    searchView.searchTextField.rightView = searchView.searchIconImageView;

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

    [self.imojiSuggestionView.collectionView loadRecents];
}

#pragma mark IMCollectionView Delegate

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

    if (self.searchView.createAndRecentsEnabled && self.searchView.recentsButton.selected) {
        self.searchView.recentsButton.selected = NO;
        self.searchView.searchTextField.rightView = self.searchView.clearButton;

        if (![self.searchView.searchIconImageView isDescendantOfView:self.searchView.searchViewContainer]) {
            [self.searchView.searchViewContainer addSubview:self.searchView.searchIconImageView];

            [self.searchView.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.searchView.searchViewContainer);
                make.centerY.equalTo(self.searchView.searchViewContainer);
                make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
            }];
        }
    }

    [self.searchView showBackButton];

    [collectionView loadImojisFromCategory:category contributingImoji:imojiImage];
}

+ (instancetype)imojiStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    return [[IMHalfAndQuarterScreenView alloc] initWithSession:session];
}

@end
