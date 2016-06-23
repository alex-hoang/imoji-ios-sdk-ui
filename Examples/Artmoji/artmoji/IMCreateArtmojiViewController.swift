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

public class IMCreateArtmojiViewController: UIViewController {

    // Required init variables
    private var session: IMImojiSession!
    public var imageBundle: NSBundle
    public var sourceImage: UIImage?
    public var capturedImageOrientation: UIImageOrientation

    // Artmoji view
    private(set) public var createArtmojiView: IMCreateArtmojiView!

    // MARK: - Object lifecycle
    public init(sourceImage: UIImage?, capturedImageOrientation: UIImageOrientation?, session: IMImojiSession, imageBundle: NSBundle) {
        self.sourceImage = sourceImage
        self.capturedImageOrientation = capturedImageOrientation ?? UIImageOrientation.Up
        self.session = session
        self.imageBundle = imageBundle

        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    override public func loadView() {
        if let _ = self.sourceImage {
            super.loadView()
            createArtmojiView = IMCreateArtmojiView(session: self.session, sourceImage: self.sourceImage!, imageBundle: self.imageBundle)
            createArtmojiView.capturedImageOrientation = self.capturedImageOrientation
            createArtmojiView.delegate = self

            view.addSubview(createArtmojiView)
            
            createArtmojiView.mas_makeConstraints { make in
                make.top.equalTo()(self.mas_topLayoutGuideBottom)
                make.left.equalTo()(self.view)
                make.right.equalTo()(self.view)
                make.bottom.equalTo()(self.mas_bottomLayoutGuideTop)
            }
        }
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Mark: - Buton action methods
    #if NOT_PHOTO_EXTENSION
    func collectionViewControllerCreateImojiButtonTapped() {
        let cameraViewController = MainCameraViewController(session: self.session, imageBundle: self.imageBundle)
        cameraViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        cameraViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        cameraViewController.delegate = self
        presentedViewController!.presentViewController(cameraViewController, animated: true, completion: nil)
    }
    #endif

    // Mark: - Draw create imoji button
    func drawCreateImojiButtonImage() -> UIImage {
        let size = CGSizeMake(60.0, 41.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetBlendMode(context!, CGBlendMode.Normal)
        
        let shadowSize: CGFloat = 1.5
        let cornerRadius: CGFloat = 2.5
        let shapeLayer = CAShapeLayer()

        let path = UIBezierPath(roundedRect: CGRectMake(shadowSize, shadowSize, size.width - (shadowSize * 2), size.height - (shadowSize * 2)), cornerRadius: cornerRadius)
        
        shapeLayer.path = path.CGPath
        shapeLayer.fillColor = UIColor.whiteColor().CGColor
        shapeLayer.strokeColor = UIColor(red: 35.0 / 255.0, green: 31.0 / 255.0, blue: 32.0 / 255.0, alpha: 0.12).CGColor
        shapeLayer.shadowColor = UIColor.blackColor().CGColor
        shapeLayer.shadowOpacity = 0.18
        shapeLayer.shadowOffset = CGSizeZero
        shapeLayer.shadowRadius = shadowSize
        shapeLayer.cornerRadius = cornerRadius
        shapeLayer.renderInContext(context!)
        
        let createImojiImage = UIImage(named: "Artmoji-Create-Imoji")!
        UIGraphicsBeginImageContextWithOptions(createImojiImage.size, false, 0.0)
        IMArtmojiConstants.DefaultBarTintColor.setFill()
        let bounds = CGRectMake(0, 0, createImojiImage.size.width, createImojiImage.size.height)
        UIRectFill(bounds)
        createImojiImage.drawInRect(bounds, blendMode: CGBlendMode.DestinationIn, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tintedImage!.drawInRect(CGRectMake((size.width - tintedImage!.size.width) / 2.0,
            (size.height - createImojiImage.size.height) / 2.0,
            tintedImage!.size.width,
            tintedImage!.size.height))
        
        let layer = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return layer!
    }


    // Mark: - UIKit.UIImagePickerController's completion selector
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<Void>) {
        if error == nil {
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityController.excludedActivityTypes = [
                UIActivityTypeAddToReadingList,
                UIActivityTypePostToVimeo
            ]
            
            activityController.popoverPresentationController?.sourceView = self.createArtmojiView.shareButton
            presentViewController(activityController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Yikes!", message: "There was a problem saving your Artmoji to your photos.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
        
        // Allow images to be saved again
        self.createArtmojiView.shareButton.userInteractionEnabled = true;
    }

}

// MARK: - IMCreateArtmojiViewDelegate
extension IMCreateArtmojiViewController: IMCreateArtmojiViewDelegate {
    public func artmojiView(view: IMCreateArtmojiView, didFinishLoadingImoji imoji: IMImojiObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }

    public func userDidCancelCreateArtmojiView(view: IMCreateArtmojiView, dirty: Bool) {
        if dirty {
            let alert = UIAlertController(title: "Start new artmoji?", message: "This will clear your current work.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Keep Editing", style: UIAlertActionStyle.Default, handler: nil))
            alert.addAction(UIAlertAction(title: "New", style: UIAlertActionStyle.Default) { alert in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            presentViewController(alert, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(false, completion: nil)
        }
    }

    public func userDidFinishCreatingArtmoji(artmoji: UIImage, view: IMCreateArtmojiView) {
        // Prevent multiple saves of the same image
        self.createArtmojiView.shareButton.userInteractionEnabled = false;
        
        UIImageWriteToSavedPhotosAlbum(artmoji, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    public func userDidSelectImojiCollectionButtonFromArtmojiView(view: IMCreateArtmojiView) {
        let collectionViewController = IMCollectionViewController(session: self.session)
        collectionViewController.topToolbar.barTintColor = IMArtmojiConstants.DefaultBarTintColor
        collectionViewController.topToolbar.translucent = false
        collectionViewController.backButton.setImage(UIImage(named: "Artmoji-Borderless-Cancel"), forState: UIControlState.Normal)
        collectionViewController.backButton.hidden = false

        collectionViewController.bottomToolbar.addFlexibleSpace()
        collectionViewController.bottomToolbar.addToolbarButtonWithType(IMToolbarButtonType.Trending)
        collectionViewController.bottomToolbar.addFlexibleSpace()
        
        #if NOT_PHOTO_EXTENSION
        let createImojiImage = drawCreateImojiButtonImage().imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        collectionViewController.bottomToolbar.addBarButton(UIBarButtonItem(image: createImojiImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(collectionViewControllerCreateImojiButtonTapped)))
        #endif
        
        collectionViewController.bottomToolbar.addToolbarButtonWithType(IMToolbarButtonType.Reactions)
        collectionViewController.bottomToolbar.addFlexibleSpace()
        collectionViewController.bottomToolbar.barTintColor = IMArtmojiConstants.DefaultBarTintColor
        collectionViewController.bottomToolbar.translucent = false
        collectionViewController.bottomToolbar.delegate = self

        collectionViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        collectionViewController.collectionView.infiniteScroll = true
        collectionViewController.collectionView.collectionViewDelegate = self
        collectionViewController.collectionViewControllerDelegate = self
        collectionViewController.searchView.delegate = self
        
        presentViewController(collectionViewController, animated: true) { finished in
            #if !NOT_PHOTO_EXTENSION
            collectionViewController.topToolbar.mas_makeConstraints { make in
                make.top.equalTo()(collectionViewController.view).offset()(50)
            }

            collectionViewController.collectionView.mas_makeConstraints { make in
                make.top.equalTo()(collectionViewController.view).offset()(50)
            }
            #endif
            
            collectionViewController.bottomToolbar.selectButtonOfType(IMToolbarButtonType.Trending)
        }
    }
}

// MARK: - IMToolbarDelegate
extension IMCreateArtmojiViewController: IMToolbarDelegate {
    public func userDidSelectCategory(category: IMImojiCategoryObject, fromCollectionView collectionView: IMCollectionView) {
        collectionView.loadImojisFromCategory(category)
    }
    
    public func userDidSelectToolbarButton(buttonType: IMToolbarButtonType) {
        switch buttonType {
            case IMToolbarButtonType.Trending:
                let collectionViewController = presentedViewController as! IMCollectionViewController
                collectionViewController.collectionView.loadImojiCategoriesWithOptions(IMCategoryFetchOptions.init(classification: IMImojiSessionCategoryClassification.Trending))
                break
            case IMToolbarButtonType.Reactions:
                let collectionViewController = presentedViewController as! IMCollectionViewController
                collectionViewController.collectionView.loadImojiCategoriesWithOptions(IMCategoryFetchOptions.init(classification: IMImojiSessionCategoryClassification.Generic))
                break
            default:
                break
        }
    }
}

#if NOT_PHOTO_EXTENSION
// MARK: - IMCameraViewControllerDelegate
extension IMCreateArtmojiViewController: IMCameraViewControllerDelegate {
    public func userDidCancelCameraViewController(viewController: IMCameraViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    public func userDidCaptureImage(image: UIImage, metadata: NSDictionary?, fromCameraViewController viewController: IMCameraViewController) {
        let createImojiViewController = IMCreateImojiViewController(sourceImage: image, session: self.session)
        createImojiViewController.createDelegate = self
        viewController.presentViewController(createImojiViewController, animated: false, completion: nil)
    }
    
    public func userDidPickImage(image: UIImage, editingInfo: [NSObject : AnyObject]?, fromImagePickerController picker: UIImagePickerController) {
        let createImojiViewController = IMCreateImojiViewController(sourceImage: image, session: self.session)
        createImojiViewController.createDelegate = self
        createImojiViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        createImojiViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        picker.presentViewController(createImojiViewController, animated: true, completion: nil)
    }
}
#endif

// MARK: - IMCreateImojiViewControllerDelegate
extension IMCreateArtmojiViewController: IMCreateImojiViewControllerDelegate {
    public func imojiUploadDidComplete(localImoji: IMImojiObject, persistentImoji: IMImojiObject?, withError error: NSError?, fromViewController viewController: IMCreateImojiViewController) {
        if error == nil {
            createArtmojiView.addImoji(persistentImoji!)
        }
    }
    
    public func userDidCancelImageEdit(viewController: IMCreateImojiViewController) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
    }
}

// MARK: - IMCollectionViewControllerDelegate
extension IMCreateArtmojiViewController: IMCollectionViewControllerDelegate {
    public func userDidSelectSplash(splashType: IMCollectionViewSplashCellType, fromCollectionView collectionView: IMCollectionView) {
        switch splashType {
            case IMCollectionViewSplashCellType.NoResults:
                let collectionViewController = presentedViewController as! IMCollectionViewController
                collectionViewController.searchView.searchTextField.becomeFirstResponder()
                break;
            default:
                break;
        }
    }
}

extension IMCreateArtmojiViewController: IMSearchViewDelegate {
    public func userDidTapBackButtonFromSearchView(searchView: IMSearchView!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - IMCollectionViewDelegate
extension IMCreateArtmojiViewController: IMCollectionViewDelegate {
    public func userDidSelectImoji(imoji: IMImojiObject, fromCollectionView collectionView: IMCollectionView) {
        createArtmojiView.addImoji(imoji)
    }
}


