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

#import "IMAttributionShelfView.h"
#import <ImojiSDK/IMArtist.h>
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <Masonry/Masonry.h>
#import <YYImage/YYImage.h>

const CGFloat IMAttributionShelfViewButtonTopOffset = 14.0f;
const CGFloat IMAttributionShelfViewButtonTextSize = 12.0f;
const CGFloat IMAttributionShelfViewButtonImageTextOffset = 5.0f;
const CGFloat IMAttributionShelfViewHeight = 82.0f;
const CGFloat IMAttributionShelfViewPreviewImojiImageViewWidthHeight = 100.0f;
const CGFloat IMAttributionShelfViewPreviewImojiImageViewTextOffset = 3.0f;

@interface IMAttributionShelfView ()

@property(nonatomic, strong, readonly) IMImojiObject *imoji;
@property(nonatomic, strong, readonly) IMImojiSession *imojiSession;

@property(nonatomic, strong) UIButton *favoriteButton;
@property(nonatomic, strong) UIButton *relatedButton;
@property(nonatomic, strong) UIButton *attributionButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIImageView *previewImojiImageView;

@end

@implementation IMAttributionShelfView

#pragma mark View Lifecycle
- (instancetype)initWithImoji:(IMImojiObject *)imoji imojiSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _imoji = imoji;
        _imojiSession = session;

        [self setup];
    }

    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.5f];

    self.favoriteButton = [self buttonWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_favorite.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                                          alpha:0.84f
                                           text:@"Favorite"
                                textImageInsets:UIEdgeInsetsMake(IMAttributionShelfViewButtonImageTextOffset, 0, 0, 0)
                                           font:[IMAttributeStringUtil sfUITextMediumFontWithSize:IMAttributionShelfViewButtonTextSize]
                                          color:[UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:0.84f]];
    [self.favoriteButton addTarget:self action:@selector(attributionShelfButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.favoriteButton.tag = IMAttributionShelfViewButtonFavorite;

    self.relatedButton = [self buttonWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_related.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                                         alpha:0.84f
                                          text:@"Related"
                               textImageInsets:UIEdgeInsetsMake(IMAttributionShelfViewButtonImageTextOffset, 0, 0, 0)
                                          font:[IMAttributeStringUtil sfUITextMediumFontWithSize:IMAttributionShelfViewButtonTextSize]
                                         color:[UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:0.84f]];
    [self.relatedButton addTarget:self action:@selector(attributionShelfButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.relatedButton.tag = IMAttributionShelfViewButtonRelated;

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.alpha = 0.74f;
    [self.cancelButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_close.png", [IMResourceBundleUtil assetsBundle].bundlePath]] forState:UIControlStateNormal];
    [self.cancelButton setImageEdgeInsets:UIEdgeInsetsMake(4.75f, 4.75f, 4.75f, 4.75f)];
    [self.cancelButton addTarget:self action:@selector(attributionShelfButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.tag = IMAttributionShelfViewButtonCancel;

    [self addSubview:self.favoriteButton];
    [self addSubview:self.relatedButton];
    [self addSubview:self.cancelButton];

    [self.favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(IMAttributionShelfViewButtonTopOffset);
        make.left.equalTo(self).offset(27.0f);
    }];

    [self.relatedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(IMAttributionShelfViewButtonTopOffset);
        make.left.equalTo(self.favoriteButton.mas_right).offset(32.0f);
    }];

    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-3.75f);
        make.width.and.height.equalTo(@34.0f);
    }];
}

- (void)setupAttributionButton {
    if(self.attribution && self.attribution.artist && self.attribution.URL) {
        NSString *attributionText = @"";
        UIImage *attributionImage = [[UIImage alloc] init];

        switch(self.attribution.urlCategory) {
            case IMAttributionURLCategoryAppStore:
                attributionText = @"App";
                attributionImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_link_appstore.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
                break;
            case IMAttributionURLCategoryInstagram:
                attributionText = @"Instagram";
                attributionImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_link_instagram.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
                break;
            case IMAttributionURLCategoryTwitter:
                attributionText = @"Twitter";
                attributionImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_link_twitter.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
                break;
            case IMAttributionURLCategoryVideo:
                attributionText = @"Video";
                attributionImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_link_video.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
                break;
            case IMAttributionURLCategoryWebsite:
                attributionText = @"Website";
                attributionImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shelf_link_website.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
                break;
            default:
                break;
        }

        self.attributionButton = [self buttonWithImage:attributionImage
                                                 alpha:0.84f
                                                  text:attributionText
                                       textImageInsets:UIEdgeInsetsMake(IMAttributionShelfViewButtonImageTextOffset, 0, 0, 0)
                                                  font:[IMAttributeStringUtil sfUITextMediumFontWithSize:IMAttributionShelfViewButtonTextSize]
                                                 color:[UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:0.84f]];
        [self.attributionButton addTarget:self action:@selector(attributionShelfButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.attributionButton.tag = IMAttributionShelfViewButtonAttribution;

        [self addSubview:self.attributionButton];

        [self.attributionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(IMAttributionShelfViewButtonTopOffset);
            make.left.equalTo(self.relatedButton.mas_right).offset(32.0f);
        }];
    }
}

- (void)setupAttributionImageLabel {
    if (self.attribution && self.attribution.artist && self.attribution.URL && self.attribution.artist.name) {
        UILabel *imageLabel = [[UILabel alloc] init];
        imageLabel.attributedText = [IMAttributeStringUtil attributedString:self.attribution.artist.name
                                                                   withFont:[IMAttributeStringUtil sfUITextMediumFontWithSize:IMAttributionShelfViewButtonTextSize]
                                                                      color:[UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]];
        [self addSubview:imageLabel];

        [imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.previewImojiImageView.mas_bottom).offset(IMAttributionShelfViewPreviewImojiImageViewTextOffset);
            make.centerX.equalTo(self.previewImojiImageView);
        }];
    }
}

