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

class MainCameraViewController: IMCameraViewController {
    // MARK: - Object lifecycle
    override init(session: IMImojiSession, imageBundle: NSBundle) {
        super.init(session: session, imageBundle: imageBundle)
        
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(session: IMImojiSession(), imageBundle: IMResourceBundleUtil.assetsBundle())
        
        delegate = self
    }
}

extension MainCameraViewController: IMCameraViewControllerDelegate {
    func userDidCaptureImage(image: UIImage, metadata: NSDictionary?, fromCameraViewController viewController: IMCameraViewController) {
        let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, capturedImageOrientation: self.currentOrientation, session: self.session, imageBundle: self.imageBundle)
        presentViewController(createArtmojiViewController, animated: false, completion: nil)
    }
    
    func userDidPickImage(image: UIImage, editingInfo: [NSObject : AnyObject]?, fromImagePickerController picker: UIImagePickerController) {
        let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, capturedImageOrientation: nil, session: self.session, imageBundle: self.imageBundle)
        createArtmojiViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        createArtmojiViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        picker.presentViewController(createArtmojiViewController, animated: true, completion: nil)
    }
}
