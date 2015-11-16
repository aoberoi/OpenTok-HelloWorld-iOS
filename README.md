# OpenTok HelloWorld iOS

This project is an updated HelloWorld code sample, with more modern coding and platform practices
adopted.

## Requirements

You must have the latest version of Xcode and Cocoapods installed.

## Set up

1. Rename the `Config.plist.sample` file to `Config.plist`. Fill in the values inside the
   `HelloWorldSession` dictionary with a valid OpenTok API Key, Session ID, and Token.
2. Run `pod install` inside the project directory.
3. Open `HelloWorld.xcworkspace`. Build and Run.


## Updates

*  Uses Swift programming language
*  Sets iOS 8.0 as minimum deployment target
*  Uses Storyboards for building the interface
*  Uses AutoLayout constraints to achieve adaptivity

## Future Improvements

*  Investigate using Collection View (or Stack View) for layout
*  Enable bitcode
*  Investigate building custom renderers (views) that can respond to `intrinsicContentSize`,
   `layoutSubviews`; has sane values for content-hugging and compression-resistance, etc. [This
   post](http://stackoverflow.com/a/15978951/305340) on SO contains a mostly exhaustive list of
   concerns for AutoLayout. Also, find ways to leverage @IBDesignable and @IBInspectable.

