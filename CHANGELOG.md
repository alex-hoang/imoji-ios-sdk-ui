# Imoji iOS UI Widgets Changes

### Version 2.2.3

* Attribution images where not being reloaded properly sometimes.
* Fixes a crash caused by users tapping a category prior to it being loaded.
* Fixes memory leaks from ImojiGraphics when dismissing IMCreateImojiViewController.
* Sets an upper limit to source image for IMCreateImojiViewController of 2300x2300.

### Version 2.2.2

* Adds support for imoji-ios-sdk 2.3.2. Update and deprecate relevant methods to support IMImojiImageReference.
* Category's preview imoji will now appear as the first result when loading a category.
* Deprecated loadUserCollectionImojis for loadCollectedImojisWithType.
* Fixed crash in IMCameraViewController for devices where the camera is unavailable.
* Cleaned up view hiearchy in IMCreateImojiAssistantViewController and IMCreateImojiViewController.
* Added utility methods to IMCollectionView to manually load IMCategoryObjects or IMImojiObject's
* Fixed an issue where users are unable to modify a sticker border on the top or bottom sections of the create screen.
* Removed support for stock MSStickerView's UITapGestureRecognizer. Callers should implement userDidSelectSticker:andImoji:fromCollectionView from IMCollectionViewDelegate.
* Avoid loading MSSticker objects larger than 500kb.

### Version 2.2.1

* Generalize IMCameraViewController for use in the ImojiSDKUI.
* Convert Artmoji to swift 2.3.
* Update Artmoji to use non-deprecated methods and properties.
* Move IMDrawingUtils to ImojiSDKUI common.
* Remove presentingViewControllerType from artmoji as IMCameraViewController's delegate methods are enough.
* Fixes #73

### Version 2.2.0

* Adds support for loading iOS 10 sticker objects in IMCollectionView! Just set loadUsingStickerViews to YES for you IMCollectionView instance. Both still and animated content is supported.

### Version 2.1.2

* Fixes a crash with the no recents splash

### Version 2.1.1

* Fix constraint with back button in half screen view when clearing text field
* Create Imoji Button doesn't show up if the developer doesn't have the editor pod spec enabled
* Cosmetic changes to IMSearchView
* Attribution views moved to IMSuggestionCollectionView
* Fix clear button appearing on top of cancel button for various screen experiences

### Version 2.1.0

* New widgets!
  * We've added IMHalfScreenView and IMQuarterScreenView as 2 new CollectionView's. 
  * IMQuarterScreenView replaces IMSuggestionView. Use this view in places where Imoji content is displayed aboved the input field.
  * IMHalfScreenView replaces IMKeyboardView. Use this view in places where Imoji content replaces the keyboard.
* Made CollectionView the default subspec. The Editor subspec is not pulled by default anymore
* Added ImojiKit sample project. All other former samples with the exception of Artmoji (Categories, Search, Prompts, etc.) are now rolled into this app.

### Version 2.0.10

* Make CollectionView the default subspec for this project
* Fixed #53 (alex-hoang)

### Version 2.0.9

* Use new fetchCollectedImojisWithType method from v2.2.1 of ImojiSDK
* IMKeyboardCollectionView now exports 16x9 animated content

### Version 2.0.8

* Updated to use ImojiSDK v2.2.0
* Refreshed loading placeholder images

### Version 2.0.7

* Adds the ability for developers to send contextual search phrases to category fetching in order to retrieve results relevant to the search phrase
* Adds SuggestionView component to the UI project. Developers can use this to display Imoji stickers in small size format above input bars.
* Prevented the share button in Artmoji example from saving multiple images before completion.
* Deprecated fetchRenderingOptions because it is no longer being used.
* Made tapping on the no results splash view focus on the search bar SDK wide.
* Bring in webp depedency from YYImage

### Version 2.0.6

* Avoid annoying pcm bugs with ImojiGraphics
* Added explicit dependency to YYImage in CollectionView submodule

### Version 2.0.5

* Fixed an issue when sometimes a ghosted image would show up when a user tapped a collection view cell before the image had been downloaded
* Change YYImage references to not be bundled references

### Version 2.0.4

* Ensure all imoji reloads happen with queued operations, regardless of iOS versions helps address the cases in which reloads case assertion failures caused by new search results clearing out previous ones.
* Update Keyboard VC to use the new renderImojiForExport: method.
* Fix bitcode woes with ImojiGraphics

### Version 2.0.3

* Fixes that pesky 'pcm: No such file or directory' warning from ImojiGraphics

### Version 2.0.2

* Switched to YYAnimatedImage and YYImage for rendering animated images
* Cleanup with renderCount on IMImojiCollectionView, fixes issues with infinite scroll where the next page would never load sometimes
* Addresses an issue where sometimes scrolling to the next page would case a problem since the loading indicator was already removed
* Support animated stickers in the keyboard sources

