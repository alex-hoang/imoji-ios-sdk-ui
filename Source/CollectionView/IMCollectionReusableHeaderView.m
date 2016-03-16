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

#import "IMCollectionReusableHeaderView.h"
#import "IMAttributeStringUtil.h"
#import <Masonry/View+MASAdditions.h>
#import "IMResourceBundleUtil.h"

NSString *const IMCollectionReusableHeaderViewReuseId = @"IMCollectionReusableHeaderViewReuseId";

@interface IMCollectionReusableHeaderView ()

@end

@implementation IMCollectionReusableHeaderView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];

    if (self) {
        _headerView = self.subviews.firstObject;
    }

    return self;
}

- (void)setupWithText:(NSString *)header multipleSections:(BOOL)multipleSections separator:(BOOL)separator {
    if (!self.headerView) {
        _headerView = [[UIView alloc] init];

        _title = [[UILabel alloc] init];

        _separatorView = [[UIView alloc] initWithFrame:CGRectZero];

        UIView *graySeparator = [[UIView alloc] initWithFrame:CGRectZero];
        graySeparator.backgroundColor = [UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:0.08f];

        UIView *grayBackground = [[UIView alloc] initWithFrame:CGRectZero];
        grayBackground.backgroundColor = [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f];

        UIView *whiteSeparator = [[UIView alloc] initWithFrame:CGRectZero];
        whiteSeparator.backgroundColor = [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];

        _contextLabel = [[UILabel alloc] init];
        self.contextLabel.attributedText = [IMAttributeStringUtil attributedString:[[IMResourceBundleUtil localizedStringForKey:@"collectionReusableHeaderViewContext"] uppercaseString]
                                                                          withFont:[IMAttributeStringUtil sfUITextMediumFontWithSize:12.0f]
                                                                             color:[UIColor colorWithRed:196.0f / 255.0f green:200.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f]
                                                                      andAlignment:NSTextAlignmentCenter];

        [self addSubview:self.headerView];

        [self.separatorView addSubview:graySeparator];
        [self.separatorView addSubview:grayBackground];
        [self.separatorView addSubview:whiteSeparator];

        [self.headerView addSubview:self.title];

        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.headerView);
        }];

        [graySeparator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self.separatorView);
            make.height.equalTo(@2.0f);
        }];

        [grayBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(graySeparator.mas_bottom);
            make.left.and.right.equalTo(self.separatorView);
            make.height.equalTo(@14.0f);
        }];

        [whiteSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(grayBackground.mas_bottom);
            make.left.and.right.equalTo(self.separatorView);
            make.height.equalTo(@2.0f);
        }];
    }

    [self.separatorView removeFromSuperview];
    [self.contextLabel removeFromSuperview];

    if(separator) {
        [self.headerView addSubview:self.separatorView];
        [self.headerView addSubview:self.contextLabel];

        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self.headerView);
            make.height.equalTo(@18.0f);
        }];

        [self.contextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.separatorView.mas_bottom).offset(16.0f);
            make.centerX.equalTo(self.headerView);
        }];

        [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contextLabel.mas_bottom);
            make.centerX.equalTo(self.contextLabel);
        }];
    } else if(multipleSections) {
        [self.headerView addSubview:self.contextLabel];

        [self.contextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView).offset(16.0f);
            make.centerX.equalTo(self.headerView);
        }];

        [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contextLabel.mas_bottom);
            make.centerX.equalTo(self.contextLabel);
        }];
    } else {
        [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.headerView);
        }];
    }

    self.title.attributedText = [IMAttributeStringUtil attributedString:[header uppercaseString]
                                                               withFont:[IMAttributeStringUtil sfUIDisplayMediumFontWithSize:22.0f]
                                                                  color:[UIColor colorWithRed:92.0f / 255.0f green:97.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f]
                                                           andAlignment:NSTextAlignmentCenter];
}

@end