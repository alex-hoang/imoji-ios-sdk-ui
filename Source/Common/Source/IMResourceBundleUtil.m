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
        #if COCOAPODS
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiUIStrings"
                                                                                           ofType:@"bundle"]];
        #else
        bundle = [NSBundle bundleWithPath: [[NSBundle bundleWithIdentifier:@"com.sopressata.ImojiSDKUI"] pathForResource:@"ImojiUIStrings"
                                                                                                                  ofType:@"bundle"]];
        #endif
    });

    return bundle;
}

+ (NSBundle *)assetsBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        #if COCOAPODS
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiUIAssets"
                                                                                           ofType:@"bundle"]];
        #else
        bundle = [NSBundle bundleWithPath: [[NSBundle bundleWithIdentifier:@"com.sopressata.ImojiSDKUI"] pathForResource:@"ImojiUIAssets"
                                                                                                                  ofType:@"bundle"]];
        #endif
    });

    return bundle;
}

+ (UIImage *)loadingPlaceholderImageWithRadius:(CGFloat)radius {
    return [IMResourceBundleUtil loadingPlaceholderImageWithRadius:radius color:[UIColor colorWithRed:81.0f / 255.0f
                                                                                                green:185.0f / 255.0f
                                                                                                 blue:197.0f / 255.0f
                                                                                                alpha:.3f]];
}

+ (UIImage *)loadingPlaceholderImageWithRadius:(CGFloat)radius color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, radius, radius));

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
