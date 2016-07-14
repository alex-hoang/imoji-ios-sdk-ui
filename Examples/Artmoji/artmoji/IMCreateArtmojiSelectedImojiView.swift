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
import ImojiSDKUI

public class IMCreateArtmojiSelectedImojiView: UIView {

    // Required init variables
    private var session: IMImojiSession!
    private var renderingOptions: IMImojiObjectRenderingOptions!
    public var flipped: Bool

    // Imoji view (Read-only)
    private(set) public var imojiView: UIImageView!
    private(set) public var imoji: IMImojiObject?

    // Flags
    public var selected: Bool?
    public var showBorder: Bool?

    // MARK: - Object lifecycle
    public init(imoji: IMImojiObject, session: IMImojiSession) {
        self.imoji = imoji
        self.session = session
        renderingOptions = IMImojiObjectRenderingOptions(renderSize: IMImojiObjectRenderSize.SizeFullResolution)
        flipped = false

        super.init(frame:CGRectZero)

        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    func setup() {
        imojiView = UIImageView()

        session.renderImoji(imoji!, options: self.renderingOptions, callback: { image, error in
            if error == nil {
                self.imojiView.image = image
                self.frame.size.width = image!.size.width
                self.frame.size.height = image!.size.height
                self.frame.origin = CGPointMake((UIScreen.mainScreen().bounds.size.width - self.frame.size.width) / 2,
                    (UIScreen.mainScreen().bounds.size.height - self.frame.size.height) / 2)
            }
        })

        addSubview(imojiView)

        layer.cornerRadius = 5.0
        layer.borderColor = UIColor(red: 40.0 / 255.0, green: 40.0 / 255.0, blue: 40.0 / 255.0, alpha: 0.6).CGColor

        imojiView.mas_makeConstraints { make in
            make.center.equalTo()(self)
        }

        backgroundColor = UIColor.clearColor()
    }

    // MARK: - Imoji editing logic
    func flipHorizontal() {
        flipped = !flipped

        let image = imojiView.image!
        imojiView.image = IMDrawingUtils.flipImage(image)
        UIGraphicsEndImageContext()
    }

}
