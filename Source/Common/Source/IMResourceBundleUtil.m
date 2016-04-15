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

#import "IMResourceBundleUtil.h"

@implementation IMResourceBundleUtil {

}

+ (NSString *)localizedStringForKey:(NSString *)key {
    return [IMResourceBundleUtil localizedStringForKey:key comment:key];
}

+ (NSString *)localizedStringForKey:(NSString *)key comment:(NSString *)comment {
    return NSLocalizedStringFromTableInBundle(key, nil, [IMResourceBundleUtil stringsBundle], comment);
}

+ (NSBundle *)stringsBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiUIStrings"
                                                                                           ofType:@"bundle"]];
    });

    return bundle;
}

+ (NSBundle *)assetsBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiUIAssets"
                                                                                           ofType:@"bundle"]];
    });

    return bundle;
}

+ (NSArray *)loadingPlaceholderColors {
    static NSArray *loadingPlaceholderColors = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        loadingPlaceholderColors = @[
                [UIColor colorWithRed:51.0f / 255.0f green:157.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:105.0f / 255.0f green:203.0f / 255.0f blue:210.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:255.0f / 255.0f green:207.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:251.0f / 255.0f green:99.0f / 255.0f blue:112.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:222.0f / 255.0f green:171.0f / 255.0f blue:201.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:133.0f / 255.0f green:173.0f / 255.0f blue:214.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:66.0f / 255.0f green:217.0f / 255.0f blue:66.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:255.0f / 255.0f green:152.0f / 255.0f blue:84.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:235.0f / 255.0f green:157.0f / 255.0f blue:157.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:145.0f / 255.0f green:107.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:77.0f / 255.0f green:216.0f / 255.0f blue:247.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:133.0f / 255.0f green:198.0f / 255.0f blue:134.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:212.0f / 255.0f green:168.0f / 255.0f blue:140.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:255.0f / 255.0f green:125.0f / 255.0f blue:180.0f / 255.0f alpha:1.0f],
                [UIColor colorWithRed:184.0f / 255.0f green:170.0f / 255.0f blue:210.0f / 255.0f alpha:1.0f]
        ];
    });

    return loadingPlaceholderColors;
}

+ (UIImage *)loadingPlaceholderImageWithRadius:(CGFloat)radius {
    NSArray *placeholderColors = [[self class] loadingPlaceholderColors];
    return [IMResourceBundleUtil loadingPlaceholderImageWithRadius:radius color:placeholderColors[arc4random() % placeholderColors.count]];
}

+ (UIImage *)loadingPlaceholderImageWithRadius:(CGFloat)radius color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect frame = CGRectMake(0, 0, radius, radius);

    // Gradient settings
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0f, 1.0f};
    CGFloat colorComponents[] = {
            255.0f / 255.0f, 255.0f / 255.0f, 255.0f / 255.0f, 0.16f,
            255.0f / 255.0f, 255.0f / 255.0f, 255.0f / 255.0f, 0.0f
    };

    // Fill circle
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect(context, frame);

    // Mask the gradient
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, frame);
    CGContextClip(context);

    // Draw gradient
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(radius / 2.0f, 0), CGPointMake(radius / 2.0f, radius), 0);

    // Release
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);

    UIImage *layer = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return layer;
}

+ (nonnull UIImage *)rightArrowButtonImage:(CGFloat)radius
                               circleColor:(nonnull UIColor *)circleColor
                               borderColor:(nonnull UIColor *)borderColor
                               strokeWidth:(CGFloat)borderWidth
                                 iconImage:(nullable UIImage *)iconImage {
    CGSize size = CGSizeMake(radius + borderWidth, radius + borderWidth);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextStrokeEllipseInRect(context, CGRectMake(borderWidth / 2.0f, borderWidth / 2.0f, radius, radius));

    CGContextSetFillColorWithColor(context, circleColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, radius, radius));
    
    if (iconImage) {
        [iconImage drawInRect:CGRectMake(
                (size.width - iconImage.size.width)/2.0f, (size.height - iconImage.size.height)/2.0f,
                iconImage.size.width, iconImage.size.height
        )];
    }

    UIImage *layer = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return layer;
}

@end
