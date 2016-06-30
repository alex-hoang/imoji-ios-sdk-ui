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

#import <Masonry/Masonry.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <YYImage/YYImage.h>
#import "IMCollectionViewCell.h"

#if IMMessagesFrameworkSupported

#import <Messages/Messages.h>

#endif


NSString *const IMCollectionViewCellReuseId = @"ImojiCollectionViewCellReuseId";

@interface IMCollectionViewCell ()

@property(nonatomic, readonly) BOOL hasImojiImage;

@end

@implementation IMCollectionViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _placeholderView = [[UIImageView alloc] init];
        self.placeholderView.contentMode = UIViewContentModeCenter;

        [self addSubview:self.placeholderView];

        [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(@100.0f);
        }];
    }

    return self;
}

- (void)setupPlaceholderImageWithPosition:(NSUInteger)position {
    NSArray *placeholderImages = [IMResourceBundleUtil loadingPlaceholderImages];
    NSUInteger placeholderStartIndex = [IMResourceBundleUtil loadingPlaceholderStartIndex];
    UIImage *placeHolderImage = placeholderImages[(placeholderStartIndex + position) % placeholderImages.count];

    UIImageView *placeHolderImageView = (UIImageView *) self.placeholderView;
    placeHolderImageView.highlightedImage =
            placeHolderImageView.image = placeHolderImage;

    self.placeholderView.contentMode = UIViewContentModeCenter;
}

- (void)setupImojiViewWithStickerViewSupport:(BOOL)stickerViewSupport {
    if (_imojiView) {
        return;
    }

#if IMMessagesFrameworkSupported
    if (stickerViewSupport) {
        _imojiView = [[MSStickerView alloc] initWithFrame:self.frame sticker:nil];
    } else {
        _imojiView = [YYAnimatedImageView new];
    }
#else
    _imojiView = [YYAnimatedImageView new];
#endif

    [self addSubview:self.imojiView];
    [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.and.height.equalTo(@100.0f);
    }];
}

- (void)loadImojiImage:(nullable UIImage *)imojiImage animated:(BOOL)animated {
    [self setupImojiViewWithStickerViewSupport:NO];

    [(UIImageView *) self.imojiView setImage:imojiImage];
    _hasImojiImage = imojiImage != nil;
    if (_hasImojiImage) {
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
    }

    if (animated) {
        [self animateImojiLoading];
    }
}

- (void)loadImojiSticker:(nullable NSObject *)msStickerObject animated:(BOOL)animated {
    [self setupImojiViewWithStickerViewSupport:YES];

#if IMMessagesFrameworkSupported
    if (msStickerObject == nil) {
        [(MSStickerView *) self.imojiView setSticker:[self placeholderSticker]];
    } else {
        [self animateCellContents:NO];
        [(MSStickerView *) self.imojiView setSticker:(MSSticker *) msStickerObject];
    }
#endif

    _hasImojiImage = msStickerObject != nil;
    self.imojiView.contentMode = UIViewContentModeScaleAspectFit;

    if (animated) {
        [self animateImojiLoading];
    }
}

- (void)animateCellContents:(BOOL)animate {
#if IMMessagesFrameworkSupported
    MSStickerView *stickerView = (MSStickerView *) self.imojiView;
    if (stickerView.sticker && [stickerView.sticker.imageFileURL.pathExtension isEqualToString:@"gif"]) {
        if (animate) {
            [stickerView startAnimating];
        } else if (stickerView.isAnimating) {
            [stickerView stopAnimating];
        }
    }
#endif
}

- (void)animateImojiLoading {
    if (_hasImojiImage) {
        BOOL animateImmediately = ![self respondsToSelector:@selector(preferredLayoutAttributesFittingAttributes:)];

        if (animateImmediately) {
            [self performPlaceholderRetractAnimation];
            [self performLoadedAnimation];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performPlaceholderRetractAnimation];
                [self performLoadedAnimation];
            });
        }
    } else {
        [self performLoadedAnimation];
    }
}

- (void)performLoadedAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @0.0f;
    animation.toValue = @1.0f;
    animation.duration = 0.7f;

    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3f :0.14f :0.36f :1.36f];

    if (self.hasImojiImage) {
        [self.imojiView.layer addAnimation:animation forKey:@"loaded"];
        self.imojiView.layer.transform = CATransform3DIdentity;
    } else {
        [self.placeholderView.layer addAnimation:animation forKey:@"loaded"];
        self.placeholderView.layer.transform = CATransform3DIdentity;
    }
}

- (void)performPlaceholderRetractAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @1.0f;
    animation.toValue = @0.0f;
    animation.duration = 1.0f;

    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :0.1f :0.25f :1.0f];

    [self.placeholderView.layer addAnimation:animation forKey:@"retract"];
    self.placeholderView.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
}

- (void)performTappedAnimation {
    if (!self.hasImojiImage) {
        return;
    }

    [CATransaction begin];
    [self.imojiView.layer removeAllAnimations];
    [CATransaction commit];

    CABasicAnimation *contractAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    contractAnimation.fromValue = @1.0f;
    contractAnimation.toValue = @0.8f;
    contractAnimation.duration = 0.5f;

    CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    growAnimation.fromValue = @0.8f;
    growAnimation.toValue = @1.0f;
    growAnimation.duration = 0.5f;
    growAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.23f :0.09f :0.37f :1.36f];

    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.animations = @[contractAnimation, growAnimation];
    animationGroup.duration = 0.5f;

    [self.imojiView.layer addAnimation:animationGroup forKey:@"tapped"];
    self.imojiView.layer.transform = CATransform3DIdentity;
}

- (void)performGrowAnimation {
    if (!self.hasImojiImage) {
        return;
    }

    [CATransaction begin];
    [self.imojiView.layer removeAllAnimations];
    [CATransaction commit];

    CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    growAnimation.fromValue = @0.8f;
    growAnimation.toValue = @1.0f;
    growAnimation.duration = 0.5f;
    growAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.23f :0.09f :0.37f :1.16f];

    [self.imojiView.layer addAnimation:growAnimation forKey:@"grow"];
    self.imojiView.layer.transform = CATransform3DIdentity;
}

- (void)performShrinkAnimation {
    if (!self.hasImojiImage) {
        return;
    }

    [CATransaction begin];
    [self.imojiView.layer removeAllAnimations];
    [CATransaction commit];

    CABasicAnimation *contractAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    contractAnimation.fromValue = @1.0f;
    contractAnimation.toValue = @0.8f;
    contractAnimation.duration = 0.2f;

    [self.imojiView.layer addAnimation:contractAnimation forKey:@"shrink"];
    self.imojiView.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
}

- (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect drawRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

#if IMMessagesFrameworkSupported

- (nullable MSSticker *)placeholderSticker {
    static int position = 0;
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@placeHolderImage-%@.png",
                                         NSTemporaryDirectory(), @(position)
                                         ]];
    NSArray *placeholderImages = [IMResourceBundleUtil loadingPlaceholderImages];
    UIImage *placeHolderImage = placeholderImages[position % placeholderImages.count];
    position = (position + 1) % placeholderImages.count;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [UIImagePNGRepresentation(placeHolderImage) writeToURL:url atomically:YES];
    }
    
    NSError *error;
    return [[MSSticker alloc] initWithContentsOfFileURL:url
                                   localizedDescription:@"placeholder"
                                                  error:&error];
}

#endif

@end

