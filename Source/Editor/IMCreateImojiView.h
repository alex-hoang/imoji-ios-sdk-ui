//
//  ImojiSDKUI
//
//  Created by Thor Harald Johansen, Nima Khoshini
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

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@protocol IMCreateImojiViewDelegate;

/**
* Base UIView class that performs imoji sticker creation
*/
@interface IMCreateImojiView : GLKView

/**
* @abstract Reverts the last edit made by the user if any
*/
- (void)undo;

/**
* @abstract Whether or not the edit process is complete
*/
- (BOOL)hasOutputImage;

/**
* @abstract Whether or not the user made edits that can be undone
*/
- (BOOL)canUndo;

/**
* @abstract Scrolls the viewport to a given point
*/
- (void)scrollTo:(CGPoint)point;

/**
* @abstract Zooms the viewport by a multiple
*/
- (void)zoomTo:(CGFloat)zoom;

/**
* @abstract Reverts the last edit made by the user if any
*/
- (void)loadImage:(UIImage * __nonnull )image;

/**
* @abstract Clears all edits and resets the viewport
*/
- (void)reset;

/**
* @abstract Removes the editor from the view
*/
- (void)unload;

/**
* @abstract The finalized image without borders for export. If hasOutputImage is false, this will return nil.
*/
@property(nonatomic, readonly, nonnull) UIImage *outputImage;

/**
* @abstract The finalized image with borders for export. If hasOutputImage is false, this will return nil.
*/
@property(nonatomic, readonly, nonnull) UIImage *borderedOutputImage;

/**
* @abstract Optional delegate property to listen for changes to the editor
*/
@property(nonatomic, assign, nullable) id<IMCreateImojiViewDelegate> editorDelegate;

@end

@protocol IMCreateImojiViewDelegate <NSObject>

@optional

/**
* @abstract Called when the user made an edit to the view
*/
- (void)userDidUpdatePathInEditorView:(IMCreateImojiView * __nonnull)editorView;

@end
