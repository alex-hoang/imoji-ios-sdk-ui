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

#import "IMQuarterScreenView.h"
#import <ImojiSDK/IMImojiCategoryObject.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <Masonry/Masonry.h>

#if __has_include(<ImojiGraphics/ImojiGraphics.h>) && __has_include(<ImojiSDKUI/IMCreateImojiViewController.h>) && !defined(IMOJI_APP_EXTENSION)
#define IMOJI_EDITOR_ENABLED 1
#else
#define IMOJI_EDITOR_ENABLED 0
#endif

@interface IMQuarterScreenView () <IMSearchViewDelegate, IMCollectionViewDelegate>
@end

@implementation IMQuarterScreenView

- (void)setupStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    self.searchView = [IMSearchView imojiSearchView];
    self.searchView.createAndRecentsEnabled = YES;
    self.searchView.backButtonType = IMSearchViewBackButtonTypeDisabled;
    self.searchView.searchTextField.returnKeyType = UIReturnKeySend;
    self.searchView.delegate = self;

    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:session];
    self.imojiSuggestionView.clipsToBounds = NO;
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

#pragma mark IMSearchView Delegate

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidBeginSearchFromSearchView:)]) {
        [self.delegate userDidBeginSearchFromSearchView:searchView];
    }

    if (searchView.recentsButton.selected) {
        [searchView.recentsButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_recents.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                                  forState:UIControlStateSelected];

        [searchView.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(searchView.searchViewContainer);
            make.centerY.equalTo(searchView.searchViewContainer);
            make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
        }];

        [searchView.recentsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
#if IMOJI_EDITOR_ENABLED
            make.right.equalTo(searchView.createButton.mas_left).offset(-4.0f);
#else
            make.right.equalTo(searchView.searchViewContainer).offset(-1.0f);
#endif
            make.centerY.equalTo(searchView.searchViewContainer);
        }];
    }

    if(searchView.searchTextField.text.length == 0) {
        searchView.cancelButton.hidden = YES;
        searchView.recentsButton.hidden = NO;
        searchView.createButton.hidden = NO;
    }
}

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidChangeTextFieldFromSearchView:)]) {
        [self.delegate userDidChangeTextFieldFromSearchView:searchView];
    }

    BOOL hasText = searchView.searchTextField.text.length > 0;

    searchView.cancelButton.hidden = !hasText;
    searchView.createButton.hidden = hasText;
    searchView.recentsButton.hidden = hasText;

    if (!hasText) {
        [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
    } else {
        [self.imojiSuggestionView.collectionView loadImojisFromSentence:searchView.searchTextField.text];
    }
}

- (void)userDidClearTextFieldFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidClearTextFieldFromSearchView:)]) {
        [self.delegate userDidClearTextFieldFromSearchView:searchView];
    }

    [searchView.searchTextField sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidEndSearchFromSearchView:)]) {
        [self.delegate userDidEndSearchFromSearchView:searchView];
    }

    [searchView.recentsButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_recents_active.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                              forState:UIControlStateSelected];
}

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapRecentsButtonFromSearchView:)]) {
        [self.delegate userDidTapRecentsButtonFromSearchView:searchView];
    }

    searchView.createButton.hidden = NO;
    searchView.recentsButton.hidden = NO;
    searchView.searchTextField.rightView = searchView.searchIconImageView;

    [searchView.searchViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView).offset(10.0f);
    }];

    [searchView.recentsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
        make.left.and.centerY.equalTo(searchView.searchViewContainer);
    }];

    [searchView.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView.recentsButton.mas_right).offset(2.0f);
#if IMOJI_EDITOR_ENABLED
        make.right.equalTo(searchView.createButton.mas_left).offset(-9.0f);
#else
        make.right.equalTo(searchView.searchViewContainer).offset(-6.0f);
#endif
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.centerY.equalTo(searchView.searchViewContainer);
    }];

    [self.imojiSuggestionView.collectionView loadRecents];
}

#pragma mark IMCollectionView Delegate

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self userDidSelectCategory:category contributingImoji:nil fromCollectionView:collectionView];
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category contributingImoji:(IMImojiImageReference *)imojiImage fromCollectionView:(IMCollectionView *)collectionView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectCategory:contributingImoji:fromCollectionView:)]) {
        [self.delegate userDidSelectCategory:category contributingImoji:imojiImage fromCollectionView:collectionView];
    }

    self.searchView.searchTextField.text = category.title;
    self.searchView.searchTextField.rightView.hidden = NO;
    self.searchView.cancelButton.hidden = NO;
    self.searchView.createButton.hidden = YES;
    self.searchView.recentsButton.hidden = YES;
    [collectionView loadImojisFromCategory:category contributingImoji:imojiImage];
}

+ (instancetype)imojiStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    return [[IMQuarterScreenView alloc] initWithSession:session];
}

@end
