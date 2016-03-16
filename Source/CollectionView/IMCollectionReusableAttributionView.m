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

#import "IMCollectionReusableAttributionView.h"
#import "IMResourceBundleUtil.h"
#import "IMAttributeStringUtil.h"
#import <Masonry/View+MASAdditions.h>
#import <ImojiSDK/IMArtist.h>
#import <ImojiSDK/IMCategoryAttribution.h>

NSString *const IMCollectionReusableAttributionViewReuseId = @"IMCollectionReusableAttributionViewReuseId";
CGFloat const IMCollectionReusableAttributionViewContainerOffset = 30.0f;
CGFloat const IMCollectionReusableAttributionViewSeparatorSize = 2.0f;
CGFloat const IMCollectionReusableAttributionViewArtistPictureWidthHeight = 60.0f;
CGFloat const IMCollectionReusableAttributionViewURLContainerHeight = 55.0f;
CGFloat const IMCollectionReusableAttributionViewDefaultFontSize = 14.0f;
CGFloat const IMCollectionReusableAttributionViewArtistNameFontSize = 19.0f;
CGFloat const IMCollectionReusableAttributionViewArtistSummaryFontSize = 12.0f;
CGFloat const IMCollectionReusableAttributionViewAttributionFontSize = 11.0f;
CGFloat const IMCollectionReusableAttributionViewAttributionButtonHeight = 28.0f;
CGFloat const IMCollectionReusableAttributionViewAttributionButtonWidth = 107.0f;
CGFloat const IMCollectionReusableAttributionViewAttributionCornerRadius = 13.5f;

@interface IMCollectionReusableAttributionView ()

@property(nonatomic, strong) NSURL *attributionLink;

@end

@implementation IMCollectionReusableAttributionView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];

    if (self) {
        self.opaque = NO;
        self.imageBundle = [IMResourceBundleUtil assetsBundle];
        _footerView = self.subviews.firstObject;
    }

    return self;
}

