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

#import "IMPopInAnimatedTransition.h"
#import <Masonry/View+MASAdditions.h>

@implementation IMPopInAnimatedTransition {

}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitionDirection = IMPopInAnimatedTransitionDirectionUp;
    }

    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return .6f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (toViewController.isBeingPresented) {
        UIView *fromView = [fromViewController.view resizableSnapshotViewFromRect:fromViewController.view.frame
                                                               afterScreenUpdates:NO
                                                                    withCapInsets:UIEdgeInsetsZero];
        UIView *toView = toViewController.view;

        UIView *blurredView = [self generateViewControllerBackground];
        [transitionContext.containerView addSubview:blurredView];
        [transitionContext.containerView addSubview:toView];

        [blurredView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(transitionContext.containerView);
        }];
        [toView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(transitionContext.containerView);

            switch (self.transitionDirection) {
                case IMPopInAnimatedTransitionDirectionLeft:
                    make.right.equalTo(blurredView.mas_left);
                    make.top.equalTo(blurredView);
                    break;
                case IMPopInAnimatedTransitionDirectionRight:
                    make.left.equalTo(blurredView.mas_right);
                    make.top.equalTo(blurredView);
                    break;
                case IMPopInAnimatedTransitionDirectionUp:
                    make.top.equalTo(blurredView.mas_bottom);
                    make.left.equalTo(blurredView);
                    break;
                case IMPopInAnimatedTransitionDirectionDown:
                    make.bottom.equalTo(blurredView.mas_top);
                    make.left.equalTo(blurredView);
                    break;
            }
        }];
        [toView layoutIfNeeded];

        blurredView.layer.opacity = 0.0f;

        [toView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(blurredView);
        }];
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromView.layer.opacity = 0.0f;
                             blurredView.layer.opacity = 1.0f;
                             [toView layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    } else {
        UIView *fromView = fromViewController.view;
        UIView *blurredView = transitionContext.containerView.subviews.firstObject;

        [transitionContext.containerView addSubview:fromView];

        [fromView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(transitionContext.containerView);
        }];
        [fromView layoutIfNeeded];

        [fromView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(transitionContext.containerView);

            switch (self.transitionDirection) {
                case IMPopInAnimatedTransitionDirectionLeft:
                    make.right.equalTo(blurredView.mas_left);
                    make.top.equalTo(blurredView);
                    break;
                case IMPopInAnimatedTransitionDirectionRight:
                    make.left.equalTo(blurredView.mas_right);
                    make.top.equalTo(blurredView);
                    break;
                case IMPopInAnimatedTransitionDirectionUp:
                    make.top.equalTo(blurredView.mas_bottom);
                    make.left.equalTo(blurredView);
                    break;
                case IMPopInAnimatedTransitionDirectionDown:
                    make.bottom.equalTo(blurredView.mas_top);
                    make.left.equalTo(blurredView);
                    break;
            }
        }];

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             if (NSClassFromString(@"UIVisualEffectView")) {
                                 blurredView.layer.opacity = 0.0f;
                             }

                             [fromView layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }
        ];
    }
}

- (UIView *)generateViewControllerBackground {
    UIView *foregroundView;

    // show blurred background if available (iOS 8 and above)
    if (NSClassFromString(@"UIVisualEffectView")) {
        foregroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    } else {
        // fall back to a simple translucent background
        foregroundView = [UIView new];
        foregroundView.backgroundColor = [UIColor colorWithWhite:.2f alpha:.95f];
    }

    return foregroundView;
}

@end
