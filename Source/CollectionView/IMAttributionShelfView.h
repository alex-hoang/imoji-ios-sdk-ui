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

#import <UIKit/UIKit.h>
#import <ImojiSDK/IMCategoryAttribution.h>
#import <ImojiSDK/IMImojiSession.h>

typedef NS_ENUM(NSUInteger, IMAttributionShelfViewButtonType) {
    IMAttributionShelfViewButtonFavorite = 1,
    IMAttributionShelfViewButtonRelated,
    IMAttributionShelfViewButtonAttribution,
    IMAttributionShelfViewButtonCancel
};

extern const CGFloat IMAttributionShelfViewButtonTopOffset;
extern const CGFloat IMAttributionShelfViewButtonTextSize;
extern const CGFloat IMAttributionShelfViewButtonImageTextOffset;
extern const CGFloat IMAttributionShelfViewHeight;
extern const CGFloat IMAttributionShelfViewPreviewImojiImageViewWidthHeight;
extern const CGFloat IMAttributionShelfViewPreviewImojiImageViewTextOffset;

@protocol IMAttributionShelfViewDelegate;

@interface IMAttributionShelfView : UIView

/**
* @abstract The current attribution associated with the imoji
*/
@property(nonatomic, strong, nullable) IMCategoryAttribution *attribution;

/**
* @abstract The current imoji image on the attribution shelf view
*/
@property(nonatomic, strong, readonly, nullable) UIImageView *previewImojiImageView;

@property(nonatomic, weak, nullable) id<IMAttributionShelfViewDelegate> delegate;

/**
 * @abstract Creates a attribution shelf view with the specified Imoji object and Imoji session
 */
+ (nonnull instancetype)imojiAttributionShelfViewWithImoji:(nonnull IMImojiObject *)imoji imojiSession:(nonnull IMImojiSession *)session;

@end

@protocol IMAttributionShelfViewDelegate <NSObject>

@optional

/**
 * @abstract Triggered when the user taps a button on the attribution shelf
 * @param buttonType The corresponding button type of the attribution shelf button
 */
- (void)userDidTapAttributionShelfButtonWithType:(IMAttributionShelfViewButtonType)buttonType;

@end
