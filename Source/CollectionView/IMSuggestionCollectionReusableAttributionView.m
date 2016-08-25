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

#import <ImojiSDK/IMArtist.h>
#import <ImojiSDK/IMCategoryAttribution.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMSuggestionCollectionReusableAttributionView.h>
#import <Masonry/Masonry.h>

CGFloat const IMSuggestionCollectionReusableAttributionViewOffsetFromHeader = 10.0f;
CGFloat const IMSuggestionCollectionReusableAttributionViewLandscapeRatio = 0.875f;
CGFloat const IMSuggestionCollectionReusableAttributionViewArtistSummaryHeight = 29.0f;

@implementation IMSuggestionCollectionReusableAttributionView

- (void)setupWithAttribution:(IMCategoryAttribution *)attribution {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    [super setupWithAttribution:attribution];

    if(self.footerView.frame.size.height != self.frame.size.height) {
        self.artistHeader.attributedText = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionReusableAttributionViewAbout"]
                                                                          withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:IMCollectionReusableAttributionViewDefaultFontSize * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)]
                                                                             color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.6f]
                                                                      andAlignment:NSTextAlignmentLeft];

        self.artistName.attributedText = [IMAttributeStringUtil attributedString:[attribution.artist.name uppercaseString]
                                                                        withFont:[IMAttributeStringUtil sfUITextBoldFontWithSize:IMCollectionReusableAttributionViewArtistNameFontSize * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)]
                                                                           color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.8f]
                                                                    andAlignment:NSTextAlignmentLeft];

        self.attributionButton.layer.cornerRadius = IMCollectionReusableAttributionViewAttributionCornerRadius * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f);
        [self.attributionButton setAttributedTitle:[IMAttributeStringUtil attributedString:[[IMResourceBundleUtil localizedStringForKey:@"collectionReusableAttributionViewAttributionButton"] uppercaseString]
                                                                                  withFont:[IMAttributeStringUtil sfUITextMediumFontWithSize:IMCollectionReusableAttributionViewAttributionFontSize * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)]
                                                                                     color:[UIColor colorWithRed:10.0f / 255.0f green:149.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                              andAlignment:NSTextAlignmentCenter]
                                          forState:UIControlStateNormal];

        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    [self.artistContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.footerView);
        make.left.equalTo(self.footerView).offset(IMCollectionReusableAttributionViewContainerOffset);
        make.right.equalTo(self.footerView).offset(-IMCollectionReusableAttributionViewContainerOffset);
    }];

    [self.urlContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.artistSummary.mas_bottom).offset(11.0f * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f));
        make.left.equalTo(self.footerView).offset(IMCollectionReusableAttributionViewContainerOffset);
        make.right.equalTo(self.footerView).offset(-IMCollectionReusableAttributionViewContainerOffset);
        make.height.equalTo(@(IMCollectionReusableAttributionViewAttributionButtonHeight));
    }];

    [self.artistPicture mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.artistContainer).offset(IMSuggestionCollectionReusableAttributionViewOffsetFromHeader + (isLandscape ? 0 : 14.0f));
        make.width.and.height.equalTo(@(IMCollectionReusableAttributionViewArtistPictureWidthHeight * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)));
    }];

    [self.artistHeader mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.artistContainer).offset(IMSuggestionCollectionReusableAttributionViewOffsetFromHeader + (isLandscape ? 9.0f / 1.2f : 23.0f));
    }];

    [self.artistSummary mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.artistPicture.mas_bottom).offset(12.0f * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f));
        make.left.and.right.equalTo(self.artistContainer);
        make.height.equalTo(@(IMSuggestionCollectionReusableAttributionViewArtistSummaryHeight));
    }];

    [self.attributionLinkImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self.urlContainer);
        make.width.equalTo(@(self.attributionLinkImage.image.size.width * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)));
        make.height.equalTo(@(self.attributionLinkImage.image.size.height * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)));
    }];

    [self.attributionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.urlContainer);
        make.centerY.equalTo(self.attributionLinkImage);
        make.width.equalTo(@(IMCollectionReusableAttributionViewAttributionButtonWidth * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)));
        make.height.equalTo(@(IMCollectionReusableAttributionViewAttributionButtonHeight * (isLandscape ? IMSuggestionCollectionReusableAttributionViewLandscapeRatio : 1.0f)));
    }];

    [super updateConstraints];
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
            IMSuggestionCollectionReusableAttributionViewOffsetFromHeader,
            IMCollectionReusableAttributionViewSeparatorSize,
            self.frame.size.height - IMSuggestionCollectionReusableAttributionViewOffsetFromHeader * 2.0f)
    );

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.18f].CGColor);
    CGContextFillRect(context, CGRectMake(
            self.frame.size.width - IMCollectionReusableAttributionViewSeparatorSize,
            IMSuggestionCollectionReusableAttributionViewOffsetFromHeader,
            IMCollectionReusableAttributionViewSeparatorSize,
            self.frame.size.height - IMSuggestionCollectionReusableAttributionViewOffsetFromHeader * 2.0f)
    );
}

@end
