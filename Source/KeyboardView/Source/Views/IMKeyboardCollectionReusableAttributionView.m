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

#import "IMKeyboardCollectionReusableAttributionView.h"
#import "IMAttributeStringUtil.h"
#import "View+MASAdditions.h"
#import "IMResourceBundleUtil.h"
#import "IMCategoryAttribution.h"
#import "IMArtist.h"

CGFloat const IMKeyboardCollectionReusableAttributionViewOffsetFromHeader = 10.0f;
CGFloat const IMKeyboardCollectionReusableAttributionViewLandscapeRatio = 0.8f;
CGFloat const IMKeyboardCollectionReusableAttributionViewArtistSummaryHeight = 29.0f;

@implementation IMKeyboardCollectionReusableAttributionView

- (void)setupWithAttribution:(IMCategoryAttribution *)attribution {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    if(!self.footerView) {
        [super setupWithAttribution:attribution];
    }

    if(self.footerView.frame.size.height != self.frame.size.height) {
        [self.footerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(self);
        }];

        [self.artistContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self);
            make.left.equalTo(self).offset(IMCollectionReusableAttributionViewContainerOffset);
            make.right.equalTo(self).offset(-IMCollectionReusableAttributionViewContainerOffset);
        }];

        [self.urlContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistSummary.mas_bottom).offset(11.0f * (isLandscape ? IMKeyboardCollectionReusableAttributionViewLandscapeRatio : 1.0f));
            make.left.equalTo(self).offset(IMCollectionReusableAttributionViewContainerOffset);
            make.right.equalTo(self).offset(-IMCollectionReusableAttributionViewContainerOffset);
        }];

        [self.artistPicture mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(IMKeyboardCollectionReusableAttributionViewOffsetFromHeader + (isLandscape ? 0 : 14.0f));
            make.width.and.height.equalTo(@(IMCollectionReusableAttributionViewArtistPictureWidthHeight * (isLandscape ? IMKeyboardCollectionReusableAttributionViewLandscapeRatio : 1.0f)));
        }];

        [self.artistHeader mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(IMKeyboardCollectionReusableAttributionViewOffsetFromHeader + (isLandscape ? 9.0f / 1.2f : 23.0f));
        }];

        [self.artistSummary mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistPicture.mas_bottom).offset(12.0f * (isLandscape ? IMKeyboardCollectionReusableAttributionViewLandscapeRatio : 1.0f));
            make.left.and.right.equalTo(self.artistContainer);
            make.height.equalTo(@(IMKeyboardCollectionReusableAttributionViewArtistSummaryHeight));
        }];

        [self.attributionLinkImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(self.urlContainer);
        }];

        [self.attributionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.attributionLinkImage.mas_right).offset(9.0f);
            make.centerY.equalTo(self.attributionLinkImage);
        }];

        self.artistHeader.attributedText = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionReusableAttributionViewAbout"]
                                                                          withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:IMCollectionReusableAttributionViewDefaultFontSize * (isLandscape ? IMKeyboardCollectionReusableAttributionViewLandscapeRatio : 1.0f)]
                                                                             color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.6f]
                                                                      andAlignment:NSTextAlignmentLeft];

        self.artistName.attributedText = [IMAttributeStringUtil attributedString:[attribution.artist.name uppercaseString]
                                                                        withFont:[IMAttributeStringUtil sfUITextBoldFontWithSize:IMCollectionReusableAttributionViewArtistNameFontSize * (isLandscape ? IMKeyboardCollectionReusableAttributionViewLandscapeRatio : 1.0f)]
                                                                           color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.8f]
                                                                    andAlignment:NSTextAlignmentLeft];
    }
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:0.08f].CGColor);
    CGContextFillRect(context, CGRectMake(
            0,
            IMKeyboardCollectionReusableAttributionViewOffsetFromHeader,
            IMCollectionReusableAttributionViewSeparatorSize,
            self.frame.size.height - IMKeyboardCollectionReusableAttributionViewOffsetFromHeader)
    );

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(
            self.frame.size.width - IMCollectionReusableAttributionViewSeparatorSize,
            IMKeyboardCollectionReusableAttributionViewOffsetFromHeader,
            IMCollectionReusableAttributionViewSeparatorSize,
            self.frame.size.height - IMKeyboardCollectionReusableAttributionViewOffsetFromHeader)
    );
}

@end