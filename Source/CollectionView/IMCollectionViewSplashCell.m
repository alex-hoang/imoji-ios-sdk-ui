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

#import "IMCollectionViewSplashCell.h"
#import "IMAttributeStringUtil.h"
#import "IMResourceBundleUtil.h"
#import <Masonry/Masonry.h>

NSString *const IMCollectionViewSplashCellReuseId = @"IMCollectionViewSplashCellReuseId";

@implementation IMCollectionViewSplashCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.splashContainer = [[UIView alloc] init];
        self.splashGraphic = [[UIImageView alloc] init];
        self.splashText = [[UILabel alloc] init];

        self.splashText.lineBreakMode = NSLineBreakByWordWrapping;
        self.splashText.numberOfLines = 2;

        [self addSubview:self.splashContainer];

        [self.splashContainer addSubview:self.splashGraphic];
        [self.splashContainer addSubview:self.splashText];
    }

    return self;
}

- (void)showSplashCellType:(IMCollectionViewSplashCellType)splashCellType withImageBundle:(NSBundle *)imageBundle {
    self.splashType = splashCellType;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    switch (splashCellType) {
        case IMCollectionViewSplashCellNoConnection:
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashNoConnection"]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:14.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];

            [self loadSplashCellWithText:attributedString imageName:@"collection_view_splash_enableaccess" imageBundle:imageBundle];
            break;
        case IMCollectionViewSplashCellNoResults: {
//            NSArray *textArray = [[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashNoResults"] componentsSeparatedByString:@"|"];
//            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[0]
//                                                                                    withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.0f]
//                                                                                       color:[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.3f]
//                                                                                andAlignment:NSTextAlignmentCenter]];
//            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[1]
//                                                                                    withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.0f]
//                                                                                       color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1]
//                                                                                andAlignment:NSTextAlignmentCenter]];

            [self setupSplashCellWithText:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashNoResults"]];
            break;
        }
        case IMCollectionViewSplashCellCollection:{
            NSArray *textArray = [[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashCollection"] componentsSeparatedByString:@"|"];
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[0]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayMediumFontWithSize:15.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[1]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:15.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];

            [self loadSplashCellWithText:attributedString imageName:@"collection_view_splash_collection" imageBundle:imageBundle];
            break;
        }
        case IMCollectionViewSplashCellRecents:
            [self setupSplashCellWithText:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashRecents"]];
            break;
        default:
            break;
    }
}

- (void)setupSplashCellWithText:(NSString *)text {
    self.splashGraphic.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_noresults_graphic_large.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
    self.splashText.attributedText = [IMAttributeStringUtil attributedString:text
                                                                    withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.0f]
                                                                       color:[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.3f]
                                                                andAlignment:NSTextAlignmentCenter];

    [self.splashContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@345.0f);
        make.height.equalTo(@239.0f);
        make.center.equalTo(self);
    }];

    [self.splashGraphic mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.splashContainer);
    }];

    [self.splashText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splashContainer);
        make.width.and.centerX.equalTo(self);
    }];
}

- (void)loadSplashCellWithText:(NSAttributedString *)text
                     imageName:(NSString *)imageName
                   imageBundle:(NSBundle *)imageBundle {
    self.splashGraphic.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", imageBundle.bundlePath, imageName]];
    self.splashText.attributedText = text;

    [self.splashContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.splashGraphic mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.splashContainer);
        make.centerY.equalTo(self.splashContainer).offset(-(self.splashGraphic.image.size.height / 2.0f));
    }];

    [self.splashText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splashGraphic.mas_bottom).offset(13.0f);
        make.width.and.centerX.equalTo(self.splashContainer);
    }];
}

@end
