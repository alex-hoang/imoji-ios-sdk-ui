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
#import "IMToolbar.h"
#import "IMCollectionView.h"
#import <ImojiSDKUI/IMSearchView.h>

@class IMImojiSession;

@protocol IMCollectionViewControllerDelegate <IMToolbarDelegate, IMCollectionViewDelegate, IMSearchViewDelegate>

@optional

/**
 * @abstract Allows the implementor to specify the background color of the view prior to presenting. Implement this
 * if you wish to have the status bar section have a different color than the toolbars.
 */
- (nullable UIColor *)backgroundColorForCollectionViewController:(nonnull UIViewController *)collectionViewController;

@end


/**
 * @abstract A simple view controller that displays a full screen collection view with Imoji content. A search field
 * is bundled in by default and positioned on the top of the page. To override the layout constraints, subclasses should
 * override updateViewConstraints to position the components how they like.
 */
@interface IMCollectionViewController : UIViewController

/**
 * @abstract Creates a new collection view controller with a specified Imoji Session object
 */
- (nonnull instancetype)initWithSession:(IMImojiSession *__nonnull)session;

/**
 * @abstract Creates a new collection view controller with a specified Imoji Session object
 */
+ (nonnull instancetype)collectionViewControllerWithSession:(IMImojiSession *__nonnull)session;

/**
 * @abstract Loads Imoji stickers into the collection view using getFeaturedImojisWithNumberOfResults from IMImojiSession
 */
@property(nonatomic, strong, nonnull) IMImojiSession *session;

/**
 * @abstract If YES, calls IMImojiSession searchImojisWithSentence: to parse Imoji content from a sentence. Otherwise,
 * a standard query search is performed.
 */
@property(nonatomic) BOOL sentenceParseEnabled;

/**
 * @abstract If YES, performs a search for every change to the text field entered by the user. If NO, the user must
 * hit return to search
 */
@property(nonatomic) BOOL searchOnTextChanges;

/**
 * @abstract Configures the delay in milliseconds for performing subsequent searches when searchOnTextChanges is enabled.
 */
@property(nonatomic) NSUInteger autoSearchDelayTimeInMillis;

/**
 * @abstract The search field component for the collection view. If you hiding this field, make sure to call
 * updateViewConstraints if the view controller has been presented. To change the dimensions of this field, override
 * updateViewConstraints in your own representation.
 * DEPRECATED: Use searchView instead.
 */
@property(nonatomic, strong, readonly, nonnull) UISearchBar *searchField DEPRECATED_ATTRIBUTE;

@property(nonatomic, strong, readonly, nonnull) IMSearchView *searchView;

/**
 * @abstract The collection view associated to the view controller. To change the dimensions of this field, override
 * updateViewConstraints in your own representation.
 */
@property(nonatomic, strong, readonly, nonnull) IMCollectionView *collectionView;

/**
 * @abstract A standard toolbar that will appear below the collection view component. If no items are added to the
 * toolbar, it will not be displayed
 */
@property(nonatomic, strong, readonly, nonnull) IMToolbar *bottomToolbar;

/**
 * @abstract A standard toolbar that will appear above the collection view component. By default, the searchField
 * component is added and always displayed.
 */
@property(nonatomic, strong, readonly, nonnull) IMToolbar *topToolbar;

/**
 * @abstract Back button displayed in topToolbar. This view is hidden by default.
 */
@property(nonatomic, strong, readonly, nonnull) UIButton *backButton;

/**
 * @abstract An optional delegate that will receive events from the toolbars as well as the collection view itself
 */
@property(nonatomic, weak, nullable) id <IMCollectionViewControllerDelegate> collectionViewControllerDelegate;

@end

@interface IMCollectionViewController(Override)

- (nonnull IMCollectionView *)createCollectionViewWithSession:(nonnull IMImojiSession *)session;

@end
