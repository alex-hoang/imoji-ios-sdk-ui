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

import UIKit

public class IMColorSlider: UISlider {
    private var colorView: UIImageView!

    public var vertical: Bool

    convenience public init() {
        self.init(frame: CGRectZero)
    }

    override public init(frame: CGRect) {
        vertical = false

        super.init(frame: frame)

        minimumValue = 0
        maximumValue = 1.0
        setMinimumTrackImage(UIImage(), forState: UIControlState.Normal)
        setMaximumTrackImage(UIImage(), forState: UIControlState.Normal)

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30,30), false, 0)
        UIColor.clearColor().setFill()
        UIRectFill(CGRectMake(0,0,1,1))
        let blankImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setThumbImage(blankImg, forState: .Normal)

        colorView = UIImageView()
        addSubview(colorView)

        colorView.mas_makeConstraints { make in
            make.edges.equalTo()(self)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        vertical = false

        super.init(coder: aDecoder)

        minimumValue = 0
        maximumValue = 1.0
        setMinimumTrackImage(UIImage(), forState: UIControlState.Normal)
        setMaximumTrackImage(UIImage(), forState: UIControlState.Normal)

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30,30), false, 0)
        UIColor.clearColor().setFill()
        UIRectFill(CGRectMake(0,0,1,1))
        let blankImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setThumbImage(blankImg, forState: .Normal)

        colorView = UIImageView()
        addSubview(colorView)

        colorView.mas_makeConstraints { make in
            make.edges.equalTo()(self)
        }
    }

    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)

        UIGraphicsBeginImageContext(colorView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        colorView.image?.drawInRect(CGRect(x: 0, y: 0, width: colorView.frame.size.width, height: colorView.frame.size.height))
        for i in 0...Int(IMArtmojiConstants.SliderWidth) {
            CGContextMoveToPoint(context!, CGFloat(i), frame.size.height / 2.0)
            CGContextAddLineToPoint(context!, CGFloat(i), frame.size.height / 2.0)
            CGContextSetLineCap(context!, CGLineCap.Round)
            CGContextSetLineWidth(context!, 8.0)
            CGContextSetStrokeColorWithColor(context!, UIColor(hue: CGFloat(i) / IMArtmojiConstants.SliderWidth, saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor)
            CGContextSetBlendMode(context!, CGBlendMode.Normal)
            CGContextStrokePath(context!)
        }

        colorView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if vertical {
            transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        }

        let outerLayer = CAGradientLayer()
        outerLayer.frame = UIEdgeInsetsInsetRect(colorView.bounds, UIEdgeInsetsMake(8, -3, 7, -3))
        colorView.layer.insertSublayer(outerLayer, atIndex: 0)
        outerLayer.cornerRadius = 3.0
        outerLayer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).CGColor
        outerLayer.borderWidth = 1.0

        let innerLayer = CAGradientLayer()
        innerLayer.frame = UIEdgeInsetsInsetRect(colorView.bounds, UIEdgeInsetsMake(9, -2, 8, -2))
        colorView.layer.insertSublayer(innerLayer, atIndex: 1)
        innerLayer.cornerRadius = 3.0
        innerLayer.borderColor = UIColor.whiteColor().CGColor
        innerLayer.borderWidth = 2.0
    }

    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)

        sendActionsForControlEvents(UIControlEvents.ValueChanged)
        return true
    }
}
