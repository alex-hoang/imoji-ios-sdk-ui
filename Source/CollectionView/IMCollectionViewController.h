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

@class IMImojiSession, IMCollectionView;

/**
 * @abstract A simple view controller that displays a full screen collection view with Imoji content. A search field
 * is bundled in by default and positioned on the top of the page. To override the layout constraints, subclasses should
 * override updateViewConstraints to position the components how they like.
 */
@interface IMCollectionViewController : UIViewController

- (instancetype)initWithSession:(IMImojiSession *)session;

+ (instancetype)collectionViewControllerWithSession:(IMImojiSession *)session;

/**
 * @abstract Loads Imoji stickers into the collection view using getFeaturedImojisWithNumberOfResults from IMImojiSession
 */
@property(nonatomic, strong) IMImojiSession* session;

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

@property(nonatomic, strong, readonly) UITextField *searchField;
@property(nonatomic, strong, readonly) IMCollectionView* collectionView;

@end