### Version 2.0.1

* Adds support for infinite scroll to IMCollectionView. When a result set reaches the end, the collection view will load a relevant followup term and continue to display Imojis to the user.
* Adds support for showing headers in IMCollectionView. The section headers describe what is being displayed (a category, search term, etc.)

### Version 2.0.0

* Support for displaying attributed artist categories! Artist categories are displayed just like normal categories however they will have attribution with detailed profile info for the artist as well as attribution links.
* Bug fix for client keyboard buttons not being actionable when network is unreachable
* Use proper semantic versioning for ImojiSDK and ImojiSDKUI

### Version 0.1.18

* Using fetchRenderingOptions from IMImojiSession for the default size to render Imoji's in the collection views
* Updated Imoji creation to trigger callbacks before and after uploading
* Fixes a bug in which the Imoji Editor would crash loading large images.

### Version 0.1.17

* Full support for loading ImojiSDKUI as a dynamic library
* Bitcode support which now requires Xcode 7 for archiving your applications
* Fixes an issue with some images for the imoji editor not showing up on iOS 7
* Fixes a crash when switching categories rapidly in IMCollectionView
* Adds a delay setting for auto searching in IMCollectionViewController
* Ensures that the Done button is displayed when the search bar text is empty in IMCollectionViewController
* Completed Artmoji Sample!

### Version 0.1.16

* Addresses build issues with Swift projects and ImojiGraphics when loading ImojiSDKUI as a framework

### Version 0.1.15

* iOS 7 Fixes
  * Addresses crashes with collection view assertions
  * Fixed Tips in the Imoji creation view
  * Fixed misaligned category collection view cells
  * Stopped calling imageNamed:inBundle:compatibleWithTraitCollection which is not available on iOS 7
* Functionality
  * Add the ability to turn off selection animation for IMCollectionView
  * Adds a Messaging App Example
  * When saving a new Imoji, update the toolbar and show an activity indicator

### Version 0.1.14

* Collection View fixes
  * Fixes a bug in which the Imoji session passed up to IMCollectionViewController was being reset
  * Splash screens were not centering properly
  * Shows loading indicator when loading a category
  * Modularized collection view to allow subclasses to have more control
  * Collection view cells were not taking up the full width of the view, the rounding logic for the cell size was off
  * Better support for orientation changes
  * Added loadImojisFromCategory to IMCollectionView for convenience

* Editor
  * Avoid showing translucency on the image being edited until the user has selected a path

### Version 0.1.13

* Fixed some issues with portrait/landscape transitions in IMCollectionViewController
* Allows flexibility to specify the preferred displayed size of the imojis

### Version 0.1.12

* Nifty tutorials for the editor!
* Updated assets for creation and tagging
* Allow for clients to specify their own styles

### Version 0.1.11

* Many enhancements to IMCollectionViewController for customizing the toolbar contents and display
* Exposes a shared common toolbar IMToolbar for Imoji components

### Version 0.1.10

* Fixed crash that occurs in the editor when the user goes to the tag screen then goes back and makes changes to the sticker
* Panning around the Editor can now be done with one finger once the border has been drawn. Previously users had to use 2 touches.
* Refactored userDidFinishCreatingImoji:withError: in IMCreateImojiViewControllerDelegate and added the source view controller to the signature

### Version 0.1.9

* Switched over to showing 3 Imoij Categories in Collection View
* Added ability to switch on/off auto search in collection view controller
* Improved collection view controller to handle updating content insets when keyboard is shown

### Version 0.1.8

* Adds sentence parsing functionality to the collection views!
* Adds IMCollectionViewController to facilitate integration
* Modified IMCreateImojiViewController to require IMImojiSession
* refactor ImojiCollectionViewContentType to IMCollectionViewContentType
* refactor imojiCollectionViewDidFinishSearching: to imojiCollectionView:didFinishLoadingContentType:

### Version 0.1.7

* Improvements to collection views! 
* Much of the common Imoji Keyboard Collection View functionality is now part of the base collection view
* Removed callbacks from collection views in favor of delegates

### Version 0.1.6

* Adds Imoji Editor to the SDK (Beta)!

### Version 0.1.5

* Adds loading user collections back to IMCollectionView
* Gray stock theme

### Version 0.1.4

* Support for loading imojis from a users collection if their session is synchronized
* Larger displayed images
* Adds support for specifying fonts and app group for implementors
* Addresses issue with categories not reloading when user has drilled into a category already and wants to go back

### Version 0.1.3

* Ensure that consumers of the keyboard view controller independently set the API credentials.
* Remove unused pod dependencies

### Version 0.1.2

* Adds Imoji Keyboard functionality as it's own Pod subspec

### Version 0.1.1

* Collection status view cell bug fix

### Version 0.1.0

* Introducing Imoji iOS UI components!