#pragma IMAttributionShelfView Button Targets
- (void)attributionShelfButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapAttributionShelfButtonWithType:)]) {
        [self.delegate userDidTapAttributionShelfButtonWithType:(IMAttributionShelfViewButtonType) sender.tag];
    }
}

#pragma mark IMAttributionShelfView Button Creation
- (UIButton *)buttonWithImage:(UIImage *)image
                        alpha:(CGFloat)alpha
                         text:(NSString *)text
              textImageInsets:(UIEdgeInsets)textImageInsets
                         font:(UIFont *)font
                        color:(UIColor *)color {
    CGSize imageSize = image.size;
    CGSize textSize = text ? [text sizeWithAttributes:@{NSFontAttributeName : font}] : CGSizeZero;
    CGSize frameSize = CGSizeMake(MAX(imageSize.width, textSize.width), imageSize.height + textSize.height + textImageInsets.top + textImageInsets.bottom);

    UIGraphicsBeginImageContextWithOptions(frameSize, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);

    if (text) {
        [text drawAtPoint:CGPointMake((frameSize.width - textSize.width) / 2.0f, frameSize.height - textSize.height)
           withAttributes:@{
                   NSFontAttributeName : font,
                   NSForegroundColorAttributeName : color
           }];
    }

    [image drawInRect:CGRectMake((frameSize.width - imageSize.width) / 2.0f, 0.0f, imageSize.width, imageSize.height)
            blendMode:kCGBlendModeNormal
                alpha:alpha];

    UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];

    return button;
}

#pragma mark Properties
- (void)setAttribution:(IMCategoryAttribution *)attribution {
    _attribution = attribution;

    IMImojiObjectRenderingOptions *renderingOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail
                                                                                               borderStyle:IMImojiObjectBorderStyleNone
                                                                                               imageFormat:IMImojiObjectImageFormatWebP];
    renderingOptions.renderAnimatedIfSupported = YES;
    [self.imojiSession renderImoji:self.imoji
                           options:renderingOptions
                          callback:^(UIImage *image, NSError *error) {
                              if (image) {
                                  self.previewImojiImageView = [[YYAnimatedImageView alloc] initWithImage:image];
                                  self.previewImojiImageView.contentMode = UIViewContentModeScaleAspectFit;
                                  self.previewImojiImageView.backgroundColor = [UIColor clearColor];

                                  [self.imojiSession renderImoji:self.imoji
                                                         options:[IMImojiObjectRenderingOptions optionsWithRenderSize:self.imoji.supportsAnimation ? IMImojiObjectRenderSize320 : IMImojiObjectRenderSizeFullResolution]
                                                        callback:^(UIImage *fullSizeImage, NSError *fullSizeImageError) {
                                                            if (fullSizeImage) {
                                                                self.previewImojiImageView = [[YYAnimatedImageView alloc] initWithImage:fullSizeImage];
                                                            }
                                                        }];

                                  [self addSubview:self.previewImojiImageView];

                                  [self.previewImojiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                                      make.right.equalTo(self).offset(-38.0f);

                                      if(self.attribution && self.attribution.artist && self.attribution.artist.name) {
                                          make.centerY.equalTo(self.mas_top);
                                      } else {
                                          make.centerY.equalTo(self.mas_top).offset(IMAttributionShelfViewButtonTextSize + IMAttributionShelfViewPreviewImojiImageViewTextOffset);
                                      }

                                      make.width.and.height.equalTo(@(IMAttributionShelfViewPreviewImojiImageViewWidthHeight));
                                  }];

                                  [self setupAttributionImageLabel];
                              }
                          }];

    [self setupAttributionButton];
}

+ (instancetype)imojiAttributionShelfViewWithImoji:(IMImojiObject *)imoji imojiSession:(IMImojiSession *)session {
    return [[IMAttributionShelfView alloc] initWithImoji:imoji imojiSession:session];
}

@end
