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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Shared styles for the Imoji Creation View
 */
@interface IMCreateImojiUITheme : NSObject

@property(nonatomic, strong, nonnull) UIColor *tagScreenNavigationToolbarBarTintColor;
@property(nonatomic, strong, nonnull) UIColor *tagScreenTintColor;
@property(nonatomic, strong, nonnull) UIColor *tagScreenRemoveButtonDividerColor;
@property(nonatomic, strong, nonnull) UIColor *tagScreenTagFontColor;
@property(nonatomic, strong, nonnull) UIColor *tagScreenPlaceHolderFontColor;
@property(nonatomic, strong, nonnull) UIColor *tagScreenRemoveButtonColor;
@property(nonatomic, strong, nonnull) UIColor *tagScreenTagItemBorderColor;
@property(nonatomic, strong, nonnull) UIColor *trimScreenTintColor;
@property(nonatomic, strong, nonnull) UIColor *createViewBackgroundColor;

@property(nonatomic, strong, nonnull) UIFont *tagScreenTagFont;
@property(nonatomic, strong, nonnull) UIFont *trimScreenNavigationBarFont;
@property(nonatomic, strong, nonnull) UIFont *tagScreenNavigationBarFont;

@property(nonatomic, strong, nonnull) UIImage *trimScreenUndoButtonImage;
@property(nonatomic, strong, nonnull) UIImage *trimScreenHelpButtonImage;
@property(nonatomic, strong, nonnull) UIImage *trimScreenCancelButtonImage;
@property(nonatomic, strong, nonnull) UIImage *tagScreenBackButtonImage;
@property(nonatomic, strong, nonnull) UIImage *trimScreenFinishTraceButtonImage;
@property(nonatomic, strong, nonnull) UIImage *tagScreenFinishButtonImage;
@property(nonatomic, strong, nonnull) UIImage *tagScreenRemoveTagIcon;
@property(nonatomic, strong, nonnull) UIImage *tagScreenHelpImageStep1;
@property(nonatomic, strong, nonnull) UIImage *tagScreenHelpImageStep2;
@property(nonatomic, strong, nonnull) UIImage *tagScreenHelpImageStep3;
@property(nonatomic, strong, nonnull) UIImage *tagScreenHelpNextButtonImage;
@property(nonatomic, strong, nonnull) UIImage *tagScreenHelpDoneButtonImage;

@property(nonatomic, strong, nonnull) NSDictionary *trimScreenTitleAttributes;
@property(nonatomic, strong, nonnull) NSDictionary *tagScreenTitleAttributes;

@property(nonatomic, nonnull) UIColor *tagScreenTagFieldBackgroundColor;
@property(nonatomic) CGFloat tagScreenTagFieldBorderWidth;
@property(nonatomic) CGFloat tagScreenTagFieldCornerRadius;
@property(nonatomic) UIEdgeInsets tagScreenTagItemInsets;
@property(nonatomic) CGFloat tagScreenTagItemInterspacingDistance;
@property(nonatomic) UIEdgeInsets tagScreenTagItemViewInsets;
@property(nonatomic) CGFloat tagScreenTagItemTextButtonSpacing;

+ (nonnull IMCreateImojiUITheme *)instance;

@end