- (void)setupWithAttribution:(IMCategoryAttribution *)attribution {
    if(!self.footerView) {
        // Setup views
        _footerView = [[UIView alloc] init];

        _urlContainer = [[UIView alloc] init];
        self.urlContainer.backgroundColor = [UIColor clearColor];
        [self.urlContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(urlContainerTapped)]];

        _artistContainer = [[UIView alloc] init];

        // URL Container view
        self.attributionLabel = [[UILabel alloc] init];
        self.attributionLabel.attributedText = [IMAttributeStringUtil attributedString:[[IMResourceBundleUtil localizedStringForKey:@"collectionReusableAttributionViewAttributionLink"] uppercaseString]
                                                                              withFont:[IMAttributeStringUtil sfUITextMediumFontWithSize:IMCollectionReusableAttributionViewAttributionFontSize]
                                                                                 color:[UIColor colorWithRed:10.0f / 255.0f green:149.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                          andAlignment:NSTextAlignmentLeft];

        self.attributionLinkImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/attribution_link_website.png", self.imageBundle.bundlePath]]];

        self.attributionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.attributionButton.backgroundColor = [UIColor clearColor];
        self.attributionButton.layer.borderWidth = 1.0f;
        self.attributionButton.layer.cornerRadius = IMCollectionReusableAttributionViewAttributionCornerRadius;
        self.attributionButton.layer.borderColor = [UIColor colorWithRed:10.0f / 255.0f green:149.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f].CGColor;

        [self.attributionButton setAttributedTitle:[IMAttributeStringUtil attributedString:[[IMResourceBundleUtil localizedStringForKey:@"collectionReusableAttributionViewAttributionButton"] uppercaseString]
                                                                                  withFont:[IMAttributeStringUtil sfUITextMediumFontWithSize:IMCollectionReusableAttributionViewAttributionFontSize]
                                                                                     color:[UIColor colorWithRed:10.0f / 255.0f green:149.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                              andAlignment:NSTextAlignmentCenter]
                                          forState:UIControlStateNormal];

        [self.attributionButton addTarget:self action:@selector(urlContainerTapped) forControlEvents:UIControlEventTouchUpInside];

        // Artist Container View
        self.artistPicture = [[UIImageView alloc] init];

        self.artistHeader = [[UILabel alloc] init];
        self.artistHeader.attributedText = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionReusableAttributionViewAbout"]
                                                                          withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:IMCollectionReusableAttributionViewDefaultFontSize]
                                                                             color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.6f]
                                                                      andAlignment:NSTextAlignmentLeft];

        self.artistName = [[UILabel alloc] init];

        self.artistSummary = [[UILabel alloc] init];
        self.artistSummary.lineBreakMode = NSLineBreakByWordWrapping;
        self.artistSummary.numberOfLines = 2;

        // Add subviews
        [self addSubview:self.footerView];

        [self.footerView addSubview:self.urlContainer];
        [self.footerView addSubview:self.artistContainer];

        [self.urlContainer addSubview:self.attributionLabel];
        [self.urlContainer addSubview:self.attributionLinkImage];
        [self.urlContainer addSubview:self.attributionButton];

        [self.artistContainer addSubview:self.artistPicture];
        [self.artistContainer addSubview:self.artistHeader];
        [self.artistContainer addSubview:self.artistName];
        [self.artistContainer addSubview:self.artistSummary];

        // View Constraints
        [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.urlContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self.footerView);
            make.height.equalTo(@(IMCollectionReusableAttributionViewURLContainerHeight));
        }];

        [self.artistContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.urlContainer.mas_bottom).offset(IMCollectionReusableAttributionViewSeparatorSize);
            make.left.equalTo(self.footerView).offset(IMCollectionReusableAttributionViewContainerOffset);
            make.right.equalTo(self.footerView).offset(-IMCollectionReusableAttributionViewContainerOffset);
            make.bottom.equalTo(self.footerView).offset(-IMCollectionReusableAttributionViewSeparatorSize);
        }];

        // URL container subview constraints
        [self.attributionLinkImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.urlContainer).offset(22.0f);
            make.centerY.equalTo(self.urlContainer);
        }];

        [self.attributionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.attributionLinkImage.mas_right).offset(10.0f);
            make.centerY.equalTo(self.urlContainer);
        }];

        [self.attributionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.urlContainer).offset(-12.0f);
            make.centerY.equalTo(self.urlContainer);
            make.width.equalTo(@(IMCollectionReusableAttributionViewAttributionButtonWidth));
            make.height.equalTo(@(IMCollectionReusableAttributionViewAttributionButtonHeight));
        }];

        // Artist container subview constraints
        [self.artistPicture mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(11.0f);
            make.left.equalTo(self.artistContainer);
            make.width.and.height.equalTo(@(IMCollectionReusableAttributionViewArtistPictureWidthHeight));
        }];

        [self.artistHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(20.0f);
            make.left.equalTo(self.artistPicture.mas_right).offset(11.0f);
        }];

        [self.artistName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistHeader.mas_bottom).offset(2.0f);
            make.left.equalTo(self.artistPicture.mas_right).offset(11.0f);
        }];

        [self.artistSummary mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistPicture.mas_bottom).offset(12.0f);
            make.bottom.equalTo(self.artistContainer).offset(-15.0f);
            make.left.and.right.equalTo(self.artistContainer);
        }];
    }

    self.attributionLink = attribution.URL;

    self.artistName.attributedText = [IMAttributeStringUtil attributedString:[attribution.artist.name uppercaseString]
                                                                    withFont:[IMAttributeStringUtil sfUITextBoldFontWithSize:IMCollectionReusableAttributionViewArtistNameFontSize]
                                                                       color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.8f]
                                                                andAlignment:NSTextAlignmentLeft];

    self.artistSummary.attributedText = [IMAttributeStringUtil attributedString:attribution.artist.summary
                                                                       withFont:[IMAttributeStringUtil sfUIDisplayLightFontWithSize:IMCollectionReusableAttributionViewArtistSummaryFontSize]
                                                                          color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.5f]
                                                                   andAlignment:NSTextAlignmentNatural];
}

- (void)urlContainerTapped {
    if(self.attributionViewDelegate && [self.attributionViewDelegate respondsToSelector:@selector(userDidSelectAttributionLink:fromCollectionReusableView:)]) {
        [self.attributionViewDelegate userDidSelectAttributionLink:self.attributionLink
                                        fromCollectionReusableView:self];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillRect(context, CGRectMake(0, IMCollectionReusableAttributionViewURLContainerHeight, self.frame.size.width, self.frame.size.height - IMCollectionReusableAttributionViewURLContainerHeight));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:0.08f].CGColor);
    CGContextFillRect(context, CGRectMake(0, IMCollectionReusableAttributionViewURLContainerHeight, self.frame.size.width, IMCollectionReusableAttributionViewSeparatorSize));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0, self.frame.size.height - IMCollectionReusableAttributionViewSeparatorSize, self.frame.size.width, IMCollectionReusableAttributionViewSeparatorSize));
}

@end
