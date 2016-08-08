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

#import <ImojiSDK/IMImojiSession.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <Masonry/View+MASAdditions.h>
#import <ImojiSDKUI/IMSuggestionCollectionView.h>

CGFloat const IMSuggestionViewDefaultHeight = 91.f;
CGFloat const IMSuggestionViewBorderHeight = 1.f;

@interface IMSuggestionView ()
@end

@implementation IMSuggestionView {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        _collectionView = [self createSuggestionCollectionViewWithSession:session];
        self.collectionView.backgroundColor = [UIColor clearColor];

        [self addSubview:self.collectionView];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }

    return self;
}

- (IMCollectionView *)createSuggestionCollectionViewWithSession:(IMImojiSession *)session {
    return [[IMSuggestionCollectionView alloc] initWithSession:session];
}

+ (instancetype)imojiSuggestionViewWithSession:(IMImojiSession *)session {
    return [[IMSuggestionView alloc] initWithSession:session];
}

@end
