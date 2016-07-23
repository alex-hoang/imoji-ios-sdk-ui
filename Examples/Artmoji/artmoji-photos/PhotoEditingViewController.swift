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
import Photos
import PhotosUI
import ImojiSDKUI

class PhotoEditingViewController: IMCreateArtmojiViewController {

    var input: PHContentEditingInput?

    required init?(coder aDecoder: NSCoder) {
        ImojiSDK.sharedInstance().setClientId(NSUUID(UUIDString: "748cddd4-460d-420a-bd42-fcba7f6c031b")!, apiToken: "U2FsdGVkX1/yhkvIVfvMcPCALxJ1VHzTt8FPZdp1vj7GIb+fsdzOjyafu9MZRveo7ebjx1+SKdLUvz8aM6woAw==")
        super.init(sourceImage: nil, capturedImageOrientation: nil, session: IMImojiSession(), imageBundle: IMResourceBundleUtil.assetsBundle())
    }
}

// MARK: - PHContentEditingController
extension PhotoEditingViewController: PHContentEditingController {
    func canHandleAdjustmentData(adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
//        if let adjustmentData = adjustmentData {
//            return adjustmentData.formatIdentifier == IMArtmojiConstants.FormatIdentifier && adjustmentData.formatVersion == IMArtmojiConstants.FormatVersion
//        }
        return false
    }

    func startContentEditingWithInput(contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
        sourceImage = UIImage(contentsOfFile: self.input!.fullSizeImageURL!.path!)
        loadView()
    }

    func finishContentEditingWithCompletionHandler(completionHandler: (PHContentEditingOutput?) -> Void) {
        // Update UI to reflect that editing has finished and output is being rendered.

        // Render and provide output on a background queue.
        dispatch_async(dispatch_get_global_queue(CLong(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)

            // Provide new adjustments and render output to given location.
            output.adjustmentData = PHAdjustmentData(formatIdentifier: IMArtmojiConstants.FormatIdentifier, formatVersion: IMArtmojiConstants.FormatVersion, data: NSKeyedArchiver.archivedDataWithRootObject([String:AnyObject]()))

            let outputImage = self.createArtmojiView.drawCompositionImage()
            let renderedJPEGData = UIImageJPEGRepresentation(outputImage, 1.0)
            renderedJPEGData!.writeToURL(output.renderedContentURL, atomically: true)

            // Call completion handler to commit edit to Photos.
            completionHandler(output)

            // Clean up temporary files, etc.
        }
    }

    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }

    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }
}
