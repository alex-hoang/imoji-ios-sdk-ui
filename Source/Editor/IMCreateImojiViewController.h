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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IMCreateImojiViewControllerDelegate;
@class IMImojiObject, IMImojiSession, IMCreateImojiView;

/**
* A simple view controller to display an Imoji sticker creator along with a screen to add tags.
*/
@interface IMCreateImojiViewController : UIViewController

@property(readonly, nonnull) UIImage *sourceImage;

/**
* @abstract Creates a new editor view controller with a specified image
*/
- (nonnull instancetype)initWithSourceImage:(nonnull UIImage *)sourceImage session:(nonnull IMImojiSession *)session;

/**
* @abstract Creates a new editor view controller with a specified image
*/
+ (nonnull instancetype)controllerWithSourceImage:(nonnull UIImage *)sourceImage session:(nonnull IMImojiSession *)session;

/**
* @abstract Clears all the edits and restores the original state of the editor
*/
- (void)reset;

/**
* @abstract Displays the help screen to the user
*/
- (void)showHelpScreen;

/**
* @abstract A delegate to receive events from the editor view controller
*/
@property(nonatomic, strong, nullable) id <IMCreateImojiViewControllerDelegate> createDelegate;

/**
* @abstract The editor view attached to the view controller
*/
@property(nonatomic, readonly, nonnull) IMCreateImojiView *imojiEditor;

/**
* @abstract The current Imoji Session
*/
@property(nonatomic, strong, nonnull) IMImojiSession *session;

/**
* @abstract Whether or not to enable showing the tag screen
*/
@property(nonatomic) BOOL enableTagScreen;

@end

@protocol IMCreateImojiViewControllerDelegate <NSObject>

@optional

/**
* @abstract Called by IMCreateImojiViewController once the user has completed the editing process and before uploading
 * the contents to the server for persistence. A temporary, non server persisted Imoji object is passed back to the
 * delegate method allowing the consumer to immediately display the Imoji.
*/
- (void)imojiUploadDidBegin:(nonnull IMImojiObject *)localImoji
         fromViewController:(nonnull IMCreateImojiViewController *)viewController;

/**
* @abstract Called by IMCreateImojiViewController once the Imoji has been completely uploaded to the server. A fully
 * persisted Imoji object is passed along with a local copy which was created prior to uploading.
*/
- (void)imojiUploadDidComplete:(nonnull IMImojiObject *)localImoji
               persistentImoji:(nullable IMImojiObject *)persistentImoji
                     withError:(nullable NSError *)error
            fromViewController:(nonnull IMCreateImojiViewController *)viewController;

/**
* @abstract Called by IMCreateImojiViewController when the user hits the back button. The caller should dismiss the view
 * controller accordingly
*/
- (void)userDidCancelImageEdit:(nonnull IMCreateImojiViewController *)viewController;

@end
