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

#import <ImojiSDKUI/IMCameraEnableAccessView.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <Masonry/View+MASAdditions.h>

@implementation IMCameraEnableAccessView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }

    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];

    NSArray *instructionsList = [self instructionsList];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"Please enable camera access"
                                                               withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.0f]
                                                                  color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                           andAlignment:NSTextAlignmentCenter];

    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.backgroundColor = [UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
    self.confirmButton.layer.cornerRadius = 3.0f;
    [self.confirmButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Go to Settings"
                                                                          withFont:[IMAttributeStringUtil montserratLightFontWithSize:18.0f]
                                                                             color:[UIColor whiteColor]]
                                  forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:titleLabel];
    [self addSubview:self.confirmButton];

    CGFloat instructionsOffset = -IMCameraEnableAccessViewInstructionsOffsetHeight * ceilf(instructionsList.count / 2);

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(instructionsOffset - IMCameraEnableAccessViewInstructionsOffsetHeight);
        make.centerX.equalTo(self.confirmButton);
        make.height.equalTo(@(IMCameraEnableAccessViewInstructionOptionHeight));
        make.width.equalTo(self);
    }];

    for (NSUInteger i = 0; i < instructionsList.count; i++) {
        UILabel *instructionLabel = [[UILabel alloc] init];
        instructionLabel.attributedText = instructionsList[i];

        [self addSubview:instructionLabel];

        [instructionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(instructionsOffset);
            make.height.equalTo(@(IMCameraEnableAccessViewInstructionOptionHeight));
            make.centerX.equalTo(self.confirmButton);
            make.width.equalTo(self);
        }];

        instructionsOffset += IMCameraEnableAccessViewInstructionsOffsetHeight;
    }

    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(IMCameraEnableAccessViewConfirmButtonWidth));
        make.height.equalTo(@(IMCameraEnableAccessViewConfirmButtonHeight));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(instructionsOffset + IMCameraEnableAccessViewConfirmButtonHeight / 2.0f);
    }];
}

- (NSArray *)instructionsList {
    NSMutableArray *instructionsList = [[NSMutableArray alloc] init];

    NSMutableAttributedString *instruction = [[NSMutableAttributedString alloc] initWithString:@""];
    [instruction appendAttributedString:[self makeAttributedInstructionStep:@"1."]];
    [instruction appendAttributedString:[self makeAttributedGreyInstruction:@" OPEN"]];
    [instruction appendAttributedString:[self makeAttributedBlueInstruction:@" SETTINGS"]];
    [instructionsList addObject:instruction.mutableCopy];

    [instruction.mutableString setString:@""];
    [instruction appendAttributedString:[self makeAttributedInstructionStep:@"2."]];
    [instruction appendAttributedString:[self makeAttributedGreyInstruction:@" GO TO"]];
    [instruction appendAttributedString:[self makeAttributedBlueInstruction:@" PRIVACY"]];
    [instructionsList addObject:instruction.mutableCopy];

    [instruction.mutableString setString:@""];
    [instruction appendAttributedString:[self makeAttributedInstructionStep:@"3."]];
    [instruction appendAttributedString:[self makeAttributedGreyInstruction:@" CHOOSE"]];
    [instruction appendAttributedString:[self makeAttributedBlueInstruction:@" CAMERA"]];
    [instructionsList addObject:instruction.mutableCopy];

    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [instruction.mutableString setString:@""];
    [instruction appendAttributedString:[self makeAttributedInstructionStep:@"4."]];
    [instruction appendAttributedString:[self makeAttributedGreyInstruction:@" TURN ON"]];
    [instruction appendAttributedString:[self makeAttributedBlueInstruction:appName ? [NSString stringWithFormat:@" %@", appName.uppercaseString] : @" THE APP"]];
    [instructionsList addObject:instruction.mutableCopy];

    return instructionsList;
}

- (NSAttributedString *)makeAttributedInstructionStep:(NSString *)string {
    return [IMAttributeStringUtil attributedString:string
                                          withFont:[IMAttributeStringUtil montserratRegularFontWithSize:13.0f]
                                             color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1.0f]
                                      andAlignment:NSTextAlignmentCenter];
}

- (NSAttributedString *)makeAttributedGreyInstruction:(NSString *)string {
    return [IMAttributeStringUtil attributedString:string
                                          withFont:[IMAttributeStringUtil montserratLightFontWithSize:13.0f]
                                             color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1.0f]
                                      andAlignment:NSTextAlignmentCenter];
}

- (NSAttributedString *)makeAttributedBlueInstruction:(NSString *)string {
    return [IMAttributeStringUtil attributedString:string
                                          withFont:[IMAttributeStringUtil montserratLightFontWithSize:13.0f]
                                             color:[UIColor colorWithRed:55.0f / 255.0f green:123.0f / 255.0f blue:167.0f / 255.0f alpha:1.0f]
                                      andAlignment:NSTextAlignmentCenter];
}

- (void)confirmButtonTapped:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapConfirmButton)]) {
        [self.delegate userDidTapConfirmButton];
    }
}

+ (instancetype)imojiCameraEnableAccessView {
    return [[IMCameraEnableAccessView alloc] initWithFrame:CGRectZero];
}

@end
