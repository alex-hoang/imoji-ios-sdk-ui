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

#import <UIKit/UIKit.h>
#import "IMCollectionView.h"

@class IMArtist;

@protocol IMCollectionReusableAttributionViewDelegate;
@class IMCategoryAttribution;

@interface IMCollectionReusableAttributionView : UICollectionReusableView

extern NSString *__nonnull const IMCollectionReusableAttributionViewReuseId;

extern CGFloat const IMCollectionReusableAttributionViewContainerOffset;
extern CGFloat const IMCollectionReusableAttributionViewSeparatorSize;
extern CGFloat const IMCollectionReusableAttributionViewArtistPictureWidthHeight;
extern CGFloat const IMCollectionReusableAttributionViewURLContainerHeight;
extern CGFloat const IMCollectionReusableAttributionViewDefaultFontSize;
extern CGFloat const IMCollectionReusableAttributionViewArtistNameFontSize;
extern CGFloat const IMCollectionReusableAttributionViewArtistSummaryFontSize;
extern CGFloat const IMCollectionReusableAttributionViewAttributionFontSize;
extern CGFloat const IMCollectionReusableAttributionViewAttributionButtonHeight;
extern CGFloat const IMCollectionReusableAttributionViewAttributionButtonWidth;
extern CGFloat const IMCollectionReusableAttributionViewAttributionCornerRadius;

@property(nonatomic, strong, readonly, nullable) UIView *footerView;
@property(nonatomic, strong, readonly, nullable) UIView *urlContainer;
@property(nonatomic, strong, readonly, nullable) UIView *artistContainer;

@property(nonatomic, strong, nullable) UIImageView *artistPicture;
@property(nonatomic, strong, nullable) UIImageView *attributionLinkImage;

@property(nonatomic, strong, nullable) UIButton *attributionButton;

@property(nonatomic, strong, nullable) UILabel *artistName;
@property(nonatomic, strong, nullable) UILabel *artistSummary;
@property(nonatomic, strong, nullable) UILabel *artistHeader;

@property(nonatomic, strong, nonnull) NSBundle *imageBundle;

@property(nonatomic, weak, nullable) id <IMCollectionReusableAttributionViewDelegate> attributionViewDelegate;

- (void)setupWithAttribution:(nonnull IMCategoryAttribution *)attribution;

- (nonnull UIView *)footerView;

- (nonnull UIView *)urlContainer;

- (nonnull UIView *)artistContainer;

@end

@protocol IMCollectionReusableAttributionViewDelegate <NSObject>

@optional

- (void)userDidSelectAttributionLink:(nonnull NSURL *)attributionLink fromCollectionReusableView:(nonnull IMCollectionReusableAttributionView *)footerView;

@end
