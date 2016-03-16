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
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IMToolbarButtonType) {
    IMToolbarButtonSearch = 1,
    IMToolbarButtonRecents,
    IMToolbarButtonReactions,
    IMToolbarButtonTrending,
    IMToolbarButtonArtist,
    IMToolbarButtonCollection,
    IMToolbarButtonBack,

    // keyboard specific button types
    IMToolbarButtonKeyboardNextKeyboard,
    IMToolbarButtonKeyboardDelete
};

extern NSUInteger const IMToolbarDefaultButtonItemWidthAndHeight;

@protocol IMToolbarDelegate <UIToolbarDelegate>

@optional

/**
 * @abstract Triggered when the user taps a toolbar item
 * @param buttonType The corresponding button type of the toolbar item
 */
- (void)userDidSelectToolbarButton:(IMToolbarButtonType)buttonType;

@end

@interface IMToolbar : UIToolbar

/**
 * @abstract The image bundle to use for loading the toolbar images. Defaults to [IMResourceBundleUtil assetsBundle]
 */
@property(nonatomic, strong, nonnull) NSBundle * imageBundle;

/**
 * @abstract Optional Imoji Toolbar Delegate
 */
@property(nonatomic, weak, nullable) id<IMToolbarDelegate> delegate;

/**
 * @abstract Adds an Imoji toolbar item to IMToolbar.items. If there are existing toolbar items already added, a flexible
 * space will be added automatically. Will attempt to load a default image from the ImojiUIAssets resource bundle for
 * the toolbar item.
 */
- (nonnull UIBarButtonItem *)addToolbarButtonWithType:(IMToolbarButtonType)buttonType;

/**
 * @abstract Adds an Imoji toolbar item to IMToolbar.items. If there are existing toolbar items already added, a flexible
 * space will be added automatically. Sets the default width of the toolbar item
 * to IMToolbarDefaultButtonItemWidthAndHeight
 * @param buttonType The imoji button type
 * @param image The toolbar item image
 * @param activeImage An optional image to display the selected state
 */
- (nonnull UIBarButtonItem *)addToolbarButtonWithType:(IMToolbarButtonType)buttonType
                                                image:(nonnull UIImage *)image
                                          activeImage:(nullable UIImage *)activeImage;

/**
 * @abstract Adds an Imoji toolbar item to IMToolbar.items. If there are existing toolbar items already added, a flexible
 * space will be added automatically.
 * @param buttonType The imoji button type
 * @param image The toolbar item image
 * @param activeImage An optional image to display the selected state
 * @param width The width of the toolbar item
 */
- (nonnull UIBarButtonItem *)addToolbarButtonWithType:(IMToolbarButtonType)buttonType
                                                image:(nonnull UIImage *)image
                                          activeImage:(nullable UIImage *)activeImage
                                                width:(CGFloat)width;

- (nonnull UIBarButtonItem *)addSearchBarItem;

/**
 * @abstract Adds a simple UIBarButtonItem of type UIBarButtonSystemItemFlexibleSpace
 */
- (nonnull UIBarButtonItem *)addFlexibleSpace;

/**
 * @abstract Convenience method for adding a UIBarButtonItem to the toolbar
 */
- (void)addBarButton:(nonnull UIBarButtonItem *)barButtonItem;

/**
 * @abstract Triggers the selection of a specified toolbar item. The delegate method userDidSelectToolbarButton: will
 * subsequently be triggered.
 */
- (void)selectButtonOfType:(IMToolbarButtonType)buttonType;

/**
 * @abstract Creates a new Imoji toolbar
 */
+ (nonnull instancetype)imojiToolbar;

@end
