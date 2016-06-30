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

#import "IMSuggestionViewCell.h"
#import "IMResourceBundleUtil.h"
#import <Masonry/Masonry.h>


@implementation IMSuggestionViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.placeholderView.image = [IMResourceBundleUtil loadingPlaceholderImageWithRadius:62.0f];
        self.placeholderView.contentMode = UIViewContentModeScaleAspectFit;

        [self.placeholderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(@62.0f);
        }];
    }

    return self;
}

- (void)setupImojiViewWithStickerViewSupport:(BOOL)stickerViewSupport {
    [super setupImojiViewWithStickerViewSupport:stickerViewSupport];
    [self.imojiView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.and.height.equalTo(@74.0f);
    }];
}

- (void)setupPlaceholderImageWithPosition:(NSUInteger)position {
    [super setupPlaceholderImageWithPosition:position];
    self.placeholderView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
