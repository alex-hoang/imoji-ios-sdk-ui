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
    override init(session: IMImojiSession) {
        super.init(session: session)
        
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(session: IMImojiSession())
        
        delegate = self
    }
    
    override func loadView() {
        super.loadView()
        
        let cancelButtonView = cameraView?.cancelButton?.customView as? UIButton
        cancelButtonView?.setImage(UIImage(named: "Artmoji-Cancel"), forState: UIControlState.Normal)
        cameraView?.captureButton?.setImage(UIImage(named: "Artmoji-Circle"), forState: UIControlState.Normal)
        cameraView?.flipButton?.setImage(UIImage(named: "Artmoji-Camera-Flip"), forState: UIControlState.Normal)
        cameraView?.photoLibraryButton?.setImage(UIImage(named: "Artmoji-Photo-Library"), forState: UIControlState.Normal)
    }
}

extension MainCameraViewController: IMCameraViewControllerDelegate {
    func userDidCaptureImage(image: UIImage, metadata: [NSObject : AnyObject], fromCameraViewController viewController: IMCameraViewController) {
        let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, capturedImageOrientation: self.currentOrientation, session: self.session, imageBundle: IMResourceBundleUtil.assetsBundle())
        presentViewController(createArtmojiViewController, animated: false, completion: nil)
    }
    
    func userDidPickMediaWithInfo(info: [String : AnyObject], fromImagePickerController picker: UIImagePickerController) {
        let image = info["UIImagePickerControllerOriginalImage"] as! UIImage;
        let createArtmojiViewController = IMCreateArtmojiViewController(sourceImage: image, capturedImageOrientation: nil, session: self.session, imageBundle: IMResourceBundleUtil.assetsBundle())
        createArtmojiViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        createArtmojiViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        picker.presentViewController(createArtmojiViewController, animated: true, completion: nil)
    }
}
