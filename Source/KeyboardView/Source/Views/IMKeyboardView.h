//
//  ImojiSDKUI
//
//  Created by Alex Hoang
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

#import <Foundation/Foundation.h>
#import <ImojiSDK/IMImojiSession.h>

#define IMKeyboardViewPortraitHeight 258.0f
#define IMKeyboardViewLandscapeHeight 205.0f

@class IMImojiSession;
@class IMKeyboardCollectionView;
@class IMToolbar;
@class IMKeyboardSearchTextField;
@class IMImojiCategoryObject;

@protocol IMKeyboardViewDelegate;

@interface IMKeyboardView : UIView

// Views
@property(nonatomic, strong, readonly) IMKeyboardCollectionView *collectionView;
@property(nonatomic, strong, readonly) IMToolbar *keyboardToolbar;
@property(nonatomic, strong, readonly) UIView *searchView;
@property(nonatomic, strong, readonly) IMKeyboardSearchTextField *searchField;

// Components
@property(nonatomic, strong) NSBundle *imageBundle;
@property(nonatomic, strong) NSString *fontFamily;

// search
@property(nonatomic) IMImojiSessionCategoryClassification currentCategoryClassification;

// delegate
@property(nonatomic, weak) id<IMKeyboardViewDelegate> delegate;

// Methods
- (void)updateTitleWithText:(NSString *)text hideCloseButton:(BOOL)isHidden;

- (void)updateProgressBarWithValue:(CGFloat)progress;

- (void)showDownloadingImojiIndicator;

- (void)showFinishedDownloadedWithMessage:(NSString *)message;

- (void)showAddedToCollectionIndicator;

- (void)setCurrentCategoryClassification:(IMImojiSessionCategoryClassification)currentCategoryClassification;

+ (instancetype)imojiKeyboardViewWithSession:(IMImojiSession *)session;

@end

@protocol IMKeyboardViewDelegate <NSObject>

@optional

- (void)userDidCloseCategoryFromView:(IMKeyboardView *)view;

@end
