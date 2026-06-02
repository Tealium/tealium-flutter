## 3.0.0
* iOS: Added Swift Package Manager (SPM) support alongside CocoaPods. Both remain supported; no action needed for CocoaPods users.
* **Breaking change:** Minimum requirements raised to Flutter 3.41 / Dart 3.11 and iOS 13.0 (from 12.0). Raise your app's iOS deployment target to 13.0 or higher.
* Updated `tealium` dependency to ^4.0.0.

## 2.0.0
* Updated `tealium` dependency to ^3.0.0
* Android: Updated Braze Remote Command to 3.3.0 (Braze SDK v41 support)
* Android: Minimum SDK raised to 25
* iOS: Updated TealiumBraze to ~> 3.6 (BrazeKit v14 support)
* iOS: Updated tealium-swift/Core dependency to ~> 2.18
* Dart SDK constraint widened to `>=2.18.0 <4.0.0` (adds Dart 3 support)

## 1.2.0
* Android 
    * Fix to resolve missing `namespace` issue when using AGP v8
    * Bumped Tealium dependencies
    * Bumped Android/Kotlin version support

## 1.1.0
* Updated dependencies for XCode 15
* Increased minimum iOS deployment target to 12.0

## 1.0.0

* Initial release of the Tealium Braze Remote Command plugin
